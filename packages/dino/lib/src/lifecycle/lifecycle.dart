import 'dart:async';

/// Represents a service that need some asynchronous work for initialization.
abstract interface class Initializable {
  /// Initializes the service.
  FutureOr<void> initialize();
}

/// Represents a service that need some asynchronous work for disposal.
abstract interface class Disposable {
  /// Disposes the service.
  FutureOr<void> dispose();
}
