import 'package:dino/dino.dart';

import 'package:generator_test_cases/conditional_registration/output.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();

  if (bool.hasEnvironment('development')) {
    services.addSingleton<DevelopmentTestService>();
  } else {
    services.addSingleton<ProductionTestService>();
  }
}

class DevelopmentTestService {}

class ProductionTestService {}
