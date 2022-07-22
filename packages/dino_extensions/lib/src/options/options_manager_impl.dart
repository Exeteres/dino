import 'package:dino/dino.dart';
import 'package:dino_extensions/src/options/options_manager.dart';

typedef OptionsFactory<TOptions> = TOptions Function(ServiceProvider provider);

typedef OptionsConfigurationAction<TOptions extends Object> = void Function(
  ServiceProvider provider,
  TOptions options,
);

class OptionsConfigurationHandler<TOptions extends Object> {
  OptionsConfigurationHandler(this.name, this.action);

  final String name;
  final OptionsConfigurationAction<TOptions> action;
}

/// This is an internal API that is not intended for use by developers.
///
/// It may be changed or removed without notice.
class OptionsManagerImpl implements OptionsManager {
  OptionsManagerImpl(this._serviceProvider);
  final ServiceProvider _serviceProvider;

  final Map<Type, Map<String, Object?>> _optionsMap =
      <Type, Map<String, Object?>>{};

  @override
  TOptions? get<TOptions extends Object>([String name = '']) {
    var map = _optionsMap[TOptions];

    if (map == null) {
      map = <String, Object?>{};
      _optionsMap[TOptions] = map;
    }

    if (map.containsKey(name)) {
      return map[name] as TOptions;
    }

    final factory = _serviceProvider.get<OptionsFactory<TOptions>>();

    if (factory == null) {
      throw Exception('Options of type $TOptions is not defined');
    }

    final handlers =
        _serviceProvider.getMany<OptionsConfigurationHandler<TOptions>>();

    final options = factory(_serviceProvider);

    for (final handler in handlers) {
      if (handler.name == name) {
        handler.action(_serviceProvider, options);
      }
    }

    map[name] = options;

    return options;
  }
}
