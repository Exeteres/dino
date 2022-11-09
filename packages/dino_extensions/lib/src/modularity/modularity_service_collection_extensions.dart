import 'package:dino/dino.dart';
import 'package:dino_extensions/src/modularity/module.dart';
import 'package:dino_extensions/src/modularity/module_builder.dart';
import 'package:dino_extensions/src/modularity/module_registration_helper.dart';

extension ModularityServiceCollectionExtensions on ServiceCollection {
  /// Adds a module to the service collection.
  ///
  /// This method will call the [Module.configureServices] method to add
  /// module-specific services to the collection.
  ///
  /// Repeated calls of this method with module instances
  /// of the same type will be ignored.
  ///
  /// If [configureAction] is provided,
  /// it always will be called for a newly created module builder.
  void addModule<TModuleBuilder extends ModuleBuilder>(
    Module<TModuleBuilder> module, [
    void Function(TModuleBuilder builder)? configureAction,
  ]) {
    final moduleManager = ModuleRegistrationHelper.getModuleManager(this);

    moduleManager.addModule(this, module);

    configureAction?.call(module.createBuilder(this));
  }
}
