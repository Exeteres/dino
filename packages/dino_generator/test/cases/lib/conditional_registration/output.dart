// ignore_for_file: unnecessary_import

import 'package:dino/dino.dart';
import 'package:generator_test_cases/conditional_registration/input.dart';

class $ServiceCollection extends RuntimeServiceCollection {
  @override
  void addGenerated<TService extends Object>(ServiceLifetime lifetime,
      [bool registerAliases = true]) {
    switch (TService) {
      case DevelopmentTestService:
        addFactory<DevelopmentTestService>(
          lifetime,
          (provider) => DevelopmentTestService(),
          true,
        );
        break;
      case ProductionTestService:
        addFactory<ProductionTestService>(
          lifetime,
          (provider) => ProductionTestService(),
          true,
        );
        break;
    }
  }
}
