// ignore_for_file: unnecessary_import

import 'package:dino/dino.dart';
import 'package:generator_test_cases/dependency_in_part_file/input.dart';
import 'dart:io';

class $ServiceCollection extends RuntimeServiceCollection {
  @override
  void addGenerated<TService extends Object>(ServiceLifetime lifetime,
      [bool registerAliases = true]) {
    switch (TService) {
      case TestService:
        addFactory<TestService>(
          lifetime,
          (provider) => TestService(
            provider.getRequired<Directory>(),
          ),
          true,
        );
        break;
    }
  }
}
