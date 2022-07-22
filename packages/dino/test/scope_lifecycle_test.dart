import 'package:dino/dino.dart';
import 'package:test/test.dart';

import 'utils.dart';

class TestObject implements Initializable, Disposable {
  bool initialized = false;
  bool disposed = false;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

class TestObject2 implements Initializable, Disposable {
  bool initialized = false;
  bool disposed = false;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  group('Scope Lifecycle', () {
    test(
      'should initialize all Initializable singleton services in root scope',
      () async {
        final rootScope = createServiceScope([
          ServiceDescriptor.factory(
            ServiceLifetime.singleton,
            (sp) => TestObject(),
          ),
          ServiceDescriptor.alias<Initializable, TestObject>(),
        ]);

        await rootScope.initialize();

        final instance = rootScope.serviceProvider.getRequired<TestObject>();

        expect(instance.initialized, isTrue);
      },
    );

    test(
      'should initialize all Initializable scopes servies in scope',
      () async {
        final rootScope = createServiceScope([
          ServiceDescriptor.factory(
            ServiceLifetime.singleton,
            (sp) => TestObject(),
          ),
          ServiceDescriptor.factory(
            ServiceLifetime.scoped,
            (sp) => TestObject2(),
          ),
          ServiceDescriptor.alias<Initializable, TestObject>(),
          ServiceDescriptor.alias<Initializable, TestObject2>(),
        ]);

        final scope = rootScope.serviceProvider.createScope();

        await scope.initialize();

        final scoped = scope.serviceProvider.getRequired<TestObject2>();
        final singleton = rootScope.serviceProvider.getRequired<TestObject>();

        expect(scoped.initialized, isTrue);
        expect(singleton.initialized, isFalse);
      },
    );

    test(
      'should dispose all created singleton Disposable services in root scope',
      () async {
        final rootScope = createServiceScope([
          ServiceDescriptor.factory(
            ServiceLifetime.singleton,
            (sp) => TestObject(),
          )
        ]);

        final instance = rootScope.serviceProvider.getRequired<TestObject>();

        await rootScope.dispose();

        expect(instance.disposed, isTrue);
      },
    );
  });
}
