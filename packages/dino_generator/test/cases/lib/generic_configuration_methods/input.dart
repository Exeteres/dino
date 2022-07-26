import 'package:dino/dino.dart';

import 'package:generator_test_cases/generic_configuration_methods/output.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();

  addTestServiceA<TestServiceA>(services);
  services.addTestServiceB<TestServiceB>();
}

void addTestServiceA<TService extends Object>(ServiceCollection services) {
  services.addSingleton<TService>();
}

extension on ServiceCollection {
  void addTestServiceB<TService extends Object>() {
    addSingleton<TService>();
  }
}

class TestServiceA {}

class TestServiceB {}
