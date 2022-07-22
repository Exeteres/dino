import 'package:dino/dino.dart';
import 'package:dino_extensions/src/modularity/module_builder.dart';
import 'package:dino_extensions/src/modularity/module_info.dart';

abstract class Module<TBuilder extends ModuleBuilder> {
  String get name => _normalizeModuleName(runtimeType.toString());
  String get version => '1.0.0';
  String get description => '';

  Map<String, Object> get properties => {};

  ModuleInfo createInfo() {
    return ModuleInfo(
      name,
      version,
      description,
      properties,
    );
  }

  void configureServices(ServiceCollection services) {}

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
