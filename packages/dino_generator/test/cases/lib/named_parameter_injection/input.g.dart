part of 'input.dart';

extension TestServiceFactory on ServiceCollection {
  void addTestService(
    ServiceLifetime lifetime, [
    bool registerAliases = true,
  ]) {
    addFactory<TestService>(
      lifetime,
      (provider) => TestService(
        provider.getRequired<String>(),
        provider.getRequired<String>(),
        c: provider.getRequired<String>(),
        d: provider.getRequired<String>(),
      ),
      true,
    );
  }
}
