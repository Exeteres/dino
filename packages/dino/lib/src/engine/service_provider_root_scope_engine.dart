import 'package:dino/src/collection/service_descriptor.dart';
import 'package:dino/src/engine/service_provider_scope_engine_base.dart';

/// This is an internal API that is not intended for use by developers.
///
/// It may be changed or removed without notice.
class ServiceProviderRootScopeEngine extends ServiceProviderScopeEngineBase {
  ServiceProviderRootScopeEngine(super.serviceMap);

  @override
  ServiceLifetime get scopeLifetime => ServiceLifetime.singleton;

  @override
  Object resolveService(ServiceDescriptor descriptor) {
    switch (descriptor.lifetime) {
      case ServiceLifetime.singleton:
        return getServiceByDescriptor(descriptor);
      case ServiceLifetime.scoped:
        throw Exception('Scoped services cannot be resolved in root scope');
      case ServiceLifetime.transient:
        return createInstance(descriptor);
    }
  }
}
