import 'package:dino/dino.dart';

import 'package:generator_test_cases/duplicate_registrations/output.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();

  // should generate implementation only once
  services.addSingleton<TestService>();
  services.addSingleton<TestService>();
}

class TestService {}
