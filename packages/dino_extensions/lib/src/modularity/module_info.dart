/// Represents the information about a module.
class ModuleInfo {
  ModuleInfo(
    this.name,
    this.version,
    this.description,
    this._properties,
  );

  /// The name of the module.
  final String name;

  /// The version of the module.
  final String version;

  /// The description of the module.
  final String description;

  final Map<String, Object> _properties;

  /// Gets the value of the user-defined property with the specified name.
  Object? operator [](String name) => _properties[name];
}
