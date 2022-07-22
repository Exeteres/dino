import 'package:dino/dino.dart';
import 'package:dino_extensions/dino_extensions.dart';

import 'package:test/test.dart';

void main() {
  group('addModule method', () {
    test('should add module and configure its dependencies only once', () {
      final services = RuntimeServiceCollection();

      services.addModule(TestModule());
      services.addModule(TestModule());

      final descriptors = services.where(
        (element) => element.serviceType == TestService,
      );

      expect(descriptors.length, 1);
    });

    test('should add module with additional configuration', () {
      final services = RuntimeServiceCollection();

      services.addModule<TestModuleBuilder>(
        TestModuleWithBuilder(),
        (b) => b
          ..addAdditionalServices()
          ..addAdditionalServices(),
      );

      services.addModule<TestModuleBuilder>(
        TestModuleWithBuilder(),
        (b) => b
          ..addAdditionalServices()
          ..addAdditionalServices(),
      );

      final descriptors = services.where(
        (element) => element.serviceType == TestService,
      );

      expect(descriptors.length, 5);
    });
  });

  group('Module Manager', () {
    test('should contain information about added modules', () {
      final services = RuntimeServiceCollection();

      services.addModule(TestModule());
      services.addModule(TestModuleWithCustomInfo());

      final scope = services.buildRootScope();
      final moduleManager = scope.serviceProvider.getRequired<ModuleManager>();

      expect(moduleManager.modules.length, 2);

      final module1 = moduleManager.modules.elementAt(0);
      final module2 = moduleManager.modules.elementAt(1);

      expect(module1.name, 'Test');
      expect(module1.version, '1.0.0');
      expect(module1.description, '');

      expect(module2.name, 'Test42');
      expect(module2.version, '42.42.42');
      expect(module2.description, 'Test module with custom info');
      expect(module2['test'], 42);
    });
  });
}

class TestModule extends Module {
  @override
  void configureServices(ServiceCollection services) {
    services.addInstance(TestService());
  }
}

class TestModuleWithCustomInfo extends Module {
  @override
  String get name => 'Test42';

  @override
  String get version => '42.42.42';

  @override
  String get description => 'Test module with custom info';

  @override
  Map<String, Object> get properties {
    return {
      'test': 42,
    };
  }
}

class TestModuleWithBuilder extends Module<TestModuleBuilder> {
  @override
  void configureServices(ServiceCollection services) {
    services.addInstance(TestService());
  }

  @override
  TestModuleBuilder createBuilder(ServiceCollection services) {
    return TestModuleBuilder(services);
  }
}

class TestModuleBuilder extends ModuleBuilder {
  TestModuleBuilder(super.services);

  void addAdditionalServices() {
    services.addInstance(TestService());
  }
}

class TestService {}
