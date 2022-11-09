import 'package:dino/dino.dart';

import 'main.dino.g.dart';

class DependencyA {}

class DependencyB {}

abstract class TestService {
  void doSomething();
}

class TestServiceImpl implements TestService {
  final DependencyA dependencyA;
  final DependencyB dependencyB;

  TestServiceImpl(this.dependencyA, this.dependencyB);

  @override
  void doSomething() {
    print('doSomething');
  }
}

void main() {
  // Create a service collection
  // The implementation of the service collection is generated
  //by the dino_generator based on subsequent method calls
  final ServiceCollection services = $ServiceCollection();

  // Create dependency A only once
  services.addInstance(DependencyA());

  // Create dependency B every time it is requested
  services.addTransientFactory((sp) => DependencyB());

  // Create TestService per a scope
  services.addScoped<TestServiceImpl>();

  // Create a root scope
  final rootScope = services.buildRootScope();

  // Create a nested scope
  final scope = rootScope.serviceProvider.createScope();

  // Resolve TestService from the nested scope
  final testService = scope.serviceProvider.getRequired<TestService>();

  testService.doSomething();
}
