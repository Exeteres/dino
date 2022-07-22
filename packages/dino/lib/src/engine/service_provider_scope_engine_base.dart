import 'package:dino/src/collection/service_descriptor.dart';
import 'package:dino/src/provider/service_provider.dart';
import 'package:dino/src/provider/service_scope.dart';

/// This is an internal API that is not intended for use by developers.
///
/// It may be changed or removed without notice.
abstract class ServiceProviderScopeEngineBase
    implements ServiceProvider, ServiceScope {
  ServiceProviderScopeEngineBase(this.serviceMap);
  final Map<Type, List<ServiceDescriptor>> serviceMap;

  final Map<ServiceDescriptor, Object> _createdServices = {};

  @override
  Iterable<Object> getServiceIterable(
    Type serviceType, [
    bool sameLifetime = false,
  ]) sync* {
    if (serviceType == ServiceProvider) {
      yield this;
      return;
    }

    final descriptors = serviceMap[serviceType];
    if (descriptors == null) return;

    for (var descriptor in descriptors) {
      if (descriptor.implementationAlias != null) {
        yield* getServiceIterable(
          descriptor.implementationAlias!,
          sameLifetime,
        );

        continue;
      }

      if (sameLifetime && descriptor.lifetime != scopeLifetime) {
        continue;
      }

      yield resolveService(descriptor);
    }
  }

  @override
  ServiceProvider get serviceProvider => this;

  @override
  Iterable<Object> get createdServices => _createdServices.values;

  ServiceLifetime get scopeLifetime;

  Object resolveService(ServiceDescriptor descriptor);

  Object createInstance(ServiceDescriptor descriptor) {
    assert(descriptor.implementationAlias == null, 'Unexpected alias');

    if (descriptor.implementationFactory != null) {
      return descriptor.implementationFactory!(this);
    }

    return descriptor.implementationInstance!;
  }

  Object getServiceByDescriptor(ServiceDescriptor descriptor) {
    final resolvedInstance = _createdServices[descriptor];

    if (resolvedInstance != null) {
      return resolvedInstance;
    }

    final instance = createInstance(descriptor);

    _createdServices[descriptor] = instance;

    return instance;
  }
}
