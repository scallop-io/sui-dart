import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:sui_dart/graphql/operations.graphql.dart' as generated;
import 'package:sui_dart/sui.dart' hide RequestOptions;
import 'package:test/test.dart';

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter(this.handler, {this.statusCode = 200});

  final Map<String, dynamic> Function(Map<String, dynamic> body) handler;
  final int statusCode;
  Map<String, dynamic>? lastBody;
  Map<String, dynamic>? lastHeaders;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastBody = Map<String, dynamic>.from(options.data as Map);
    lastHeaders = options.headers;
    return ResponseBody.fromString(
      jsonEncode(handler(lastBody!)),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(_MockAdapter adapter) => Dio()..httpClientAdapter = adapter;

void main() {
  test('network endpoints and transport request shape', () async {
    expect(
      SuiUrls.graphql(SuiNetwork.mainnet),
      'https://graphql.mainnet.sui.io/graphql',
    );
    expect(
      SuiUrls.graphql(SuiNetwork.localnet),
      'http://127.0.0.1:9125/graphql',
    );

    final adapter = _MockAdapter(
      (_) => {
        'data': {'chainIdentifier': 'chain-id'},
      },
    );
    final client = SuiGraphQLClient(
      endpoint: 'https://example.test/graphql',
      dio: _dioWith(adapter),
      headers: const {'authorization': 'test-value'},
    );

    expect(await client.getChainIdentifier(), 'chain-id');
    expect(adapter.lastBody!['query'], contains('chainIdentifier'));
    expect(adapter.lastBody!.containsKey('variables'), isFalse);
    expect(adapter.lastHeaders!['authorization'], 'test-value');

    final response = await client.query(
      'query Chain { chainIdentifier }',
      operationName: 'Chain',
      extensions: const {'requestId': 'test'},
    );
    expect(response.data!['chainIdentifier'], 'chain-id');
    expect(adapter.lastBody!['operationName'], 'Chain');
    expect(adapter.lastBody!['extensions'], {'requestId': 'test'});
  });

  test('raw queries preserve partial data and structured errors', () async {
    final adapter = _MockAdapter(
      (_) => {
        'data': {'chainIdentifier': 'partial-chain-id'},
        'errors': [
          {
            'message': 'bad filter',
            'locations': [
              {'line': 1, 'column': 2},
            ],
            'path': ['chainIdentifier'],
            'extensions': {'code': 'BAD_FILTER'},
          },
        ],
        'extensions': {'service': 'sui'},
      },
    );
    final client = SuiGraphQLClient(
      endpoint: 'https://example.test/graphql',
      dio: _dioWith(adapter),
    );

    final response = await client.query('{ chainIdentifier }');
    expect(response.data!['chainIdentifier'], 'partial-chain-id');
    expect(response.errors.single.message, 'bad filter');
    expect(response.errors.single.locations.single.line, 1);
    expect(response.errors.single.path, ['chainIdentifier']);
    expect(response.errors.single.extensions!['code'], 'BAD_FILTER');
    expect(response.extensions!['service'], 'sui');

    await expectLater(
      client.getChainIdentifier(),
      throwsA(
        isA<GraphQLException>()
            .having((error) => error.errors, 'errors', hasLength(1))
            .having(
              (error) => error.message,
              'message',
              contains('bad filter'),
            ),
      ),
    );
  });

  test('generated operations return typed data and variables', () async {
    final adapter = _MockAdapter(
      (_) => {
        'data': {'chainIdentifier': 'typed-chain-id'},
      },
    );
    final client = SuiGraphQLClient(
      endpoint: 'https://example.test/graphql',
      dio: _dioWith(adapter),
    );
    final operation =
        GraphQLOperation<generated.Query$ChainIdentifier, GraphQLNoVariables>(
          document: generated.documentNodeQueryChainIdentifier,
          operationName: 'ChainIdentifier',
          decodeData: generated.Query$ChainIdentifier.fromJson,
          encodeVariables: (_) => const {},
        );

    final response = await client.execute(
      operation,
      const GraphQLNoVariables(),
    );

    expect(response.data!.chainIdentifier, 'typed-chain-id');
    expect(adapter.lastBody!['operationName'], 'ChainIdentifier');
    expect(adapter.lastBody!.containsKey('variables'), isFalse);
  });

  test('generated operation decoding failures are explicit', () async {
    final adapter = _MockAdapter(
      (_) => {
        'data': {'chainIdentifier': 42},
      },
    );
    final client = SuiGraphQLClient(
      endpoint: 'https://example.test/graphql',
      dio: _dioWith(adapter),
    );

    await expectLater(
      client.getChainIdentifier(),
      throwsA(isA<GraphQLResponseDecodingException>()),
    );
  });

  test('HTTP errors are rejected before response data is used', () async {
    final adapter = _MockAdapter(
      (_) => {
        'data': {'chainIdentifier': 'must-not-be-used'},
      },
      statusCode: 503,
    );
    final client = SuiGraphQLClient(
      endpoint: 'https://example.test/graphql',
      dio: _dioWith(adapter),
    );

    await expectLater(
      client.getChainIdentifier(),
      throwsA(
        isA<GraphQLRequestException>().having(
          (error) => error.statusCode,
          'statusCode',
          503,
        ),
      ),
    );
  });

  test('cancelled requests use the GraphQL request exception', () async {
    final adapter = _MockAdapter((_) => {'data': <String, dynamic>{}});
    final client = SuiGraphQLClient(
      endpoint: 'https://example.test/graphql',
      dio: _dioWith(adapter),
    );
    final cancelToken = CancelToken()..cancel();

    await expectLater(
      client.query('{ chainIdentifier }', cancelToken: cancelToken),
      throwsA(
        isA<GraphQLRequestException>().having(
          (error) => error.isCancelled,
          'isCancelled',
          isTrue,
        ),
      ),
    );
  });

  test('transaction history requests newest page and parses details', () async {
    final adapter = _MockAdapter((body) {
      expect(body['variables'], {
        'address': '0xabc',
        'first': 2,
        'before': 'older-cursor',
        'showBalanceChanges': true,
        'showObjectChanges': true,
      });
      return {
        'data': {
          'transactions': {
            'pageInfo': {'hasPreviousPage': true, 'startCursor': 'next-cursor'},
            'nodes': [
              {
                'digest': 'D1',
                'sender': {'address': '0xabc'},
                'kind': {
                  '__typename': 'ProgrammableTransaction',
                  'commands': {
                    'pageInfo': {'hasNextPage': true},
                    'nodes': [
                      {'__typename': 'TransferObjectsCommand'},
                    ],
                  },
                },
                'effects': {
                  'timestamp': '2026-07-20T00:00:00Z',
                  'status': 'SUCCESS',
                  'gasEffects': {
                    'gasSummary': {
                      'computationCost': 1000,
                      'storageCost': 500,
                      'storageRebate': 300,
                    },
                  },
                  'balanceChanges': {
                    'pageInfo': {'hasNextPage': true},
                    'nodes': [
                      {
                        'owner': {'address': '0xabc'},
                        'amount': '-10',
                        'coinType': {'repr': '0x2::sui::SUI'},
                      },
                    ],
                  },
                  'objectChanges': {
                    'pageInfo': {'hasNextPage': false},
                    'nodes': [
                      {
                        'address': '0xobject',
                        'idCreated': false,
                        'idDeleted': false,
                        'inputState': {
                          'owner': {
                            '__typename': 'AddressOwner',
                            'address': {'address': '0xabc'},
                          },
                        },
                        'outputState': {
                          'owner': {
                            '__typename': 'AddressOwner',
                            'address': {'address': '0xdef'},
                          },
                          'asMoveObject': {
                            'contents': {
                              'type': {'repr': '0x1::nft::Nft'},
                            },
                          },
                        },
                      },
                    ],
                  },
                },
              },
            ],
          },
        },
      };
    });
    final client = SuiGraphQLClient(
      endpoint: 'https://example.test/graphql',
      dio: _dioWith(adapter),
    );

    final page = await client.queryTransactionsByAddress(
      '0xabc',
      first: 2,
      after: 'older-cursor',
      options: const TransactionHistoryOptions(showObjectChanges: true),
    );

    final document = adapter.lastBody!['query'] as String;
    expect(document, contains('affectedAddress'));
    expect(document, contains(r'last: $first'));
    expect(document, contains(r'before: $before'));
    expect(document, contains('balanceChanges'));
    expect(document, contains('objectChanges'));
    expect(document, contains('balanceChanges(first: 50)'));
    expect(document, contains('objectChanges(first: 50)'));
    expect(page.digests, ['D1']);
    expect(page.hasNextPage, isTrue);
    expect(page.endCursor, 'next-cursor');
    expect(page.transactions.single.success, isTrue);
    expect(page.transactions.single.senderAddress, '0xabc');
    expect(page.transactions.single.isProgrammableTransaction, isTrue);
    expect(page.transactions.single.commandTypes, ['TransferObjectsCommand']);
    expect(page.transactions.single.commandTypesTruncated, isTrue);
    expect(page.transactions.single.gasSummary?.netCost, BigInt.from(1200));
    expect(page.transactions.single.balanceChanges.single.amount, '-10');
    expect(page.transactions.single.balanceChangesTruncated, isTrue);
    expect(page.transactions.single.objectChangesTruncated, isFalse);
    expect(page.transactions.single.objectChanges.single.toJson(), {
      'objectId': '0xobject',
      'type': '0x1::nft::Nft',
      'kind': 'mutated',
      'from': '0xabc',
      'to': '0xdef',
    });
  });

  test('transaction gas summary is typed and forwards digest', () async {
    final adapter = _MockAdapter((body) {
      expect(body['variables'], {'digest': 'test-digest'});
      return {
        'data': {
          'transaction': {
            'effects': {
              'gasEffects': {
                'gasSummary': {
                  'computationCost': 100,
                  'storageCost': 200,
                  'storageRebate': 50,
                },
              },
            },
          },
        },
      };
    });
    final client = SuiGraphQLClient(
      endpoint: 'https://example.test/graphql',
      dio: _dioWith(adapter),
    );

    final summary = await client.getTransactionGasSummary('test-digest');

    expect(adapter.lastBody!['operationName'], 'TransactionGasSummary');
    expect(summary?.netCost, BigInt.from(250));
  });

  test('sender history uses sentAddress and validates page size', () async {
    final adapter = _MockAdapter(
      (_) => {
        'data': {
          'transactions': {
            'pageInfo': {'hasPreviousPage': false, 'startCursor': null},
            'nodes': <Map<String, dynamic>>[],
          },
        },
      },
    );
    final client = SuiGraphQLClient(
      endpoint: 'https://example.test/graphql',
      dio: _dioWith(adapter),
    );

    await client.queryTransactionsBySender('0xabc');
    expect(adapter.lastBody!['query'], contains('sentAddress'));
    await expectLater(
      client.queryTransactionsBySender('0xabc', first: 0),
      throwsRangeError,
    );
    await expectLater(
      client.queryTransactionsBySender('0xabc', first: 51),
      throwsRangeError,
    );
  });

  test('active validators paginate and parse metadata', () async {
    var request = 0;
    final adapter = _MockAdapter((body) {
      request++;
      expect(body['variables']['first'], 50);
      if (request == 2) expect(body['variables']['after'], 'page-2');
      return {
        'data': {
          'epoch': {
            'validatorSet': {
              'activeValidators': {
                'pageInfo': {
                  'hasNextPage': request == 1,
                  'endCursor': request == 1 ? 'page-2' : null,
                },
                'nodes': [
                  {
                    'contents': {
                      'json': {
                        'metadata': {
                          'name': 'Validator $request',
                          'sui_address': '0x$request',
                          'image_url': 'https://example.test/$request.png',
                        },
                        'voting_power': '100',
                        'commission_rate': '200',
                        'next_epoch_stake': '300',
                        'staking_pool': {
                          'id': '0xpool$request',
                          'sui_balance': '400',
                          'pool_token_balance': '500',
                          'activation_epoch': '6',
                        },
                      },
                    },
                  },
                ],
              },
            },
          },
        },
      };
    });
    final client = SuiGraphQLClient(
      endpoint: 'https://example.test/graphql',
      dio: _dioWith(adapter),
    );

    final validators = await client.getActiveValidators(pageSize: 50);
    expect(request, 2);
    expect(validators, hasLength(2));
    expect(validators.first.name, 'Validator 1');
    expect(validators.first.imageUrl, 'https://example.test/1.png');
    expect(validators.first.stakingPoolSuiBalance, BigInt.from(400));
  });

  test('active validator pagination rejects a repeated cursor', () async {
    final adapter = _MockAdapter(
      (_) => {
        'data': {
          'epoch': {
            'validatorSet': {
              'activeValidators': {
                'pageInfo': {'hasNextPage': true, 'endCursor': 'same'},
                'nodes': <Map<String, dynamic>>[],
              },
            },
          },
        },
      },
    );
    final client = SuiGraphQLClient(
      endpoint: 'https://example.test/graphql',
      dio: _dioWith(adapter),
    );

    await expectLater(client.getActiveValidators(), throwsStateError);
  });

  test('epoch, stakes, object history, and events parse results', () async {
    final adapter = _MockAdapter((body) {
      final document = body['query'] as String;
      if (document.contains('epoch(epochId')) {
        return {
          'data': {
            'epoch': {
              'epochId': 42,
              'referenceGasPrice': '1000',
              'totalTransactions': 12,
              'startTimestamp': '2026-07-20T00:00:00Z',
              'endTimestamp': null,
            },
          },
        };
      }
      if (document.contains('StakedSui')) {
        return {
          'data': {
            'address': {
              'objects': {
                'pageInfo': {'hasNextPage': true, 'endCursor': 'next-stake'},
                'nodes': [
                  {
                    'address': '0xstake',
                    'contents': {
                      'json': {
                        'pool_id': '0xpool',
                        'principal': {'value': '99'},
                        'stake_activation_epoch': '40',
                      },
                    },
                  },
                ],
              },
            },
          },
        };
      }
      if (document.contains('affectedObject')) {
        return {
          'data': {
            'transactions': {
              'pageInfo': {'hasNextPage': false, 'endCursor': null},
              'nodes': [
                {'digest': 'object-tx'},
              ],
            },
          },
        };
      }
      return {
        'data': {
          'events': {
            'pageInfo': {'hasNextPage': true, 'endCursor': 'next-event'},
            'nodes': [
              {
                'transactionModule': {'name': 'coin'},
                'sender': {'address': '0xsender'},
                'contents': {
                  'type': {'repr': '0x2::coin::Event'},
                  'json': {'value': 1},
                },
              },
            ],
          },
        },
      };
    });
    final client = SuiGraphQLClient(
      endpoint: 'https://example.test/graphql',
      dio: _dioWith(adapter),
    );

    final epoch = await client.getEpochSummary();
    expect(epoch.epochId, 42);
    expect(epoch.referenceGasPrice, BigInt.from(1000));

    final stakes = await client.getStakes('0xowner');
    expect(stakes.stakes.single.stakedSuiId, '0xstake');
    expect(stakes.stakes.single.principal, BigInt.from(99));
    expect(stakes.hasNextPage, isTrue);
    expect(stakes.endCursor, 'next-stake');

    final objectHistory = await client.queryTransactionsByObject('0xobject');
    expect(objectHistory.digests, ['object-tx']);

    final events = await client.queryEventsByModule('0x2', 'coin');
    expect(events.events.single.module, 'coin');
    expect(events.events.single.sender, '0xsender');
    expect(events.events.single.type, '0x2::coin::Event');
    expect(events.events.single.json, {'value': 1});
    expect(events.hasNextPage, isTrue);
    expect(events.endCursor, 'next-event');
  });
}
