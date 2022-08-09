import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:code_builder/code_builder.dart';

import 'package:dino_generator/src/utils.dart';

class ServiceImplementation {
  ServiceImplementation(
    this.serviceType,
    this.dependencies,
    this.aliases,
  );

  final Reference serviceType;
  final List<Reference> dependencies;
  final List<Reference> aliases;
}

class ServiceImplementationFactory {
  ServiceImplementation create(ClassElement element) {
    final constructor = element.unnamedConstructor;

    if (constructor == null || !constructor.isPublic) {
      throw Exception(
        'No public constructor found for type ${element.displayName}',
      );
    }

    final dependencies = <Reference>[];

    for (var parameter in constructor.parameters) {
      final type = parameter.type;

      final dependency = TypeReference((b) => b
        ..isNullable = type.nullabilitySuffix == NullabilitySuffix.question
        ..symbol = type.getDisplayString(withNullability: false)
        ..url = type.element!.librarySource!.uri.toString());

      dependencies.add(dependency);
    }

    final serviceType = referElement(element);
    final aliases = _createAliases(element).toList();

    return ServiceImplementation(
      serviceType,
      dependencies,
      aliases,
    );
  }

  Iterable<Reference> _createAliases(ClassElement element) sync* {
    for (var supertype in element.allSupertypes) {
      if (supertype.isDartCoreObject) {
        continue;
      }

      if (!supertype.element.isAbstract) {
        continue;
      }

      final supertypeElement = supertype.element;

      yield referElement(supertypeElement);
    }
  }
}
