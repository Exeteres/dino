// ignore_for_file: unnecessary_import

import 'package:dino/dino.dart';
import 'package:generator_test_cases/named_parameter_injection/input.dart';
import 'dart:core';

class $ServiceCollection extends RuntimeServiceCollection {
  @override
  void addGenerated<TService extends Object>(
    ServiceLifetime lifetime, [
    bool registerAliases = true,
  ]) {
    switch (TService) {
      case TestService:
        addFactory<TestService>(
          lifetime,
          (provider) => TestService(
            provider.getRequired<String>(),
            provider.getRequired<String>(),
            c: provider.getRequired<String>(),
            d: provider.getRequired<String>(),
          ),
          true,
        );
        break;
    }
  }
}
