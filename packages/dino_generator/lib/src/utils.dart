import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart' hide Expression;

const String dinoLibraryUri = 'package:dino/dino.dart';

const String dinoServiceDescriptorLibraryUri =
    'package:dino/src/collection/service_descriptor.dart';

const String dinoServiceCollectionLibraryUri =
    'package:dino/src/collection/service_collection.dart';

Future<AstNode?> getElementDeclarationNode(Element element) async {
  final session = element.session;

  if (session == null) {
    throw Exception('Element declaraion session is null');
  }

  final library = element.library;

  if (library == null) {
    log.warning('Element is not associated with library');
    return null;
  }

  final result = await session.getResolvedLibraryByElement(library);

  if (result is! ResolvedLibraryResult) {
    log.warning('Failed to load library ${element.library}');
    return null;
  }

  final declararation = result.getElementDeclaration(element);

  if (declararation == null) {
    log.warning('Failed to fetch element declaration');
    return null;
  }

  return declararation.node;
}

Reference referDino(String symbol) {
  return refer(symbol, dinoLibraryUri);
}

Reference referElement(Element element) {
  return refer(element.displayName, element.source!.uri.toString());
}

bool isDinoServiceCollectionType(DartType type) {
  if (type.getDisplayString(withNullability: false) != 'ServiceCollection') {
    return false;
  }

  if (type.element?.source?.uri.toString() != dinoServiceCollectionLibraryUri) {
    return false;
  }

  return true;
}

bool isDinoAddGeneratedMethod(ExecutableElement element) {
  return element.source.uri.toString() == dinoServiceCollectionLibraryUri &&
      element.name == 'addGenerated';
}

ExecutableElement? findEnclosingExecutableElement(Element element) {
  Element? parent = element.enclosingElement;
  ExecutableElement? executableElement;

  while (parent != null) {
    if (parent is ExecutableElement) {
      executableElement = parent;
      break;
    }

    parent = parent.enclosingElement;
  }

  return executableElement;
}

ExecutableElement? getInvocationExecutableElement(
  InvocationExpression invocation,
) {
  final identifier = invocation.function;

  if (identifier is! Identifier) {
    return null;
  }

  return identifier.staticElement as ExecutableElement;
}

String renderElement(Element element) {
  return '$element in ${element.source}';
}

DartType getMethodTargetType(MethodElement element) {
  final enclosingElement = element.enclosingElement;

  if (enclosingElement is ExtensionElement) {
    return enclosingElement.extendedType;
  }

  if (enclosingElement is ClassElement) {
    return enclosingElement.thisType;
  }

  throw Exception(
    'Failed to detect this type for '
    '${renderElement(enclosingElement)}',
  );
}
