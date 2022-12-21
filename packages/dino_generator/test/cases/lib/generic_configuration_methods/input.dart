import 'package:dino/dino.dart';

import 'package:generator_test_cases/generic_configuration_methods/output.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();

  addTestService1<TestServiceA>(services);
  services.addTestService2<TestServiceB>();
  addTestService3<TestServiceC>(services);
}

void addTestService1<TService extends Object>(ServiceCollection services) {
  services.addSingleton<TService>();
}

extension on ServiceCollection {
  void addTestService2<TService extends Object>() {
    addSingleton<TService>();
  }
}

void addTestService3<TService extends Object>(ServiceCollection services) {
  services.addTestService2<TService>();
}

class TestServiceA {}

class TestServiceB {}

class TestServiceC {}
