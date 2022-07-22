import 'package:dino/src/collection/service_descriptor.dart';
import 'package:dino/src/engine/service_provider_root_scope_engine.dart';
import 'package:dino/src/engine/service_provider_scope_engine_base.dart';

/// This is an internal API that is not intended for use by developers.
///
/// It may be changed or removed without notice.
class ServiceProviderScopeEngine extends ServiceProviderScopeEngineBase {
  ServiceProviderScopeEngine(this._rootScopeEngine)
      : super(_rootScopeEngine.serviceMap);

  final ServiceProviderRootScopeEngine _rootScopeEngine;

  @override
  ServiceLifetime get scopeLifetime => ServiceLifetime.scoped;

  @override
  Object resolveService(ServiceDescriptor descriptor) {
    switch (descriptor.lifetime) {
      case ServiceLifetime.singleton:
        return _rootScopeEngine.resolveService(descriptor);
      case ServiceLifetime.scoped:
        return getServiceByDescriptor(descriptor);
      case ServiceLifetime.transient:
        return createInstance(descriptor);
    }
  }
}
