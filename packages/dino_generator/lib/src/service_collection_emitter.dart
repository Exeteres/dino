import 'package:code_builder/code_builder.dart';
import 'package:dino_generator/src/service_implementation_factory.dart';

/// This is an internal API that is not intended for use by developers.
///
/// It may be changed or removed without notice.
class ServiceCollectionEmitter {
  Extension emit(ServiceImplementation implementation) {
    return Extension(
      (b) => b
        ..name = '${implementation.serviceType.symbol}Factory'
        ..on = refer('ServiceCollection')
        ..methods.add(_emitMethod(implementation)),
    );
  }

  Method _emitMethod(ServiceImplementation implementation) {
    return Method.returnsVoid((builder) {
      final lifetime = implementation.lifetime;

      if (lifetime != null) {
        builder.optionalParameters.add(Parameter(
          (b) => b
            ..name = 'lifetime'
            ..type = refer('ServiceLifetime')
            ..defaultTo = lifetime.code,
        ));
      } else {
        builder.requiredParameters.add(Parameter(
          (b) => b
            ..name = 'lifetime'
            ..type = refer('ServiceLifetime'),
        ));
      }

      builder.optionalParameters.add(Parameter(
        (b) => b
          ..name = 'registerAliases'
          ..type = refer('bool')
          ..defaultTo = Code('true'),
      ));

      builder.name = 'add${implementation.serviceType.symbol}';
      builder.body = _emitBody(implementation);
    });
  }

  Code _emitBody(ServiceImplementation implementation) {
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
    String methodName;

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
