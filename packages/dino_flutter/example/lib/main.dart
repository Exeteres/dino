import 'package:dino/dino.dart';
import 'package:dino_flutter/dino_flutter.dart';
import 'package:flutter/material.dart';

final class Calculator {
  int sum(int a, int b) => a + b;
}

Future<void> main() async {
  final services = ServiceCollection();

  services.addInstance(Calculator());

  final scope = services.buildRootScope();
  await scope.initialize();

  runApp(
    DinoProvider(
      serviceProvider: scope.serviceProvider,
      child: const Application(),
    ),
  );
}

final class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dino Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final calculator = context.sp.getRequired<Calculator>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dino Flutter Example'),
      ),
      body: Center(
        child: Text('${calculator.sum(1, 2)}'),
      ),
    );
  }
}
