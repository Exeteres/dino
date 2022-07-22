import 'package:dino/src/collection/service_descriptor.dart';

/// A collection of service descriptors.
abstract class ServiceCollection implements List<ServiceDescriptor> {
  /// Registers a service of the specified type with specified [lifetime].
  /// Service must have a single accessible constructor.
  ///
  /// It's implementation will be created automatically by the dino generator.
  ///
  /// This method also gets optional [registerAliases] parameter
  /// indicating whether aliases for all service interfaces
  /// should be registered or not.
  void addGenerated<TService extends Object>(
    ServiceLifetime lifetime, [
    bool registerAliases = true,
  ]);
}
