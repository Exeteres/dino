import 'package:dino/src/provider/service_provider.dart';

/// Represents a scope of services.
abstract class ServiceScope {
  /// An instance of [ServiceProvider] that provides services for this scope.
  ServiceProvider get serviceProvider;

  /// An iterable of all services created inside this scope.
  ///
  /// If this scope is a root scope,
  /// this iterable will contain singleton services.
  Iterable<Object> get createdServices;
}
