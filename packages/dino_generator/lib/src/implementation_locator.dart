import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dino_generator/src/service_implementation_factory.dart';
import 'package:dino_generator/src/implementation_locator_visitor.dart';
import 'package:dino_generator/src/utils.dart';

import 'package:analyzer/src/dart/element/element.dart';

/// This is an internal API that is not intended for use by developers.
///
/// It may be changed or removed without notice.
class ImplementationLocator {
  ImplementationLocator(this._implementationFactory, this._resolver);

  final ServiceImplementationFactory _implementationFactory;
  final Resolver _resolver;

  final Set<ServiceImplementation> locatedImplementations = {};

  /// Analyzes the given [executableElement], locates all
  /// [ServiceImplementation]s and populates [locatedImplementations].
  Future<void> analyzeExecutable(
    ExecutableElement executableElement, {
    List<ClassElement?>? typeArguments,
    List<ClassElement?>? arguments,
    Expression? invocation,
    Element? scSymbol,
  }) async {
    final node = await getElementDeclarationNode(executableElement, _resolver);

    if (node == null) {
      return;
    }

    if (scSymbol == null) {
      scSymbol = _locateSCSymbol(executableElement);
    }

    final visitor = ImplementationLocatorVisitor(scSymbol);

    node.accept(visitor);

    if (visitor.locatedInvocations.isEmpty) {
      return;
    }

    await _analyzeInvocations(
      executableElement,
      typeArguments ?? const [],
      arguments ?? const [],
      invocation,
      visitor.locatedInvocations,
    );
  }

  Future<void> _analyzeInvocations(
    ExecutableElement parentExecutableElement,
    List<ClassElement?> parentTypeArguments,
    List<ClassElement?> parentArguments,
    Expression? parentInvocation,
    List<Expression> invocations,
  ) async {
    for (final invocation in invocations) {
      final typeArguments = _resolveInvocationTypeArguments(
        invocation,
        parentExecutableElement,
        parentTypeArguments,
      );

      final arguments = _resolveInvocationArguments(
        invocation,
        parentExecutableElement,
        parentArguments,
      );

      final executableElement = _getInvocationExecutableElement(invocation);

      if (executableElement == null) {
        continue;
      }

      final isDinoMethodInvocation = await _tryProcessAddGeneratedMethod(
        invocation,
        executableElement,
        typeArguments,
      );

      if (isDinoMethodInvocation) {
        continue;
      }

      await _tryProcessConstructorInvocation(
        executableElement,
        invocation,
        typeArguments,
        arguments,
      );

      final isPolymorphic = await _tryProcessPolymorphicMethodInvocation(
        invocation,
        executableElement,
        typeArguments,
        arguments,
        parentExecutableElement,
        parentInvocation,
        parentArguments,
      );

      if (isPolymorphic) {
        continue;
      }

      await analyzeExecutable(
        executableElement,
        invocation: invocation,
        typeArguments: typeArguments,
        arguments: arguments,
      );
    }
  }

  Future<bool> _tryProcessPolymorphicMethodInvocation(
    Expression invocation,
    ExecutableElement executableElement,
    List<ClassElement?> typeArguments,
    List<ClassElement?> arguments,
    ExecutableElement parentExecutableElement,
    Expression? parentInvocation,
    List<ClassElement?> parentArguments,
  ) async {
    if (parentInvocation == null) {
      return false;
    }

    if (invocation is! MethodInvocation) {
      return false;
    }

    final targetElement = invocation.target;

    if (targetElement is! Identifier) {
      return false;
    }

    final parameterIndex = parentExecutableElement.parameters
        .indexWhere((element) => element.name == targetElement.name);

    if (parameterIndex == -1) {
      return false;
    }

    if (parameterIndex >= parentArguments.length) {
      return false;
    }

    final realTarget = parentArguments[parameterIndex];

    if (realTarget == null) {
      return false;
    }

    final method = _findPolymorphicMethod(
      realTarget,
      executableElement,
    );

    if (method == null) {
      return false;
    }

    await analyzeExecutable(
      method,
      invocation: invocation,
      typeArguments: typeArguments,
      arguments: arguments,
    );

    return true;
  }

  MethodElement? _findPolymorphicMethod(
    ClassElement realTarget,
    ExecutableElement executableElement,
  ) {
    for (final typeMethod in realTarget.methods) {
      if (typeMethod.name == executableElement.name) {
        return typeMethod;
      }
    }

    final superType = realTarget.supertype;

    if (superType == null || superType.isDartCoreObject) {
      return null;
    }

    return _findPolymorphicMethod(
      superType.element as ClassElement,
      executableElement,
    );
  }

