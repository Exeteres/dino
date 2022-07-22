# Code generation

- [Core library](core-library.md)
- Code generation
  - [Setting up code generation](#setting-up-code-generation)
  - [Conditional registration](#conditional-registration)
  - [Configuration methods](#configuration-methods)
  - [Generic configuration methods](#generic-configuration-methods)
- [Extensions](extensions.md)

---

When we create a service that depends on several others, we usually pass these dependencies through the constructor. This is what is usually called dependency injection:

```dart
class MyService implements Initializable, Disposable {
  MyService(this.dependencyA, this.dependencyB);

  final DependencyA dependencyA;
  final DependencyB dependencyB;

  Future<void> initialize() async {
    // Perform initialization here
  }

  Future<void> dispose() async {
    // Perform disposal here
  }
}
```

To register an implementation for it without using code generation, we would write the following code:

```dart
services.addSingletonFactory(
  (sp) => MyService(
    sp.getRequired<DependencyA>(),
    sp.getRequired<DependencyB>(),
  ),
);

services.addAlias<Initializable, MyService>();
services.addAlias<Disposable, MyService>();
```

Not only did we have to manually pass all the dependencies to the constructor, but we also had to register aliases for its interfaces.

Of course, in order not to force developers to write a lot of boilerplate code, dino provides the ability to use code generation.

### Setting up code generation

To use code generation, you need to add a dev dependency to your project:

```yaml
dev_dependencies:
  dino_generator:
  build_runner:
```

Then you should create `ServiceCollection` in a special way:

```dart
// myfile.dart

import 'package:dino/dino.dart';

import 'myfile.dino.g.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();
}
```

As you may have guessed, the `$ServiceCollection` class does not yet exist and will be generated.

For the generator to recognize this class, several conditions must be met:

- it must be instantiated in a variable assignment expression;
- this variable must be **explicitly** set to the `ServiceCollection` type;
- class name must start with a dollar sign.

You must also import the generated file.

Since we have explicitly specified the type of the `services` variable, we can use IDE autocompletion even when the class has not yet been generated.

Now let's rewrite the registration code from the last example:

```dart
final ServiceCollection services = $ServiceCollection();

services.addSingleton<MyService>();
```

Just one line is enough to register the factory and all aliases.
If you look at the source code of the generated file, you will see that it does the same thing that we would do without using code generation.

Besides `addSingleton` you can also use `addTransient` and `addScoped`.

### Conditional registration

Since dependency registration happens in the ordinary method, you can use the ordinary conditional statements. For example, you can register different implementations of the same service depending on the environment:

```dart
if (isDevelopment) {
  services.addSingleton<DevelopmentMyService>();
} else {
  services.addSingleton<ProductionMyService>();
}
```

The generator will generate descriptors for all possible services, but only those for which the `addSingleton` method will actually be called will be added to the collection.

### Configuration methods

You probably guessed that dependency registration can be moved to separate methods, but does this work with code generation? Of course it works:

```dart
void registerMyService(ServiceCollection services) {
  services.addSingleton<MyService>();
}

void main() {
  final ServiceCollection services = $ServiceCollection();

  registerMyService(services);
}
```

Not only regular methods are supported, but also extension methods:

```dart
extension MyServiceExtension on ServiceCollection {
  void registerMyService() {
    addSingleton<MyService>();
  }
}

void main() {
  final ServiceCollection services = $ServiceCollection();

  services.registerMyService();
}
```

Moreover, these do not have to be local methods - these methods can be imported from various libraries. This allows you to break the application into modules and add only the necessary functionality.

### Generic configuration methods

Configuration methods can also be generic, and use type parameters as services:

```dart
extension on ServiceCollection {
  void addMyService<TCustomImpl extends MyService>() {
    if (TCustomImpl == dynamic) {
      addSingleton<MyServiceImpl>();
    } else {
      addSingleton<TCustomImpl>();
    }
  }
}

Future<void> main() async {
  final ServiceCollection services = $ServiceCollection();

  services.addMyService();

  // or

  services.addMyService<CustomMyServiceImpl>();
}
```

Read next: [Extensions](extensions.md)
