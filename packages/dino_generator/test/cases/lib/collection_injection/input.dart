import 'package:dino/dino.dart';

part 'input.g.dart';

@service
final class ListConsumer {
  ListConsumer(this.dependency);

  final List<Object> dependency;
}

@service
final class IterableConsumer {
  IterableConsumer(this.dependency);

  final Iterable<Object> dependency;
}
