// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// Dino Generator
// **************************************************************************

extension DependencyCFactory on ServiceCollection {
  void addDependencyC(
    ServiceLifetime lifetime, [
    bool registerAliases = true,
  ]) {
    addFactory<DependencyC>(
      lifetime,
      (provider) => DependencyC(
        provider.getRequired<DependencyA>(),
        provider.getRequired<DependencyB>(),
      ),
      true,
    );
  }
}

extension TestServiceImplFactory on ServiceCollection {
  void addTestServiceImpl([
    ServiceLifetime lifetime = ServiceLifetime.singleton,
    bool registerAliases = true,
  ]) {
    addFactory<TestServiceImpl>(
      lifetime,
      (provider) => TestServiceImpl(
        provider.getRequired<DependencyA>(),
        provider.getRequired<DependencyB>(),
        provider.getRequired<DependencyC>(),
      ),
      true,
    );

    if (registerAliases) {
      addAlias<TestService, TestServiceImpl>(true);
    }
  }
}
