import 'package:sui_dart/grpc/types.dart' show ExecutionError;

class FaucetRateLimitError extends Error {}

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
