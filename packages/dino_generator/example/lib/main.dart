import 'package:dino/dino.dart';

part 'main.g.dart';

final class DependencyA {}

final class DependencyB {}

@service
final class DependencyC {
  DependencyC(this.dependencyA, this.dependencyB);

  final DependencyA dependencyA;
  final DependencyB dependencyB;
}

abstract final class TestService {
  void doSomething();
}

@Service(ServiceLifetime.singleton)
final class TestServiceImpl implements TestService {
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
