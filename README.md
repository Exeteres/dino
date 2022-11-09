<p align="center">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Exeteres/dino/master/docs/assets/logo-dark.png">
  <img alt="Logo" src="https://raw.githubusercontent.com/Exeteres/dino/master/docs/assets/logo-light.png" width="250">
</picture>
</p>
<br/>

Dino is a Dart dependency injection library with optional code generation.
It was inspired by [DI in .NET](https://docs.microsoft.com/en-us/dotnet/core/extensions/dependency-injection) and aimed to be flexible, predictable and easy to use.

### Quick start

> It is assumed that you have a basic understanding of [dependency injection](https://en.wikipedia.org/wiki/Dependency_injection).

Suppose we have multiple services dependent on each other:

```dart
class Repository {
  Repository(this.restClient);
  final RestClient restClient;

  Future<void> sendMessage(String message) async {
    try {
      await restClient.sendMessage(message);
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}

class RestClient {
  RestClient(this.dio);
  final Dio dio;

  Future<void> sendMessage(String message) async {
    await dio.post('/api/message', data: {'message': message});
  }
}
```

Then their registration in dino will look like this:

```dart
void main() {
  final ServiceCollection services = RuntimeServiceCollection();

  services.addInstance(Dio());

  services.addSingletonFactory(
    (sp) => RestClient(
      dio: sp.getRequired<Dio>(),
    ),
  );

  services.addSingletonFactory(
    (sp) => Repository(
      restClient: sp.getRequired<RestClient>(),
    ),
  );
}
```

If we add code generation using dino_generator, then the code will become even nicer:

```dart
import 'main.dino.g.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();

  services.addInstance(Dio());
  services.addSingleton<RestClient>();
  services.addSingleton<Repository>();
}
```

Now we can use registered services:

```dart
final rootScope = services.buildRootScope();

final repository = rootScope.serviceProvider.getRequired<Repository>();
repository.sendMessage('Hello world!');
```

You can also use dino in flutter with `dino_flutter` package:

```dart
void main() {
  final ServiceCollection services = $ServiceCollection();

  services.addInstance(Dio());
  services.addSingleton<RestClient>();
  services.addSingleton<Repository>();

  final rootScope = services.buildRootScope();

  runApp(
    DinoProvider(
      serviceProvider: scope.serviceProvider,
      child: Application(),
    ),
  );
}
```

Then you can use the `ServiceProvider` from the `BuildContext`:

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final repository = context.sp.getRequired<Repository>();

    // build widget
  }
}
```

For a better understanding of concepts such as `ServiceCollection`, `ServiceScope`, and `ServiceProvider`, and to learn more about dino, you can check out the detailed documentation.

### Documentation

- [Core library](https://github.com/Exeteres/dino/blob/master/docs/core-library.md)
- [Code generation](https://github.com/Exeteres/dino/blob/master/docs/code-generation.md)
- [Extensions](https://github.com/Exeteres/dino/blob/master/docs/extensions.md)

### Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

### License

[MIT](https://choosealicense.com/licenses/mit/)
