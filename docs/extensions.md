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

It is guaranteed that `configureServices` method will be called only once, even if the module of the same type is added multiple times.

There are also another method `configureInstanceServices` that allows you to configure services for a specific instance of the module:

```dart
class TestModule extends Module {
  TestModule({
    required this.apiKey,
  })

  final String apiKey;

  @override
  void configureServices(ServiceCollection services) {
    services.addInstance(TestService());
  }

  @override
  void configureInstanceServices(ServiceCollection services) {
    services.configure<TestOptions>((provider, options) {
      options.apiKey = apiKey;
    });
  }
}

void main() {
  final ServiceCollection services = ServiceCollection();

  services.addModule(
    TestModule(
      apiKey: '0123456789',
    ),
  );

  services.addModule(
    TestModule(
      apiKey: '9876543210',
    ),
  );
}
```

Unlike `configureServices`, `configureInstanceServices` will be called every time a module is added.

In this case, repeated calls to `addModule` will result in multiple changes to the application configuration.
The last call will set the final value of the `apiKey` field, but you can define your own logic for handling such cases.
For example, you can merge options or even add support for using multiple modules with completely independent configurations.
