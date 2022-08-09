import 'dart:async';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'package:dino_generator/src/generator_composition_root.dart';

class DinoGenerator implements Generator {
  final _compositionRoot = GeneratorCompositionRoot();

  @override
  String toString() {
    return 'Dino Generator';
  }

  @override
  Future<String?> generate(LibraryReader library, BuildStep buildStep) {
    return _compositionRoot.process(library.element, buildStep.resolver);
  }
}
