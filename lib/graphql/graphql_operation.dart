import 'package:gql/ast.dart';
import 'package:gql/language.dart';

import 'graphql_transport.dart';

typedef GraphQLDataDecoder<T> = T Function(Map<String, dynamic> json);
typedef GraphQLVariablesEncoder<T> = Map<String, dynamic> Function(T value);

/// Variables value for a generated operation that declares no variables.
class GraphQLNoVariables {
  const GraphQLNoVariables();
}

/// A schema-checked GraphQL document with its generated Dart data types.
class GraphQLOperation<TData, TVariables> {
  GraphQLOperation({
    required DocumentNode document,
    required this.operationName,
    required this.decodeData,
    required this.encodeVariables,
  }) : document = printNode(document);

  final String document;
  final String operationName;
  final GraphQLDataDecoder<TData> decodeData;
  final GraphQLVariablesEncoder<TVariables> encodeVariables;
}

/// A typed GraphQL response that can contain both partial data and errors.
class TypedGraphQLResponse<TData> {
  const TypedGraphQLResponse({
    required this.data,
    required this.errors,
    this.extensions,
  });

  final TData? data;
  final List<GraphQLError> errors;
  final Map<String, dynamic>? extensions;

  bool get hasErrors => errors.isNotEmpty;
}

class GraphQLResponseDecodingException implements Exception {
  const GraphQLResponseDecodingException(this.operationName, this.cause);

  final String operationName;
  final Object cause;

  @override
  String toString() =>
      'GraphQLResponseDecodingException: Failed to decode $operationName: '
      '$cause';
}
