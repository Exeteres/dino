// ignore_for_file: unnecessary_import

import 'package:dino/dino.dart';
import 'package:generator_test_cases/configuration_methods/input.dart';

class $ServiceCollection extends RuntimeServiceCollection {
  @override
  void addGenerated<TService extends Object>(ServiceLifetime lifetime,
      [bool registerAliases = true]) {
    switch (TService) {
      case TestServiceA:
        addFactory<TestServiceA>(
          lifetime,
          (provider) => TestServiceA(),
          true,
        );
        break;
      case TestServiceB:
        addFactory<TestServiceB>(
          lifetime,
          (provider) => TestServiceB(),
          true,
        );
        break;
    }
  }
}
