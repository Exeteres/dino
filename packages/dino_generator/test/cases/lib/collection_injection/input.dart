import 'package:dino/dino.dart';

import 'package:generator_test_cases/collection_injection/output.dart';

void main() {
  final ServiceCollection services = $ServiceCollection();

  services.addSingleton<ListConsumer>();
  services.addSingleton<IterableConsumer>();
}

class ListConsumer {
  ListConsumer(this.dependency);

  final List<Object> dependency;
}

class IterableConsumer {
  IterableConsumer(this.dependency);

  final Iterable<Object> dependency;
}
