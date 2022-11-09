import 'package:dino/dino.dart';
import 'package:dino_extensions/src/modularity/module_builder.dart';
import 'package:dino_extensions/src/modularity/module_info.dart';

/// The base class for all modules.
abstract class Module<TBuilder extends ModuleBuilder> {
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

  /// Creates a new instance of the module builder.
  ///
  /// This method must be overridden if the custom [TBuilder] type is provided.
  TBuilder createBuilder(ServiceCollection services) {
    if (TBuilder == dynamic || TBuilder == ModuleBuilder) {
      return ModuleBuilder(services) as TBuilder;
    }

    throw UnsupportedError(
      'Override the createBuilder method to '
      'return a custom builder for this module',
    );
  }

  static String _normalizeModuleName(String name) {
    if (name.endsWith('Module')) {
      return name.substring(0, name.length - 6);
    }

    return name;
  }
}
