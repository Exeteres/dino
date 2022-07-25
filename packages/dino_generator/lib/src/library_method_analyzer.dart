import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';

import 'package:dino_generator/src/utils.dart';

class LibraryMethodAnalyzer {
  LibraryMethodAnalyzer(this._resolver);
  final Resolver _resolver;

  Future<void> analyze(
    LibraryElement library,
    AstVisitor<void> visitor,
  ) async {
    for (var element in library.topLevelElements) {
      if (element is FunctionElement) {
        await _analyzeMethod(element, visitor);

        continue;
      }

      if (element is ClassElement) {
        for (var method in element.methods) {
          await _analyzeMethod(method, visitor);
        }

        continue;
      }
    }
  }

  Future<void> _analyzeMethod(
    Element element,
    AstVisitor<void> visitor,
  ) async {
    final node = await getElementDeclarationNode(element, _resolver);

    if (node != null) {
      node.visitChildren(visitor);
    }
  }
}
