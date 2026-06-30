// ignore_for_file: constant_identifier_names
import 'package:sui_dart/types/common.dart';
import 'package:sui_dart/types/objects.dart';

class FaucetCoinInfo {
  final int amount;
  final ObjectId id;
  final TransactionDigest transferTxDigest;

  FaucetCoinInfo(this.amount, this.id, this.transferTxDigest);

  factory FaucetCoinInfo.fromJson(dynamic data) {
    return FaucetCoinInfo(data['amount'], data['id'], data['transferTxDigest']);
  }
}

/// Response from `/v2/gas`. [status] is `'Success'` or a `{Failure: {internal}}` map.
class FaucetResponseV2 {
  final dynamic status;
  final List<FaucetCoinInfo>? coinsSent;

  FaucetResponseV2(this.status, this.coinsSent);

  bool get isSuccess => status == 'Success';

  String? get failureInternal {
    if (status is Map && status['Failure'] != null) {
      return status['Failure']['internal']?.toString();
    }
    return null;
  }

  factory FaucetResponseV2.fromJson(dynamic data) {
    final sent = data['coins_sent'];
    return FaucetResponseV2(
      data['status'],
      sent == null
          ? null
          : (sent as List).map((x) => FaucetCoinInfo.fromJson(x)).toList(),
    );
  }
}

class FaucetResponse {
  final List<FaucetCoinInfo> transferredGasObjects;
  final String? error;

  FaucetResponse(this.transferredGasObjects, this.error);

  factory FaucetResponse.fromJson(dynamic data) {
    final gasObjects = (data['transferredGasObjects'] as List)
        .map((x) => FaucetCoinInfo.fromJson(x))
        .toList();

    return FaucetResponse(gasObjects, data['error']);
  }
}

class BatchFaucetResponse {
  final String? task;
  final String? error;

  BatchFaucetResponse(this.task, this.error);

  factory BatchFaucetResponse.fromJson(dynamic data) {
    return BatchFaucetResponse(data['task'], data['error']);
  }
}

enum BatchSendStatus { INPROGRESS, SUCCEEDED, DISCARDED }

class BatchSendStatusType {
  BatchSendStatus status;
  List<FaucetCoinInfo>? gasObjects;

  BatchSendStatusType(this.status, this.gasObjects);

  factory BatchSendStatusType.fromJson(dynamic data) {
    var gasObjects = data['transferred_gas_objects'];
    if (gasObjects != null) {
      gasObjects = (gasObjects["sent"] as List)
          .map((x) => FaucetCoinInfo.fromJson(x))
          .toList();
    }

    return BatchSendStatusType(
      BatchSendStatus.values.byName(data['status']),
      gasObjects,
    );
  }
}

class BatchStatusFaucetResponse {
  BatchSendStatusType status;
  final String? error;

  BatchStatusFaucetResponse(this.status, this.error);

  factory BatchStatusFaucetResponse.fromJson(dynamic data) {
    return BatchStatusFaucetResponse(
      BatchSendStatusType.fromJson(data['status']),
      data['error'],
    );
  }
}
