import 'package:dino/dino.dart';

import 'package:generator_test_cases/service_with_interfaces/output.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();

  services.addSingleton<TestService>();
}

class TestService implements Initializable {
  @override
  Future<void> initialize() {
    throw UnimplementedError();
  }
}
