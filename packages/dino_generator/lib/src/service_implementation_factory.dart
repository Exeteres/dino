import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';

import 'package:dino_generator/src/utils.dart';

enum DependencyKind { single, iterable, list }

class ImplementationDependency {
  ImplementationDependency(this.kind, this.reference);

  final DependencyKind kind;
  final Reference reference;
}

class ServiceImplementation {
  ServiceImplementation(
    this.serviceType,
    this.dependencies,
    this.aliases,
  );

  final Reference serviceType;
  final List<ImplementationDependency> dependencies;
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

    final dependencies = <ImplementationDependency>[];

    for (var parameter in constructor.parameters) {
      var kind = DependencyKind.single;
      var type = parameter.type;

      if (type is InterfaceType) {
        if (type.isDartCoreList) {
          kind = DependencyKind.list;
          type = type.typeArguments[0];
        } else if (type.isDartCoreIterable) {
          kind = DependencyKind.iterable;
          type = type.typeArguments[0];
        }
      }

      final reference = TypeReference((b) => b
        ..isNullable = type.nullabilitySuffix == NullabilitySuffix.question
        ..symbol = type.getDisplayString(withNullability: false)
        ..url = type.element!.librarySource!.uri.toString());

      dependencies.add(ImplementationDependency(kind, reference));
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

      final classElement = supertype.element;

      if (classElement is! ClassElement) {
        continue;
      }

      if (!classElement.isAbstract) {
        continue;
      }

      final supertypeElement = supertype.element;

      yield referElement(supertypeElement);
    }
  }
}
