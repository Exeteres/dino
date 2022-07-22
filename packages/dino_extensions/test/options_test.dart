import 'package:dino/dino.dart';
import 'package:dino_extensions/dino_extensions.dart';

import 'package:test/test.dart';

void main() {
  group('Options Extensions', () {
    test('should define, configure and resolve options', () {
      final services = RuntimeServiceCollection();

      services.defineOptions((sp) => TestOptions());

      services.configure<TestOptions>((provider, options) {
        options.apiKey = '42';
      });

      final provider = services.buildRootScope().serviceProvider;

      final options = provider.getRequired<TestOptions>();

      expect(options.apiKey, '42');
    });

    test('should define, configure and resolved names options', () {
      final services = RuntimeServiceCollection();

      services.defineOptions((sp) => TestOptions());

      services.configureNamed<TestOptions>('test1', (provider, options) {
        options.apiKey = '42';
      });

      services.configureNamed<TestOptions>('test2', (provider, options) {
        options.apiKey = '24';
      });

      final provider = services.buildRootScope().serviceProvider;

      final optionsProvider =
          provider.getRequired<OptionsProvider<TestOptions>>();

      final options1 = optionsProvider.getRequired('test1');
      final options2 = optionsProvider.getRequired('test2');

      expect(options1.apiKey, '42');
      expect(options2.apiKey, '24');
    });

    test('should throw an exception when configuring undefined options', () {
      final services = RuntimeServiceCollection();

      expect(
        () {
          services.configure<TestOptions>((provider, options) {
            options.apiKey = '42';
          });
        },
        throwsException,
      );
    });
  });
}

class TestOptions {
  late String apiKey;
}
