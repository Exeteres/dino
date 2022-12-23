import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';

import 'package:dino_generator/src/utils.dart';

/// This is an internal API that is not intended for use by developers.
///
/// It may be changed or removed without notice.
enum DependencyKind { single, iterable, list }

/// This is an internal API that is not intended for use by developers.
///
/// It may be changed or removed without notice.
class ImplementationDependency {
  ImplementationDependency(this.kind, this.reference);

  final DependencyKind kind;
  final Reference reference;
}

/// This is an internal API that is not intended for use by developers.
///
/// It may be changed or removed without notice.
///
/// Service implementation contains an information about the implementation of
/// the service of the specified type.
///
/// Besides the type of the service, it also contains a list of dependencies
/// that will be resolved from the service provider in the generated factory
/// function.
///
/// It also contains a list of aliases that will be automatically
/// registered in the service collection.
class ServiceImplementation {
  ServiceImplementation(
    this.serviceType,
    this.dependencies,
    this.namedDependencies,
    this.aliases,
  );

  final Reference serviceType;
  final List<ImplementationDependency> dependencies;
  final Map<String, ImplementationDependency> namedDependencies;
  final List<Reference> aliases;
}

class ServiceImplementationFactory {
  final Map<ClassElement, ServiceImplementation> _implementations = {};

  ServiceImplementation create(ClassElement element) {
    final existingImplementation = _implementations[element];

    if (existingImplementation != null) {
      return existingImplementation;
    }

    final constructor = element.unnamedConstructor;

    if (constructor == null || !constructor.isPublic) {
      throw Exception(
        'No public constructor found for type ${element.displayName}',
      );
    }

    final dependencies = <ImplementationDependency>[];
    final namedDependencies = <String, ImplementationDependency>{};

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
        ..url = type.element?.librarySource!.uri.toString());

      final dependency = ImplementationDependency(kind, reference);

      if (parameter.isNamed) {
        namedDependencies[parameter.name] = dependency;
      } else {
        dependencies.add(dependency);
      }
    }

    final serviceType = referElement(element);
    final aliases = _createAliases(element).toList();

    final implementation = ServiceImplementation(
      serviceType,
      dependencies,
      namedDependencies,
      aliases,
    );

    _implementations[element] = implementation;

    return implementation;
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
