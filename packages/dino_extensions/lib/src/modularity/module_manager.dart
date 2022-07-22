import 'package:dino_extensions/src/modularity/module_info.dart';

abstract class ModuleManager {
  Iterable<ModuleInfo> get modules;
}
