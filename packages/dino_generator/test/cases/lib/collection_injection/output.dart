// ignore_for_file: unnecessary_import

import 'package:dino/dino.dart';
import 'package:generator_test_cases/collection_injection/input.dart';
import 'dart:core';

class $ServiceCollection extends RuntimeServiceCollection {
  @override
  void addGenerated<TService extends Object>(
    ServiceLifetime lifetime, [
    bool registerAliases = true,
  ]) {
    switch (TService) {
      case ListConsumer:
        addFactory<ListConsumer>(
          lifetime,
          (provider) => ListConsumer(
            provider.getMany<Object>(),
          ),
          true,
        );
        break;
      case IterableConsumer:
        addFactory<IterableConsumer>(
          lifetime,
          (provider) => IterableConsumer(
            provider.getIterable<Object>(),
          ),
          true,
        );
        break;
    }
  }
}
