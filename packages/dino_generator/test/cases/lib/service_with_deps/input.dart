import 'package:dino/dino.dart';

part 'input.g.dart';

class DependencyA {}

class DependencyB {}

@service
class TestService {
  final DependencyA dependencyA;
  final DependencyB dependencyB;

  TestService(this.dependencyA, this.dependencyB);
}
