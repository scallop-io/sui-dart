import 'package:sui_dart/builder/serializer.dart';
import 'package:sui_dart/grpc/grpc_resolution_client.dart';
import 'package:sui_dart/grpc/types.dart';
import 'package:test/test.dart';

void main() {
  group('normalizedMoveTypeToJson', () {
    test('primitives map to the JSON-RPC capitalized form', () {
      expect(normalizedMoveTypeToJson(const MoveTypePrimitive('U64')), 'U64');
      expect(
        normalizedMoveTypeToJson(const MoveTypePrimitive('Address')),
        'Address',
      );
    });

    test('vector / struct / type-parameter shapes', () {
      expect(
        normalizedMoveTypeToJson(const MoveTypeVector(MoveTypePrimitive('U8'))),
        {'Vector': 'U8'},
      );
      expect(normalizedMoveTypeToJson(const MoveTypeParameter(2)), {
        'TypeParameter': 2,
      });

      final struct = normalizedMoveTypeToJson(
        const MoveTypeStruct(
          address: '0x2',
          module: 'coin',
          name: 'Coin',
          typeArguments: [MoveTypePrimitive('U64')],
        ),
      );
      expect(struct['Struct']['module'], 'coin');
      expect(struct['Struct']['typeArguments'], ['U64']);
    });

    // The whole point: the converted shape must feed the builder's serializer,
    // which decides pure-vs-object encoding. Run it end to end.
    test('output is accepted by normalizedTypeToMoveTypeSignature', () {
      final sig = normalizedTypeToMoveTypeSignature(
        normalizedMoveTypeToJson(const MoveTypePrimitive('U64')),
      );
      expect(sig['ref'], isNull);
      expect(sig['body'], 'u64');
    });

    test('reference wrapping is preserved through the serializer', () {
      final json = normalizedMoveTypeToJson(
        const MoveTypeMutableReference(
          MoveTypeStruct(
            address: '0x2',
            module: 'coin',
            name: 'Coin',
            typeArguments: [MoveTypePrimitive('U64')],
          ),
        ),
      );
      expect(json.containsKey('MutableReference'), isTrue);

      final sig = normalizedTypeToMoveTypeSignature(json);
      expect(sig['ref'], '&mut');
      expect(sig['body']['datatype']['module'], 'coin');
    });
  });
}
