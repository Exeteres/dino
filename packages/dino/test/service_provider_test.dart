import 'package:dino/dino.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('ServiceProvider', () {
    test('should resolve singleton instance', () {
      final expectedInstance = TestObject();

      final provider = createServiceProvider([
        ServiceDescriptor.instance(expectedInstance),
      ]);

      final instance = provider.get<TestObject>();

      expect(instance, equals(expectedInstance));
    });

    test('should resolve singleton by factory', () {
      final expectedInstance = TestObject();

      final provider = createServiceProvider([
        ServiceDescriptor.factory(
          ServiceLifetime.singleton,
          (sp) => expectedInstance,
        ),
      ]);

      final instance = provider.get<TestObject>();

      expect(instance, equals(expectedInstance));
    });

    test('should resolve transient instance', () {
      final provider = createServiceProvider([
        ServiceDescriptor.factory(
          ServiceLifetime.transient,
          (sp) => TestObject(),
        ),
      ]);

      final instance1 = provider.get<TestObject>();
      final instance2 = provider.get<TestObject>();

      expect(instance1, isNot(instance2));
    });
  });

  group('Scoped ServiceProvider', () {
    test('should resolve scoped service from different scopes', () {
      final rootServiceProvider = createServiceProvider([
        ServiceDescriptor.factory(
          ServiceLifetime.scoped,
          (sp) => TestObject(),
        ),
      ]);

      final scope1 = rootServiceProvider.createScope();

      final instance1 = scope1.serviceProvider.get<TestObject>();
      final instance2 = scope1.serviceProvider.get<TestObject>();

      final scope2 = rootServiceProvider.createScope();

      final instance3 = scope2.serviceProvider.get<TestObject>();
      final instance4 = scope2.serviceProvider.get<TestObject>();

      expect(instance1, equals(instance2));
      expect(instance3, equals(instance4));

      expect(instance1, isNot(equals(instance3)));
    });

    test(
      'should throw an exception when resolving scoped service from root scope',
      () async {
        final rootServiceProvider = createServiceProvider([
          ServiceDescriptor.factory(
            ServiceLifetime.scoped,
            (sp) => TestObject(),
          ),
        ]);

        expect(
          () => rootServiceProvider.get<TestObject>(),
          throwsException,
        );
      },
    );

    test('should resolve singleton service from scope', () async {
      final rootServiceProvider = createServiceProvider([
        ServiceDescriptor.factory(
          ServiceLifetime.singleton,
          (sp) => TestObject(),
        ),
      ]);

      final scope1 = rootServiceProvider.createScope();
      final scope2 = rootServiceProvider.createScope();

      final instance1 = scope1.serviceProvider.get<TestObject>();
      final instance2 = scope2.serviceProvider.get<TestObject>();

      expect(instance1, equals(instance2));
    });
  });
}
