import 'dart:io';

import 'package:dino/dino.dart';

import 'package:generator_test_cases/duplicate_registrations/output.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();

  services.addSingleton<TestService>();
}

class TestService {
  TestService(this.directory);

  final Directory directory;
}
