import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import 'package:dino_generator/src/utils.dart';

class ServiceCollectionLocator extends RecursiveAstVisitor {
  Map<String, VariableElement> locatedElements = {};

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final element = node.declaredElement!;

    if (!isDinoServiceCollectionType(element.type)) {
      return;
    }

    final initializer = node.initializer;

    if (initializer is! InvocationExpression) {
      return;
    }

    final function = initializer.function;

    if (function is! SimpleIdentifier) {
      return;
    }

    if (!function.name.startsWith('\$')) {
      return;
    }

    locatedElements[function.name] = element;
  }
}
