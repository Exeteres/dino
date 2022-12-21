import 'package:dino/dino.dart';
import 'package:dino_extensions/dino_extensions.dart';

/// The global application options that
/// should be configured by multiple modules.
class ApplicationOptions {
  late int answerOfLife;
}

/// The options of the [TestModule] that
/// should be used and configured mostly by the module itself.
class TestModuleOptions {
  late String apiKey;
}

class TestModule extends Module {
  TestModule({
    required this.apiKey,
  });

  final String apiKey;

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
  void configureInstanceServices(ServiceCollection services) {
    // Configure test module options for the current instance
    services.configure<TestModuleOptions>((provider, options) {
      options.apiKey = apiKey;
    });
  }
}

void main() {
  final services = RuntimeServiceCollection();

  // Define application options
  services.defineOptions((provider) => ApplicationOptions());

  // Add a module
  services.addModule(
    TestModule(
      apiKey: '1234567890',
    ),
  );

  // If we add another instance of this module,
  // it will replace the apiKey option
  services.addModule(
    TestModule(
      apiKey: '0987654321',
    ),
  );

  // Build a root scope
  final rootScope = services.buildRootScope();

  // Resolve application options
  final options = rootScope.serviceProvider.getRequired<ApplicationOptions>();

  print(options.answerOfLife);
}
