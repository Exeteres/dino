import 'package:dino_extensions/src/modularity/module_info.dart';

/// The service that can be used to get information about added modules.
abstract class ModuleManager {
  /// The iterable of [ModuleInfo] objects of all added modules.
  Iterable<ModuleInfo> get modules;
}
