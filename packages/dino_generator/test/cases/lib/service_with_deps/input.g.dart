part of 'input.dart';

extension TestServiceFactory on ServiceCollection {
  void addTestService(
    ServiceLifetime lifetime, [
    bool registerAliases = true,
  ]) {
    addFactory<TestService>(
      lifetime,
      (provider) => TestService(
        provider.getRequired<DependencyA>(),
        provider.getRequired<DependencyB>(),
      ),
      true,
    );
  }
}
