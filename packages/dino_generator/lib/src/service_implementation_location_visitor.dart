import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:dino_generator/src/utils.dart';

class ServiceImplementationLocationVisitor extends RecursiveAstVisitor {
  ServiceImplementationLocationVisitor(this._scSymbol);
  final Element _scSymbol;

  List<InvocationExpression> locatedInvocations = [];

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (_checkArgumentIdentifiers(node)) {
      locatedInvocations.add(node);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target == null && _checkMethodTarget(node)) {
      locatedInvocations.add(node);
      return;
    }

    if (_checkIdentifier(node.target) || _checkArgumentIdentifiers(node)) {
      locatedInvocations.add(node);
    }
  }

  bool _checkMethodTarget(MethodInvocation node) {
    final identifier = node.function;

    if (identifier is! Identifier) {
      return false;
    }

    final staticElement = identifier.staticElement;

    if (staticElement is! MethodElement) {
      return false;
    }

    final type = getMethodTargetType(staticElement);

    return isDinoServiceCollectionType(type);
  }

  bool _checkArgumentIdentifiers(InvocationExpression expression) {
    for (var argument in expression.argumentList.arguments) {
      if (_checkIdentifier(argument)) {
        return true;
      }
    }

    return false;
  }

  bool _checkIdentifier(Expression? node) {
    if (node is! Identifier) {
      return false;
    }

    if (node.staticElement != _scSymbol) {
      return false;
    }

    return true;
  }
}
