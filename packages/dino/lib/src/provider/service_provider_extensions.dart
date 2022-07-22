import 'package:dino/src/provider/service_provider.dart';
import 'package:dino/src/provider/service_scope.dart';
import 'package:dino/src/provider/service_scope_factory.dart';

extension ServiceProviderExtensions on ServiceProvider {
  /// Gets a service of the specified type.
  /// Returns null if no service of the specified type is registered.
  Object? getService(Type serviceType) {
    for (final element in getServiceIterable(serviceType)) {
      return element;
    }

    return null;
  }

  /// Returns a permanent list of services of specified type.
  List<Object> getServices(Type serviceType) {
    return getServiceIterable(serviceType).toList();
  }

  /// Gets a service of the specified type.
  /// Throws an exception if no service of the specified type is registered.
  Object getRequiredService(Type serviceType) {
    for (final element in getServiceIterable(serviceType)) {
      return element;
    }

    throw Exception('No service registered for type $serviceType');
  }

  /// Gets a service of the specified type
  /// Returns null if no service of the specified type is registered.
  TService? get<TService>() {
    return getService(TService) as TService?;
  }

  /// Gets a service of the specified type.
  /// Throws an exception if no service of the specified type is registered.
  TService getRequired<TService>() {
    final service = get<TService>();

    if (service == null) {
      throw Exception('No service registered for type $TService');
    }

    return service;
  }

  /// Returns a permanent list of services of specified type.
  List<TService> getMany<TService>() {
    return getServiceIterable(TService).cast<TService>().toList();
  }

  /// Creates a new [ServiceScope].
  ServiceScope createScope() {
    return getRequired<ServiceScopeFactory>().createScope();
  }
}
