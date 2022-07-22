// ignore_for_file: unnecessary_import

import 'package:dino/dino.dart';
import 'package:generator_test_cases/service_with_interfaces/input.dart';
import 'package:dino/src/lifecycle/lifecycle.dart';

class $ServiceCollection extends RuntimeServiceCollection {
  @override
  void addGenerated<TService extends Object>(ServiceLifetime lifetime,
      [bool registerAliases = true]) {
    switch (TService) {
      case TestService:
        addFactory<TestService>(
          lifetime,
          (provider) => TestService(),
          true,
        );

        if (registerAliases) {
          addAlias<Initializable, TestService>(true);
        }

        break;
    }
  }
}
