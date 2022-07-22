import 'package:dino/dino.dart';

import 'package:generator_test_cases/service_with_deps/output.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();

  services.addSingleton<TestService>();
}

class DependencyA {}

class DependencyB {}

class TestService {
  final DependencyA dependencyA;
  final DependencyB dependencyB;

  TestService(this.dependencyA, this.dependencyB);
}
