import 'package:dino/dino.dart';

part 'main.g.dart';

class DependencyA {}

class DependencyB {}

@service
class DependencyC {
  DependencyC(this.dependencyA, this.dependencyB);

  final DependencyA dependencyA;
  final DependencyB dependencyB;
}

abstract class TestService {
  void doSomething();
}

@Service(ServiceLifetime.singleton)
class TestServiceImpl implements TestService {
  TestServiceImpl(
    this.dependencyA,
    this.dependencyB,
    this.dependencyC,
  );

  final DependencyA dependencyA;
  final DependencyB dependencyB;
  final DependencyC dependencyC;

  @override
  void doSomething() {
    print('doSomething');
  }
}

void main(List<String> args) {
  final services = ServiceCollection();

  services.addDependencyC(ServiceLifetime.transient);
  services.addTestServiceImpl();
}
