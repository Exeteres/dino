import 'package:dino/dino.dart';

part 'input.g.dart';

final class DependencyA {}

final class DependencyB {}

@service
final class TestService {
  const TestService(this.dependencyA, this.dependencyB);
  final DependencyA dependencyA;
  final DependencyB dependencyB;
}
