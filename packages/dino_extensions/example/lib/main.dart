import 'package:dino/dino.dart';
import 'package:dino_extensions/dino_extensions.dart';

class ApplicationOptions {
  late int answerOfLife;
}

class TestModuleOptions {
  late String apiKey;
}

class TestModuleBuilder extends ModuleBuilder {
  TestModuleBuilder(super.services);

  useApiKey(String apiKey) {
    services.configure<TestModuleOptions>((provider, options) {
      options.apiKey = apiKey;
    });
  }
}

class TestModule extends Module<TestModuleBuilder> {
  @override
  void configureServices(ServiceCollection services) {
    // Define an options for the module
    services.defineOptions((provider) => TestModuleOptions());

    // Configure an already defined application options
    services.configure<ApplicationOptions>((provider, options) {
      options.answerOfLife = 42;
    });
  }

  @override
  TestModuleBuilder createBuilder(ServiceCollection services) {
    return TestModuleBuilder(services);
  }
}

void main() {
  final services = RuntimeServiceCollection();

  // Define application options
  services.defineOptions((provider) => ApplicationOptions());

  // Add a module
  services.addModule<TestModuleBuilder>(
    TestModule(),
    (builder) => builder.useApiKey('1234567890'),
  );

  // Build a root scope
  final rootScope = services.buildRootScope();

  // Resolve application options
  final options = rootScope.serviceProvider.getRequired<ApplicationOptions>();

  print(options.answerOfLife);
}
