part of 'input.dart';

extension ListConsumerFactory on ServiceCollection {
  void addListConsumer(
    ServiceLifetime lifetime, [
    bool registerAliases = true,
  ]) {
    addFactory<ListConsumer>(
      lifetime,
      (provider) => ListConsumer(
        provider.getMany<Object>(),
      ),
      true,
    );
  }
}

extension IterableConsumerFactory on ServiceCollection {
  void addIterableConsumer(
    ServiceLifetime lifetime, [
    bool registerAliases = true,
  ]) {
    addFactory<IterableConsumer>(
      lifetime,
      (provider) => IterableConsumer(
        provider.getIterable<Object>(),
      ),
      true,
    );
  }
}
