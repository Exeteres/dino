# Core library

- Core library
  - [Registering services](#registering-services)
  - [Using services](#using-services)
  - [Lifecycle management](#lifecycle-management)
  - [Multiple registrations](#multiple-registrations)
  - [Nested scopes](#nested-scopes)
- [Code generation](code-generation.md)

---

Dino is splitted into multiple packages:

- `dino`: the runtime library (required);
- `dino_generator`: the code generation library (optional);
- `dino_extensions`: the set of useful extensions (optional).

In this section we will only discuss the runtime library.

### Registering services

The process of using dino consists of two phases: registering dependencies and using them.

On the first phase, you create and use a `ServiceCollection` - a collection of something called `ServiceDescriptor`. The `ServiceDescriptor` is a class that contains an information about service, it's lifetime and how service it is implemented.

In dino there are three types of service lifetimes:

- `singleton`: the service is created once and is shared between all scopes;
- `transient`: the service is created on each resolution (`serviceProvider.get()` call);
- `scoped`: the service is created for each scope.

If you are building a simple flutter application, you will most likely only use singleton and transient services.
If you need to process some requests, for example, if you create a web server, then scoped services will also be useful to you.

Services could be implemented in multiple ways:

- `factory`: the service is created by a factory function;
- `instance`: the service use an existing instance (only for singletons);
- `alias`: the service is resolved by an alias to another service.

To register services of various types, you should use various extensions on `ServiceCollection`:

```dart
// Register a singleton service by existing instance
services.addInstance(MyService());

// Register a singleton service by factory function
services.addSingletonFactory((sp) => MyService());

// Register a scoped service by factory function
services.addScopedFactory((sp) => MyService());

// Register a transient service by factory function
services.addTransientFactory((sp) => MyService());

// Register a service by alias to another service
services.addAlias<MyService, MyOtherService>();
```

All factories accept a `ServiceProvider` as a parameter in order to resolve dependencies. Next we will see how it can be used.

> Note that all services are created lazily and synchronously. This feature allows the dino to be simple and predictable.

### Using services

The second phase is to use services. To do that, you need to create a `ServiceScope` - a container for services. The `ServiceScope` instances contains something called `ServiceProvider` which is a class that provides access to services.

The first scope you create is the root scope. This scope will contain all singleton services. You can create it from service collection:

```dart
final rootScope = services.buildRootScope();
```

To get a service from the scope, you should use `ServiceProvider`:

```dart
final service = rootScope.serviceProvider.getRequired<MyService>();
```

If you are not sure that the service of the required type is available, you can use the `get` method. In this case the return value will be nullable.

### Lifecycle management

As you already know, all services in dino are lazy and synchronous. But some services need to perform certain asynchronous operations in order to initialize themselves. To do this, dino provides a mechanism for centralized initialization.

To support initialization service must implement `Initializable` interface:

```dart
class Myservice implements Initializable {
  Future<void> initialize() async {
    // Perform initialization here
  }
}
```

To initialize all services in the scope, you can use `ServiceScope.initialize` method. To initialize all singleton services, you should call this method on the root scope:

```dart
await rootScope.initialize();
```

In some cases it is important to initialize services in the correct order. For example, if you have a service that depends on another service, you should initialize the dependent service first.

To achieve this, you should manually initialize a dependent service using `LifecycleManager` service:

```dart
class Dependency implements Initializable {
  Future<void> initialize() async {
    // Perform initialization here
  }
}

class MyService implements Initializable {
  MyService(this.lifecycleManager, this.dependency);

  final LifecycleManager lifecycleManager;
  final Dependency dependency;

  Future<void> initialize() async {
    await lifecycleManager.initialize(dependency);

    // Perform initialization here
  }
}
```

Using `LifecycleManager` avoids re-initialization of the service in case it is initialized earlier.

Your services can also implement `Disposable` interface. To dispose services, you should call `dispose` method on the `ServiceScope`.

So the full lifecycle of a scope might look something like this:

```dart
final rootScope = services.buildRootScope();

// Initialize services
await rootScope.initialize();

try {
  // Use services
  doSomething(rootScope.serviceProvider);
} finally {
  // Dispose services
 await rootScope.dispose();
}
```

### Multiple registrations

You can register multiple services of the same type. This is useful if you need to add the ability to extend your application.

For example, we are making a system that checks an application for viruses using several virus checkers. Then we can make a universal interface for the virus checker and register several implementations for it:

```dart
abstract class VirusChecker {
  Future<bool> check(String filePath);
}

class Checker1 implements VirusChecker {
  Future<bool> check(String filePath) async {
    // Perform check here
  }
}

class Checker2 implements VirusChecker {
  Future<bool> check(String filePath) async {
    // Perform check here
  }
}

void main() {
  final services = RuntimeServiceCollection();

  services.addSingletonFactory<VirusChecker>((sp) => Checker1());
  services.addSingletonFactory<VirusChecker>((sp) => Checker2());

  final rootScope = services.buildRootScope();

  final checkers = rootScope.serviceProvider.getMany<VirusChecker>();

  for (final checker in checkers) {
    if (await checker.check('file.exe')) {
      print('Virus found!');
      return;
    }
  }

  print('No viruses found.');
}
```

This way you can add new virus checkers without changing the code that uses them.

### Nested scopes

You can create nested scopes. This is useful if you need to create a scope for a specific request. To create nested scope, you should use `ServiceProvider`:

```dart
final requestScope = serviceProvider.createScope();

// Use services in the scope
handleRequest(requestScope.serviceProvider);
```

Read next: [Code generation](code-generation.md)
