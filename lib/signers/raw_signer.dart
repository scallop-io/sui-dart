// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:typed_data';

import 'package:sui_dart/cryptography/keypair.dart';
import 'package:sui_dart/signers/signer_with_provider.dart';
import 'package:sui_dart/sui_account.dart';
import 'package:sui_dart/types/common.dart';

@Deprecated('JSON-RPC is being sunset (~July 2026); use SuiGrpcClient.')
class RawSigner extends SignerWithProvider {
  late final Keypair _keypair;

  RawSigner(Keypair keypair, {String? endpoint, super.serializer})
    : super(endpoint: endpoint ?? '') {
    _keypair = keypair;
  }

  @override
  void setSigner(SuiAccount signer) {
    _keypair = signer.keyPair;
  }

  @override
  SuiAddress getAddress() {
    return _keypair.getPublicKey().toSuiAddress();
  }

  @override
  SignaturePubkeyPair signData(Uint8List data) {
    return SignaturePubkeyPair(
      _keypair.getKeyScheme(),
      _keypair.signData(data),
      pubKey: _keypair.getPublicKey(),
    );
  }

  bool verify(Uint8List data, SignaturePubkeyPair signature) {
    bool success = _keypair.verify(
      data,
      signature.signature,
      signature.pubKey!.toRawBytes(),
    );
    return success;
  }
}