  Future<void> _tryProcessConstructorInvocation(
    ExecutableElement executableElement,
    Expression invocation,
    List<ClassElement?> typeArguments,
    List<ClassElement?> arguments,
  ) async {
    if (executableElement is! ConstructorElementImpl) {
      return;
    }

    final superConstructor = executableElement.superConstructor;

    if (superConstructor != null) {
      await analyzeExecutable(
        superConstructor,
        invocation: invocation,
        typeArguments: typeArguments,
        arguments: arguments,
      );
    }

    final redirectingConstructor = executableElement.redirectedConstructor;

    if (redirectingConstructor != null) {
      await analyzeExecutable(
        redirectingConstructor,
        invocation: invocation,
        typeArguments: typeArguments,
        arguments: arguments,
      );
    }
  }

  Future<bool> _tryProcessAddGeneratedMethod(
    Expression invocation,
    ExecutableElement executableElement,
    List<ClassElement?> typeArguments,
  ) async {
    // Check whether the invocation is one of the dino add methods
    final isAddGeneratedMethod = isDinoAddGeneratedMethod(executableElement);

    if (!isAddGeneratedMethod) {
      return false;
    }

    if (invocation is! MethodInvocation) {
      return false;
    }

    final typeArgument = typeArguments[0];

    if (typeArgument == null) {
      return true;
    }

    final implementation = await _implementationFactory.create(typeArgument);
    locatedImplementations.add(implementation);

    return true;
  }

  Element? _locateSCSymbol(ExecutableElement executableElement) {
    for (final element in executableElement.parameters) {
      if (isDinoServiceCollectionType(element.type)) {
        return element;
      }
    }

    return null;
  }

  List<ClassElement?> _resolveInvocationTypeArguments(
    Expression invocation,
    ExecutableElement parentExecutableElement,
    List<ClassElement?> parentTypeArguments,
  ) {
    final argumentList = _getInvocationTypeArgumentList(invocation);

    if (argumentList == null) {
      return const [];
    }

    final result = List<ClassElement?>.filled(
      argumentList.arguments.length,
      null,
    );

    for (var i = 0; i < argumentList.arguments.length; i++) {
      final typeElement = argumentList.arguments[i].type?.element;

      if (typeElement is ClassElement) {
        result[i] = typeElement;
        continue;
      }

      if (typeElement is TypeParameterElement) {
        final index = parentExecutableElement.typeParameters
            .indexWhere((element) => element == typeElement);

        if (index == -1 || index >= parentTypeArguments.length) {
          continue;
        }

        result[i] = parentTypeArguments[index];
        continue;
      }
    }

    return result;
  }

  List<ClassElement?> _resolveInvocationArguments(
    Expression invocation,
    ExecutableElement parentExecutableElement,
    List<ClassElement?> parentArguments,
  ) {
    final argumentList = _getInvocationArgumentList(invocation);

    final result = List<ClassElement?>.filled(
      argumentList.arguments.length,
      null,
    );

    for (var i = 0; i < argumentList.arguments.length; i++) {
      final argument = argumentList.arguments[i];

      if (argument is Identifier) {
        final parameterIndex = parentExecutableElement.parameters
            .indexWhere((element) => element.name == argument.name);

        if (parameterIndex == -1 || parameterIndex >= parentArguments.length) {
          continue;
        }

        result[i] = parentArguments[parameterIndex];

        continue;
      }

      final typeElement = argument.staticType?.element;

      if (typeElement is ClassElement) {
        result[i] = typeElement;
        continue;
      }
    }

    return result;
  }

  ArgumentList _getInvocationArgumentList(Expression invocation) {
    if (invocation is MethodInvocation) {
      return invocation.argumentList;
    } else if (invocation is InstanceCreationExpression) {
      return invocation.argumentList;
    } else {
      throw Exception('Unsupported invocation type: $invocation');
    }
  }

  TypeArgumentList? _getInvocationTypeArgumentList(Expression invocation) {
    if (invocation is MethodInvocation) {
      return invocation.typeArguments;
    } else if (invocation is InstanceCreationExpression) {
      return invocation.constructorName.type.typeArguments;
    } else {
      throw Exception('Unsupported invocation type: $invocation');
    }
  }

  ExecutableElement? _getInvocationExecutableElement(Expression invocation) {
    if (invocation is MethodInvocation) {
      final identifier = invocation.function;

      if (identifier is! Identifier) {
        return null;
      }

      return identifier.staticElement as ExecutableElement?;
    }

    if (invocation is InstanceCreationExpression) {
      return invocation.constructorName.staticElement;
    }

    return null;
  }
}
