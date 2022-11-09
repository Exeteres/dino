import 'package:dino_extensions/src/options/options_manager.dart';

extension OptionsManagerExtensions on OptionsManager {
  /// Gets the options with of the specified type.
  /// Optionally, a name can be specified to get a named options.
  ///
  /// Throws an exception if the options is not defined.
  TOptions getRequired<TOptions extends Object>([String name = '']) {
    final options = get<TOptions>(name);

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
