import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dino_generator/src/service_implementation_factory.dart';
import 'package:dino_generator/src/service_implementation_location_visitor.dart';
import 'package:dino_generator/src/utils.dart';

import 'package:analyzer/src/dart/element/element.dart';

class ServiceImplementationDefinition {
  ServiceImplementationDefinition(this.typeArgumentIndex);
  final int typeArgumentIndex;
}

class ImplementationProvider {
  ImplementationProvider(
    this.definitions,
    this.staticImplementations,
    this.children,
    this.registerAliases,
  );

  final List<ServiceImplementationDefinition> definitions;
  final List<ServiceImplementation> staticImplementations;
  final List<ImplementationProvider> children;
  final bool registerAliases;
}

class ImplementationProviderLocator {
  ImplementationProviderLocator(this._implementationFactory, this._resolver);

  final ServiceImplementationFactory _implementationFactory;
  final Resolver _resolver;

  final HashMap<ExecutableElement, ImplementationProvider?>
      _implementationProviders = HashMap();

  Future<ImplementationProvider?> resolve(
    ExecutableElement executableElement, [
    Element? scSymbol,
  ]) async {
    if (_implementationProviders.containsKey(executableElement)) {
      return _implementationProviders[executableElement];
    }

    _implementationProviders[executableElement] =
        await _locate(executableElement, scSymbol);

    return _implementationProviders[executableElement];
  }

  Future<ImplementationProvider?> _locate(
    ExecutableElement executableElement,
    Element? scSymbol,
  ) async {
    final node = await getElementDeclarationNode(executableElement, _resolver);

    if (node == null) {
      return null;
    }

    if (scSymbol == null) {
      scSymbol = _locateServiceCollectionSymbol(executableElement);

      if (scSymbol == null) {
        throw Exception(
          'Could not find service collection symbol '
          'for ${executableElement.name}',
        );
      }
    }

    final visitor = ServiceImplementationLocationVisitor(scSymbol);

    node.accept(visitor);

    if (visitor.locatedInvocations.isEmpty) {
      return null;
    }

    return await _create(executableElement, visitor.locatedInvocations);
  }

  Future<ImplementationProvider> _create(
    ExecutableElement executableElement,
    List<Expression> invocations,
  ) async {
    final children = <ImplementationProvider>[];
    final implementations = <ServiceImplementation>[];
    final definitions = <ServiceImplementationDefinition>[];

    for (final invocation in invocations) {
      final childExecutableElement = getInvocationExecutableElement(invocation);

      if (childExecutableElement == null) {
        continue;
      }

      final isDinoMethodInvocation = await _tryProcessAddGeneratedMethod(
        invocation,
        executableElement,
        childExecutableElement,
        implementations,
        definitions,
      );

      if (isDinoMethodInvocation) {
        continue;
      }

      if (childExecutableElement is ConstructorElementImpl) {
        // If the invocation is a constructor invocation, we need to recursively
        // proccess the super constructor invocations.

        final superConstructor = childExecutableElement.superConstructor;

        if (superConstructor != null) {
          final superImplementationProvider = await resolve(superConstructor);

          if (superImplementationProvider != null) {
            children.add(superImplementationProvider);
          }
        }
      }

      final childImplementationProvider = await resolve(childExecutableElement);

      if (childImplementationProvider == null) {
        continue;
      }

      children.add(childImplementationProvider);

      _processImplementationProviderInvocation(
        invocation,
        executableElement,
        childImplementationProvider,
        implementations,
        definitions,
      );
    }

    return ImplementationProvider(
      definitions,
      implementations,
      children,
      true,
    );
  }

  /// Adds metadata for invocation of the
  ///
  /// `addGenerated<TService>(ServiceLifetime lifetime, [bool registerAliases])`
  Future<bool> _tryProcessAddGeneratedMethod(
    Expression invocation,
    ExecutableElement parentExecutableElement,
    ExecutableElement executableElement,
    List<ServiceImplementation> implementations,
    List<ServiceImplementationDefinition> definitions,
  ) async {
    // Check whether the invocation is one of the dino add methods
    final isAddGeneratedMethod = isDinoAddGeneratedMethod(executableElement);

    if (!isAddGeneratedMethod) {
      return false;
    }

    if (invocation is! MethodInvocation) {
      return false;
    }

    final typeArgument = invocation.typeArguments?.arguments[0].type?.element;

    _addImplementationOrDefinition(
      parentExecutableElement,
      typeArgument,
      implementations,
      definitions,
    );

    return true;
  }

  void _processImplementationProviderInvocation(
    Expression invocation,
    ExecutableElement parentExecutableElement,
    ImplementationProvider implementationProvider,
    List<ServiceImplementation> implementations,
    List<ServiceImplementationDefinition> definitions,
  ) {
    if (invocation is! MethodInvocation) {
      return;
    }

    for (final definition in implementationProvider.definitions) {
      final typeArgument = invocation
          .typeArguments?.arguments[definition.typeArgumentIndex].type?.element;

      if (typeArgument == null) {
        // If the type argument is not specified, it means that the type is dynamic
        continue;
      }

      _addImplementationOrDefinition(
        parentExecutableElement,
        typeArgument,
        implementations,
        definitions,
      );
    }
  }

  /// Detects whether the [typeElement] is static or generic
  /// and adds corresponding metadata
  void _addImplementationOrDefinition(
    ExecutableElement parentExecutableElement,
    Element? typeElement,
    List<ServiceImplementation> implementations,
    List<ServiceImplementationDefinition> definitions,
  ) {
    // If type element points to a class, just add a generated implementation
    if (typeElement is ClassElement) {
      final implementation = _implementationFactory.create(typeElement);

      implementations.add(implementation);
      return;
    }

    // If type element points to generic type, add a definition
    if (typeElement is TypeParameterElement) {
      // Find the index of the type parameter of the executable element

      final typeParameterIndex = parentExecutableElement.typeParameters
          .indexWhere((typeParameter) => typeParameter == typeElement);

      if (typeParameterIndex == -1) {
        throw Exception(
          'Could not find type parameter ${typeElement.name} '
          'in ${parentExecutableElement.name}',
        );
      }

      definitions.add(ServiceImplementationDefinition(typeParameterIndex));
      return;
    }

    throw Exception(
      'Could not find type element for ${typeElement}',
    );
  }

  Element? _locateServiceCollectionSymbol(
    ExecutableElement executableElement,
  ) {
    for (final element in executableElement.parameters) {
      if (isDinoServiceCollectionType(element.type)) {
        return element;
      }
    }

    if (executableElement is MethodElement) {
      final targetType = getMethodTargetType(executableElement);

      if (isDinoServiceCollectionType(targetType)) {
        return executableElement;
      }
    }

    return null;
  }
}
