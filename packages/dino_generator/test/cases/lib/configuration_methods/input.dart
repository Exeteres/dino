import 'package:dino/dino.dart';

import 'package:generator_test_cases/configuration_methods/output.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();

  addTestServiceA(services);
  services.addTestServiceB();
}

void addTestServiceA(ServiceCollection services) {
  services.addSingleton<TestServiceA>();
}

extension on ServiceCollection {
  void addTestServiceB() {
    addSingleton<TestServiceB>();
  }
}

class TestServiceA {}

class TestServiceB {}
