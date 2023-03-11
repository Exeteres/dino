import 'package:dino/dino.dart';

part 'input.g.dart';

typedef Dependency = String Function(String);

@service
class TestService {
  TestService(this.dependency1, this.dependency2);

  final String Function(String) dependency1;
  final Dependency dependency2;
}
