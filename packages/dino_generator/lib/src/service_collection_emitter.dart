import 'package:code_builder/code_builder.dart';

import 'package:dino_generator/src/service_implementation_factory.dart';
import 'package:dino_generator/src/utils.dart';

class ServiceCollectionEmitter {
  Class emit(
    String typeName,
    Iterable<ServiceImplementation> implementations,
  ) {
    return Class(
      (b) => b
        ..name = typeName
        ..extend = referDino('RuntimeServiceCollection')
        ..methods.add(_emitMethod(implementations)),
    );
  }

  Method _emitMethod(Iterable<ServiceImplementation> implementations) {
    return Method.returnsVoid(
      (b) => b
        ..name = 'addGenerated'
        ..annotations.add(CodeExpression(Code('override')))
        ..types.add(refer('TService extends Object'))
        ..requiredParameters.addAll([
          Parameter((b) => b
            ..name = 'lifetime'
            ..type = referDino('ServiceLifetime')),
        ])
        ..optionalParameters.addAll([
          Parameter((b) => b
            ..name = 'registerAliases'
            ..type = refer('bool')
            ..defaultTo = Code('true')),
        ])
        ..body = _emitBody(implementations),
    );
  }

  Code _emitBody(Iterable<ServiceImplementation> implementations) {
    return Block.of([
      const Code('switch (TService) {'),
      ...implementations.map(_emitImplementationCase),
      const Code('}')
    ]);
  }

  Code _emitImplementationCase(ServiceImplementation implementation) {
    return Block.of([
      const Code('case '),
      implementation.serviceType.code,
      const Code(':'),
      _emitImplementation(implementation),
      const Code('break;')
    ]);
  }

  Code _emitImplementation(ServiceImplementation implementation) {
    return Block.of([
      _emitServiceRegistration(implementation),
      ..._emitAliasRegistrationBlock(implementation)
    ]);
  }

  Iterable<Code> _emitAliasRegistrationBlock(
    ServiceImplementation implementation,
  ) sync* {
    if (implementation.aliases.isEmpty) {
      return;
    }

    yield const Code('\nif (registerAliases) {\n');

    yield* implementation.aliases.map(
      (aliasType) => _emitAliasRegistration(
        aliasType,
        implementation.serviceType,
      ),
    );

    yield const Code('}\n');
  }

  Code _emitAliasRegistration(
    Reference aliasType,
    Reference implementationType,
  ) {
    return Block.of([
      refer('addAlias').call([
        refer('true'),
      ], {}, [
        aliasType,
        implementationType,
      ]).code,
      const Code(';')
    ]);
  }

  Code _emitServiceRegistration(ServiceImplementation implementation) {
    return Block.of([
      Code('addFactory<'),
      implementation.serviceType.code,
      const Code('>(lifetime,'),
      Method((b) => b
        ..requiredParameters.add(Parameter((b) => b.name = 'provider'))
        ..lambda = true
        ..body = _emitServiceConstruction(implementation)).closure.code,
      const Code(', true,);')
    ]);
  }

  Code _emitServiceConstruction(ServiceImplementation implementation) {
    return Block.of([
      implementation.serviceType.code,
      const Code('('),
      ...implementation.dependencies.map(_emitDependencyResolution),
      ...implementation.namedDependencies.entries
          .map(_emitNamedDependencyAssignment),
      const Code(')')
    ]);
  }

  Code _emitDependencyResolution(ImplementationDependency dependency) {
    var methodName;

    switch (dependency.kind) {
      case DependencyKind.single:
        methodName = 'getRequired';
        break;
      case DependencyKind.iterable:
        methodName = 'getIterable';
        break;
      case DependencyKind.list:
        methodName = 'getMany';
        break;
      default:
        throw Exception('Unexpected dependency kind');
    }

    return Block.of([
      refer('provider').property(methodName).call([], {}, [
        dependency.reference,
      ]).code,
      const Code(',')
    ]);
  }

  Code _emitNamedDependencyAssignment(
    MapEntry<String, ImplementationDependency> entry,
  ) {
    return Block.of([
      Code(entry.key),
      const Code(':'),
      _emitDependencyResolution(entry.value),
    ]);
  }
}
