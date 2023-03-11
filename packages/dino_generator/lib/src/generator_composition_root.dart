import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dino/dino.dart';
import 'package:dino_generator/src/service_collection_emitter.dart';
import 'package:dino_generator/src/service_implementation_factory.dart';
import 'package:source_gen/source_gen.dart';

/// This is an internal API that is not intended for use by developers.
///
/// It may be changed or removed without notice.
class GeneratorCompositionRoot {
  final _dartEmitter = DartEmitter();
  final _emitter = ServiceCollectionEmitter();
  final _impFactory = ServiceImplementationFactory();
  final _annotation = TypeChecker.fromRuntime(Service);

  String? process(LibraryReader library) {
    final result = StringBuffer();

    for (final annotated in library.annotatedWith(_annotation)) {
      final classElement = annotated.element;

      if (classElement is! ClassElement) {
        throw InvalidGenerationSourceError(
          'The @service annotation can only be used on classes.',
          element: annotated.element,
        );
      }

      final lifetime = getLifetime(annotated.annotation);

      final implementation = _impFactory.create(classElement, lifetime);
      final code = _emitter.emit(implementation);

      result.writeln(code.accept(_dartEmitter));
    }

    return result.isNotEmpty ? result.toString() : null;
  }
}

Reference? getLifetime(ConstantReader annotation) {
  final lifetimeValue = annotation.read('lifetime');

  final lifetimeString = lifetimeValue.isNull
      ? null
      : lifetimeValue.objectValue.getField('_name')?.toStringValue();

  return lifetimeString == null
      ? null
      : refer('ServiceLifetime.${lifetimeString}');
}
