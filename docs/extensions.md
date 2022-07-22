# Extensions

- [Core library](core-library.md)
- [Code generation](code-generation.md)
- Extensions
  - [Options](#options)
  - [Modularity](#modularity)

---

Dino was designed with extensibility in mind. Many useful extensions that you will most likely want to use in your applications you can find in the `dino_extensions` package.

### Options

Dino extensions provides options mechanism that allows different parts of your application to be configured:

```dart
class TestOptions {
  late String apiKey;
}

void main() {
  final services = RuntimeServiceCollection();

  services.defineOptions((sp) => TestOptions());

  services.configure<TestOptions>((provider, options) {
    options.apiKey = '42';
  });

  final provider = services.buildRootScope().serviceProvider;

  final options = provider.getRequired<TestOptions>();
}
```

In this example we define an options class `TestOptions` and then configure it by setting field value.
Options should be defined only once, but it is possible to configure it multiple times.
Thus, different configuration methods can make changes to the application configuration and most likely will not conflict.

You can also configure named options:

```dart
final services = RuntimeServiceCollection();

services.defineOptions((sp) => TestOptions());

services.configureNamed<TestOptions>('test1', (provider, options) {
  options.apiKey = '42';
});

services.configureNamed<TestOptions>('test2', (provider, options) {
  options.apiKey = '24';
});

final provider = services.buildRootScope().serviceProvider;

final optionsProvider =
    provider.getRequired<OptionsProvider<TestOptions>>()

final options1 = optionsProvider.getRequired('test1');
final options2 = optionsProvider.getRequired('test2');
```

In this case you should use `OptionsProvider` to get options of the specified name.

> Unnamed options are just named options with empty ('') name.

### Modularity

To simplify modular development, dino provides a way to create and use modules:

```dart
class TestModule extends Module {
  @override
  void configureServices(ServiceCollection services) {
    services.addInstance(TestService());
  }
}

void main() {
  final ServiceCollection services = ServiceCollection();

  services.addModule(TestModule());
}
```

A module of the same type can only be added once. Repeated calls to `addModule` will not change anything. Accordingly, it is guaranteed that its `configureServices` method will also be called only once.

Module can also accept additional configuration using module builder:

```dart
class TestModule extends Module {
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
  ModuleBuilder(ServiceCollection services) : super(services);

  void addAdditionalServices() {
    services.addInstance(AdditionalTestService());
  }

  void useApiKey(String apiKey) {
    services.configure<TestOptions>((provider, options) {
      options.apiKey = apiKey;
    });
  }
}

void main() {
  final ServiceCollection services = ServiceCollection();

  services.addModule<TestModuleBuilder>(
    TestModule(),
    (b) => b
      ..addAdditionalServices()
      ..useApiKey('42'),
  );
}
```

Unlike `configureServices`, additional configuration builder can be called multiple times.
