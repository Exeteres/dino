class ModuleInfo {
  ModuleInfo(
    this.name,
    this.version,
    this.description,
    this._properties,
  );

  final String name;
  final String version;
  final String description;

  final Map<String, Object> _properties;

  Object? operator [](String name) => _properties[name];
}
