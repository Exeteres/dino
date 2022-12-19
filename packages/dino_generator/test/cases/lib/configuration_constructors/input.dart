import 'package:dino/dino.dart';

import 'package:generator_test_cases/configuration_constructors/output.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();

  ApplicationA(services);
  ApplicationB(services);
  ApplicationC(services);
}

class ApplicationA {
  ApplicationA(ServiceCollection services) {
    services.addSingleton<TestServiceA>();
  }
}

class ApplicationB extends ApplicationBBase {
  // Should also analyze constructors of super classes
  ApplicationB(ServiceCollection services) : super(services);
}

class ApplicationC extends ApplicationCBase {
  // And for short syntax too
  ApplicationC(super.services);
}

abstract class ApplicationBBase {
  ApplicationBBase(ServiceCollection services) {
    services.addSingleton<TestServiceB>();
  }
}

abstract class ApplicationCBase {
  ApplicationCBase(ServiceCollection services) {
    services.addSingleton<TestServiceC>();
  }
}

class TestServiceA {}

class TestServiceB {}

class TestServiceC {}
