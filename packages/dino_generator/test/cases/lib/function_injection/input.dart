import 'package:dino/dino.dart';

import 'package:generator_test_cases/function_injection/output.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();

  services.addSingleton<TestService>();
}

typedef Dependency = String Function(String);

class TestService {
  TestService(this.dependency1, this.dependency2);

  final String Function(String) dependency1;
  final Dependency dependency2;
}
