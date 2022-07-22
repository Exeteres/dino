/// Represents a service that need some asynchronous work for initialization.
abstract class Initializable {
  /// Initializes the service.
  Future<void> initialize();
}

/// Represents a service that need some asynchronous work for disposal.
abstract class Disposable {
  /// Disposes the service.
  Future<void> dispose();
}
