import 'dart:io';

import 'package:dino/dino.dart';

import 'package:generator_test_cases/dependency_in_part_file/output.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();

  services.addSingleton<TestService>();
}

class TestService {
  TestService(this.directory);

  final Directory directory;
}
