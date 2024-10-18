import 'package:build/build.dart';
import 'package:dino_generator/src/dino_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder dinoBuilder(BuilderOptions options) {
  return SharedPartBuilder(
    [DinoGenerator()],
    'dino',
  );
}
