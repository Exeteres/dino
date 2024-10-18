import 'dart:async';

/// A scoped service that manages lifecyle operations on services.
/// Use it to create a valid order of lifecycle operations beetwen dependencies.
abstract interface class LifecycleManager {
  /// Proccesses an operation on a service if it have not already been processed.
  Future<void> process<TService extends Object>(
    TService service,
    FutureOr<void> Function(TService) operation,
  );
}
