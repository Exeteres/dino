import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dino_generator/src/implementation_provider_locator.dart';
import 'package:dino_generator/src/library_method_analyzer.dart';
import 'package:dino_generator/src/service_collection_emitter.dart';
import 'package:dino_generator/src/service_collection_locator.dart';
import 'package:dino_generator/src/service_implementation_factory.dart';

import 'package:dino_generator/src/utils.dart';

class GeneratorCompositionRoot {
  final ServiceImplementationFactory _implementationFactory =
      ServiceImplementationFactory();

  final ServiceCollectionEmitter _scEmitter = ServiceCollectionEmitter();

  Future<String?> process(
    LibraryElement libraryElement,
    Resolver resolver,
  ) async {
    final locatedElements = await _locateServiceCollections(
      libraryElement,
      resolver,
    );

    if (locatedElements == null) {
      return null;
    }

    final library = await _generateLibrary(locatedElements, resolver);

    if (library == null) {
      return null;
    }

    final dartEmitter = DartEmitter(allocator: Allocator());

    final result = library.accept(dartEmitter).toString();

    return '// ignore_for_file: unnecessary_import\n\n$result';
  }

  Future<Map<String, VariableElement>?> _locateServiceCollections(
    LibraryElement libraryElement,
    Resolver resolver,
  ) async {
    final scLocator = ServiceCollectionLocator();
    final methodAnalyzer = LibraryMethodAnalyzer(resolver);

    await methodAnalyzer.analyze(libraryElement, scLocator);

    if (scLocator.locatedElements.isEmpty) {
      return null;
    }

    return scLocator.locatedElements;
  }

  Future<Library?> _generateLibrary(
    Map<String, VariableElement> locatedElements,
    Resolver resolver,
  ) async {
    final classes = <Class>[];

    for (var entry in locatedElements.entries) {
      log.info('Generating implementation for collection ${entry.value.name}');

      final classInstance = await _createSCImplementation(
        entry.key,
        entry.value,
        resolver,
      );

      classes.add(classInstance);
    }

    return Library((l) => l..body.addAll(classes));
  }

  Future<Class> _createSCImplementation(
    String typeName,
    VariableElement element,
    Resolver resolver,
  ) async {
    final executableElement = findEnclosingExecutableElement(element);

    if (executableElement == null) {
      throw Exception('Could not find executable element for $element');
    }

    final impLocator = ImplementationProviderLocator(
      _implementationFactory,
      resolver,
    );

    final implementationProvider = await impLocator.resolve(
      executableElement,
      element,
    );

    if (implementationProvider == null) {
      log.warning('No service registered for ${renderElement(element)}');

      return _scEmitter.emit(typeName, []);
    }

    final providerCache = HashSet<ImplementationProvider>();
    final serviceCache = HashSet<Reference>();

    final allImplementations = _iterateImplementations(
      implementationProvider,
      providerCache,
      serviceCache,
    );

    return _scEmitter.emit(typeName, allImplementations);
  }

  Iterable<ServiceImplementation> _iterateImplementations(
    ImplementationProvider provider,
    HashSet<ImplementationProvider> providerCache,
    HashSet<Reference> serviceCache,
  ) sync* {
    if (providerCache.contains(provider)) {
      return;
    }

    providerCache.add(provider);

    for (final implementation in provider.staticImplementations) {
      if (serviceCache.contains(implementation.serviceType)) {
        continue;
      }

      serviceCache.add(implementation.serviceType);
      yield implementation;
    }

    for (final child in provider.children) {
      yield* _iterateImplementations(child, providerCache, serviceCache);
    }
  }
}
