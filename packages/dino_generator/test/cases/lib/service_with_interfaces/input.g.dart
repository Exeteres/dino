part of 'input.dart';

extension TestServiceFactory on ServiceCollection {
  void addTestService(
    ServiceLifetime lifetime, [
    bool registerAliases = true,
  ]) {
    addFactory<TestService>(
      lifetime,
      (provider) => TestService(),
      true,
    );

    if (registerAliases) {
      addAlias<Initializable, TestService>(true);
    }
  }
}
