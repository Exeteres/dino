import 'package:dino/dino.dart';

import 'package:generator_test_cases/simple_service/output.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();

  services.addSingleton<TestService>();
}

class TestService {}
