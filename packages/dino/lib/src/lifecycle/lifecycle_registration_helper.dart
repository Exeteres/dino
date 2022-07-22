import 'package:dino/src/collection/service_collection.dart';
import 'package:dino/src/collection/service_collection_extensions.dart';
import 'package:dino/src/lifecycle/lifecycle_manager.dart';
import 'package:dino/src/lifecycle/lifecycle_manager_impl.dart';

/// This is an internal API that is not intended for use by developers.
///
/// It may be changed or removed without notice.
abstract class LifecycleRegistrationHelper {
  static void addLifecycleManager(ServiceCollection services) {
    services.addSingletonFactory((sp) => LifecycleManagerImpl());
    services.addScopedFactory((sp) => LifecycleManagerImpl());

    services.addTransientFactory<LifecycleManager>(
      (sp) => sp
          .getServiceIterable(LifecycleManagerImpl, true)
          .cast<LifecycleManager>()
          .first,
    );
  }
}
