import 'package:build/build.dart';
import 'package:dino_generator/src/generator_composition_root.dart';
import 'package:source_gen/source_gen.dart';

class DinoGenerator extends Generator {
  final _compositionRoot = GeneratorCompositionRoot();

  @override
  String toString() {
    return 'Dino Generator';
  }

  @override
  String? generate(LibraryReader library, BuildStep buildStep) {
    return _compositionRoot.process(library);
  }
}
