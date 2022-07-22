import 'package:dino/dino.dart';
import 'package:dino/src/lifecycle/lifecycle_manager_impl.dart';
import 'package:test/test.dart';

class InitializableTestObject implements Initializable {
  int counter = 0;

  @override
  Future<void> initialize() {
    counter++;

    return Future.value();
  }
}

void main() {
  group('LifecycleManager', () {
    test('should initialize single service only once', () {
      final LifecycleManager manager = LifecycleManagerImpl();

      final instance = InitializableTestObject();

      manager.initialize(instance);
      manager.initialize(instance);

      expect(instance.counter, equals(1));
    });
  });
}
