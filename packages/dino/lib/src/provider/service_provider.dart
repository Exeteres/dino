/// Defines a mechanism for retrieving services.
abstract class ServiceProvider {
  /// Returns an iterable of all services of specified type.
  ///
  /// Services will be lazily resolved while iteration.
  /// It means that new transient services will be created on each iteration.
  ///
  /// This method is not intended to be used by the application.
  /// You should use extension methods like [get] instead.
  ///
  /// If [sameLifetime] is `true`:
  /// - in root scope only singleton services will be returned;
  /// - in all other scopes only scoped services will be returned.
  Iterable<Object> getServiceIterable(
    Type serviceType, [
    bool sameLifetime = false,
  ]);
}
