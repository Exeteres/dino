import 'package:dino/src/collection/service_collection.dart';
import 'package:dino/src/collection/service_descriptor.dart';
import 'package:dino/src/engine/service_provider_root_scope_engine.dart';
import 'package:dino/src/provider/service_scope.dart';
import 'package:dino/src/provider/service_scope_factory.dart';
import 'package:dino/src/engine/service_scope_factory_impl.dart';

extension ServiceCollectionExtensions on ServiceCollection {
  /// Registers a singleton service of the specified [TService] type
  /// using the specified [instance].
  void addInstance<TService extends Object>(TService instance) {
    add(ServiceDescriptor.instance<TService>(instance));
  }

  /// Registers a service with specified [lifetime]
  /// of the specified [TService] type
  /// implemented by the specified [factory].
  void addFactory<TService extends Object>(
    ServiceLifetime lifetime,
    ServiceFactory<TService> factory, [
    bool isGenerated = false,
  ]) {
    add(ServiceDescriptor.factory<TService>(lifetime, factory, isGenerated));
  }

  /// Registers a singleton service of the specified [TService] type
  /// implemented by the specified [factory].
  void addSingletonFactory<TService extends Object>(
    ServiceFactory<TService> factory,
  ) {
    addFactory(ServiceLifetime.singleton, factory);
  }

  /// Registers a scoped service of the specified [TService] type
  /// implemented by the specified [factory].
  void addScopedFactory<TService extends Object>(
    ServiceFactory<TService> factory,
  ) {
    addFactory(ServiceLifetime.scoped, factory);
  }

  /// Registers a transient service of the specified [TService] type
  /// implemented by the specified [factory].
  void addTransientFactory<TService extends Object>(
    ServiceFactory<TService> factory,
  ) {
    addFactory(ServiceLifetime.transient, factory);
  }

  /// Registers a transient service of the specified [TService] type
  /// implemented as an alias for the specified [TImplementation] type.
  /// [TImplementation] must implement [TService].
  void addAlias<TService extends Object, TImplementation extends TService>([
    bool isGenerated = false,
  ]) {
    add(ServiceDescriptor.alias<TService, TImplementation>(isGenerated));
  }

  bool containsService<TService extends Object>() {
    for (final descriptor in this) {
      if (descriptor.serviceType == TService) {
        return true;
      }
    }

    return false;
  }

  /// Builds a root [ServiceScope].
  ServiceScope buildRootScope() {
    final serviceMap = <Type, List<ServiceDescriptor>>{};

    for (var descriptor in this) {
      var descriptors = serviceMap[descriptor.serviceType];

      if (descriptors == null) {
        descriptors = [];
        serviceMap[descriptor.serviceType] = descriptors;
      }

      descriptors.add(descriptor);
    }

    final rootScope = ServiceProviderRootScopeEngine(serviceMap);

    serviceMap[ServiceScopeFactory] = [
      ServiceDescriptor.instance(ServiceScopeFactoryImpl(rootScope)),
    ];

    return rootScope;
  }
}
