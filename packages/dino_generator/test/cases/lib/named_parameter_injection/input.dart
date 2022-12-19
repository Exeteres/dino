import 'package:dino/dino.dart';

import 'package:generator_test_cases/named_parameter_injection/output.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();

  services.addSingleton<TestService>();
}

class TestService {
  TestService(
    String a,
    String b, {
    required String c,
    required String d,
  });
}
