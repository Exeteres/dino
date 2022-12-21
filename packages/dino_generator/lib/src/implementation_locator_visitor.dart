import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:dino_generator/src/utils.dart';

/// This is an internal API that is not intended for use by developers.
///
/// It may be changed or removed without notice.
class ImplementationLocatorVisitor extends RecursiveAstVisitor {
  ImplementationLocatorVisitor(this._scSymbol);
  final Element? _scSymbol;

  List<Expression> locatedInvocations = [];

  // We will collect all (or almost all) invocations
  // that somehow use the ServiceCollection

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (_checkArgumentIdentifiers(node.argumentList)) {
      // This is a function invocation with ServiceCollection as an argument

      locatedInvocations.add(node);
    }
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (_checkArgumentIdentifiers(node.argumentList)) {
      // This is a constructor invocation with ServiceCollection as an argument

      locatedInvocations.add(node);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target == null && _checkMethodTarget(node)) {
      // This is an implicit call to the method on `this`
      // inside ServiceCollection (it's sub class or extension)

      // For example:
      // extension on ServiceCollection {
      //   void addMyService() {
      //     addSingleton<MyService>(); // this is the analyzed invocation
      //   }
      // }

      locatedInvocations.add(node);
      return;
    }

    if (_checkIdentifier(node.target) ||
        _checkArgumentIdentifiers(node.argumentList)) {
      // This is an invocation of the method on a variable
      // Eithier the target or one of the arguments is the ServiceCollection

      // For example:
      // services.addMyService(); // this is the analyzed invocation
      // or
      // addMyService(services); // this is the analyzed invocation

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

  bool _checkArgumentIdentifiers(ArgumentList argumentList) {
    for (final argument in argumentList.arguments) {
      if (_checkIdentifier(argument)) {
        return true;
      }
    }

    return false;
  }

  bool _checkIdentifier(Expression? node) {
    if (node is ThisExpression) {
      return true;
    }

    if (node is! Identifier) {
      return false;
    }

    final staticType = node.staticType;

    if (staticType == null) {
      return false;
    }

    if (_scSymbol != null) {
      return node.staticElement == _scSymbol;
    }

    return isDinoServiceCollectionType(staticType);
  }
}
