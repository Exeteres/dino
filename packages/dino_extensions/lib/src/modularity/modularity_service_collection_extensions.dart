import 'package:dino/dino.dart';
import 'package:dino_extensions/src/modularity/module.dart';
import 'package:dino_extensions/src/modularity/module_builder.dart';
import 'package:dino_extensions/src/modularity/module_registration_helper.dart';

extension ModularityServiceCollectionExtensions on ServiceCollection {
  void addModule<TModuleBuilder extends ModuleBuilder>(
    Module<TModuleBuilder> module, [
    void Function(TModuleBuilder builder)? configureAction,
  ]) {
    final moduleManager = ModuleRegistrationHelper.getModuleManager(this);

    moduleManager.addModule(this, module);

    configureAction?.call(module.createBuilder(this));
  }
}
