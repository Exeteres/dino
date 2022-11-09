/// A service that manages application options.
abstract class OptionsManager {
  /// Gets an options instance of the specified type.
  /// Optionally, you can specify a [name] to get a named options instance.
  ///
  /// Returns `null` if no options instance
  /// configured for the specified type and name.
  TOptions? get<TOptions extends Object>([String name = '']);
}
