import 'package:dino/dino.dart';
import 'package:dino_extensions/src/modularity/module_info.dart';

/// The base class for all modules.
abstract class Module {
  /// The name of the module.
  ///
  /// It will be passed to the [ModuleInfo] object.
  String get name => _normalizeModuleName(runtimeType.toString());

  /// The version of the module.
  ///
  /// It will be passed to the [ModuleInfo] object.
  String get version => '1.0.0';

  /// The description of the module.
  ///
  /// It will be passed to the [ModuleInfo] object.
  String get description => '';

  /// The map of user-defined properties of the module.
  ///
  /// It will be passed to the [ModuleInfo] object.
  Map<String, Object> get properties => {};

  /// Creates a new instance of the [ModuleInfo].
  ///
  /// Can be overridden to provide custom [ModuleInfo] instance.
  ModuleInfo createInfo() {
    return ModuleInfo(
      name,
      version,
      description,
      properties,
    );
  }

  /// Configures the service collection with module-specific services.
  ///
  /// It will be called when module is added to the collection only once.
  void configureServices(ServiceCollection services) {}

  /// Configures the service collection with module instance-specific services.
  ///
  /// Unlike [configureServices], this method will be called every time
  /// when a new instance of the module is created and passed to the
  /// [ServiceCollection.addModule] method.
  void configureInstanceServices(ServiceCollection services) {}

  /// The same as [configureServices] but this method is used for
  /// some configuration actions that should be performed by base classes
  /// rather than by the module itself.
  ///
  /// This method will be called before [configureServices].
  void onServiceConfiguration(ServiceCollection services) {}

  /// The same as [configureInstanceServices] but this method is used for
  /// some configuration actions that should be performed by base classes
  /// rather than by the module itself.
  ///
  /// This method will be called before [configureInstanceServices].
  void onInstanceServiceConfiguration(ServiceCollection services) {}

  static String _normalizeModuleName(String name) {
    if (name.endsWith('Module')) {
      return name.substring(0, name.length - 6);
    }

    return name;
  }
}
