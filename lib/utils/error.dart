import 'package:sui_dart/grpc/types.dart' show ExecutionError;

class FaucetRateLimitError extends Error {}

/// Check [digest] before retrying: the payout may already be on chain.
class FaucetError implements Exception {
  FaucetError(this.message, {required this.status, this.code, this.digest});

  final String message;
  final int status;
  final String? code;
  final String? digest;

  @override
  String toString() => 'FaucetError($status): $message';
}

/// A transaction failed to resolve. [executionError] is set when the node ran
/// it and it aborted; [cause] is the transport error otherwise.
class SimulationError implements Exception {
  SimulationError(this.message, {this.executionError, this.cause});

  final String message;
  final ExecutionError? executionError;
  final Object? cause;

  @override
  String toString() => 'SimulationError: $message';
}
