import 'package:dino/dino.dart';
import 'package:dino_extensions/src/modularity/module_manager_impl.dart';

import 'package:dino_extensions/src/modularity/module_manager.dart';

/// This is an internal API that is not intended for use by developers.
///
/// It may be changed or removed without notice.
abstract class ModuleRegistrationHelper {
  static ModuleManagerImpl getModuleManager(ServiceCollection services) {
    ServiceDescriptor? descriptor;

    for (final service in services) {
      if (service.serviceType == ModuleManager) {
        descriptor = service;
        break;
      }
    }

    if (descriptor == null) {
      final moduleManager = ModuleManagerImpl();

      services.addInstance<ModuleManager>(moduleManager);

      return moduleManager;
    }

    if (descriptor.implementationInstance is ModuleManagerImpl) {
      return descriptor.implementationInstance as ModuleManagerImpl;
    }

    throw Exception(
      'ModuleManager is already registered with a different implementation',
    );
  }
}
