import 'package:dino/dino.dart';

/// The base class for all module builders.
class ModuleBuilder {
  ModuleBuilder(this.services);

  /// The service collection that can be used to configure services.
  final ServiceCollection services;
}
