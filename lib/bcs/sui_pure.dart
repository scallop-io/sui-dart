import 'package:bcs_dart/bcs.dart';
import 'package:sui_dart/bcs/sui_bcs.dart';

class SuiPure {
  static BcsType pureBcsSchemaFromTypeName(String name) {
    switch (name) {
      case 'u8':
        return Bcs.u8();
      case 'u16':
        return Bcs.u16();
      case 'u32':
        return Bcs.u32();
      case 'u64':
        return Bcs.u64();
      case 'u128':
        return Bcs.u128();
      case 'u256':
        return Bcs.u256();
      case 'bool':
        return Bcs.boolean();
      case 'string':
        return Bcs.string();
      case 'id':
      case 'address':
        return SuiBcs.Address;
    }

    final genericMatch = RegExp(r'^(vector|option)<(.+)>$').firstMatch(name);
    if (genericMatch != null) {
      final kind = genericMatch.group(1)!;
      final inner = genericMatch.group(2)!;

      final innerSchema = pureBcsSchemaFromTypeName(inner);
      if (kind == 'vector') {
        return Bcs.vector(innerSchema);
      } else {
        return Bcs.option(innerSchema);
      }
    }

    throw ArgumentError('Invalid Pure type name: $name');
  }
}
