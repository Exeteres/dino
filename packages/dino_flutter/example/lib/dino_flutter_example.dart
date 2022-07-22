import 'package:flutter/material.dart';

import 'package:dino/dino.dart';
import 'package:dino_flutter/dino_flutter.dart';

class Calculator {
  int sum(int a, int b) => a + b;
}

Future<void> main() async {
  final ServiceCollection services = RuntimeServiceCollection();
  services.addInstance(Calculator());

  final scope = services.buildRootScope();
  await scope.initialize();

  runApp(
    DinoProvider(
      serviceProvider: scope.serviceProvider,
      child: Application(),
    ),
  );
}

class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dino Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final calculator = context.serviceProvider.getRequired<Calculator>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dino Flutter Example'),
      ),
      body: Center(
        child: Text('${calculator.sum(1, 2)}'),
      ),
    );
  }
}
