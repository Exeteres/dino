import 'package:dino/src/engine/service_provider_root_scope_engine.dart';
import 'package:dino/src/engine/service_provider_scope_engine.dart';
import 'package:dino/src/provider/service_scope.dart';
import 'package:dino/src/provider/service_scope_factory.dart';

/// This is an internal API that is not intended for use by developers.
///
/// It may be changed or removed without notice.
class ServiceScopeFactoryImpl implements ServiceScopeFactory {
  ServiceScopeFactoryImpl(this._rootScopeEngine);
  final ServiceProviderRootScopeEngine _rootScopeEngine;

  @override
  ServiceScope createScope() {
    return ServiceProviderScopeEngine(_rootScopeEngine);
  }
}
