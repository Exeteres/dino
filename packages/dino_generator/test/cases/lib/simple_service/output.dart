// ignore_for_file: unnecessary_import

import 'package:dino/dino.dart';
import 'package:generator_test_cases/simple_service/input.dart';

class $ServiceCollection extends RuntimeServiceCollection {
  @override
  void addGenerated<TService extends Object>(
    ServiceLifetime lifetime, [
    bool registerAliases = true,
  ]) {
    switch (TService) {
      case TestService:
        addFactory<TestService>(
          lifetime,
          (provider) => TestService(),
          true,
        );
        break;
    }
  }
}
