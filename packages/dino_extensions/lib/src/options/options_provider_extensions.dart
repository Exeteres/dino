import 'package:dino_extensions/src/options/options_provider.dart';

extension OptionsProviderExtensions<TOptions extends Object>
    on OptionsProvider<TOptions> {
  TOptions getRequired([String name = '']) {
    final options = get(name);

    if (options == null) {
      if (name == '') {
        throw Exception(
          'Options of type $TOptions was not configured',
        );
      }

      throw Exception(
        'Options of type $TOptions with name "$name" was not configured',
      );
    }

    return options;
  }
}
