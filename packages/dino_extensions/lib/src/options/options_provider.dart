/// A service that provides options instances of the specified type.
abstract class OptionsProvider<TOptions extends Object> {
  /// Gets an options instance of the specified type.
  /// Optionally, you can specify a [name] to get a named options instance.
  ///
  /// Returns `null` if no options instance
  /// configured for the specified type and name.
  TOptions? get([String name = '']);
}
