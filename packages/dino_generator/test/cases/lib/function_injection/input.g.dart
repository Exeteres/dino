part of 'input.dart';

extension TestServiceFactory on ServiceCollection {
  void addTestService(
    ServiceLifetime lifetime, [
    bool registerAliases = true,
  ]) {
    addFactory<TestService>(
      lifetime,
      (provider) => TestService(
        provider.getRequired<String Function(String)>(),
        provider.getRequired<String Function(String)>(),
      ),
      true,
    );
  }
}
