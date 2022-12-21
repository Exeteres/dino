import 'package:dino/dino.dart';
import 'package:dino_extensions/src/modularity/module.dart';
import 'package:dino_extensions/src/modularity/module_registration_helper.dart';

extension ModularityServiceCollectionExtensions on ServiceCollection {
  /// Adds a module to the service collection.
  ///
  /// This method will call the [Module.configureServices] method to add
  /// module-specific services to the collection.
  /// This method will be called only once for each module.
  ///
  /// This method also will call the [Module.configureInstanceServices] method
  /// to add module instance-specific services to the collection.
  /// This method will be called every time when a new instance of the module
  /// is created and passed to this method.
  void addModule(Module module) {
    final moduleManager = ModuleRegistrationHelper.getModuleManager(this);

    moduleManager.addModule(this, module);
  }
}
