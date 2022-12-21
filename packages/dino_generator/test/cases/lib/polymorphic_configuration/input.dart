import 'package:dino/dino.dart';

import 'package:generator_test_cases/polymorphic_configuration/output.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();

  configure(services, ConfigurationServiceA());
  configure(services, ConfigurationServiceB());
}

void configure<T extends ConfigurationService>(
  ServiceCollection services,
  T configuration,
) {
  configuration.configureServices(services);
}

abstract class ConfigurationService {
  void configureServices(ServiceCollection services);
}

class ConfigurationServiceA implements ConfigurationService {
  @override
  void configureServices(ServiceCollection services) {
    services.addSingleton<TestServiceA>();
  }
}

class ConfigurationServiceB implements ConfigurationService {
  @override
  void configureServices(ServiceCollection services) {
    services.addSingleton<TestServiceB>();
  }
}

class TestServiceA {}

class TestServiceB {}
