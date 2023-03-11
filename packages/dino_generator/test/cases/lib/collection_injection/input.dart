import 'package:dino/dino.dart';

part 'input.g.dart';

@service
class ListConsumer {
  ListConsumer(this.dependency);

  final List<Object> dependency;
}

@service
class IterableConsumer {
  IterableConsumer(this.dependency);

  final Iterable<Object> dependency;
}
