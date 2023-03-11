# Code generation

- [Core library](core-library.md)
- Code generation
  - [Setting up code generation](#setting-up-code-generation)

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

Now we can annotate our services with `@service` annotation:

```dart
import 'package:dino/dino.dart';

@service
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

If you run `pub run build_runner build` now, you will see that the generator has created a file called `my_service.g.dart` in the same directory as your service.
This file contains the extension methods that we wrote manually before. Now you can use them in your code:

```dart
services.addMyService(ServiceLifetime.singleton);
```

You can also use the `@Service` annotation to provide the lifetime of the service. In this case, you can omit the lifetime parameter in the `addMyService`.

<!-- TODO describe advanced injection features -->
