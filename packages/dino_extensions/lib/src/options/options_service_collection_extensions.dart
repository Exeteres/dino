import 'package:dino/dino.dart';
import 'package:dino_extensions/src/options/options_manager.dart';
import 'package:dino_extensions/src/options/options_manager_extensions.dart';
import 'package:dino_extensions/src/options/options_manager_impl.dart';
import 'package:dino_extensions/src/options/options_provider.dart';
import 'package:dino_extensions/src/options/options_provider_impl.dart';

extension OptionsServiceCollectionExtensions on ServiceCollection {
  void addOptionsManager() {
    if (!containsService<OptionsManager>()) {
      addSingletonFactory<OptionsManager>((sp) => OptionsManagerImpl(sp));
    }
  }

  void defineOptions<TOptions extends Object>(
    OptionsFactory<TOptions> factory,
  ) {
    addOptionsManager();
    addInstance(factory);
  }

  void configure<TOptions extends Object>(
    OptionsConfigurationAction<TOptions> action,
  ) {
    configureNamed('', action);
  }

  void configureNamed<TOptions extends Object>(
    String name,
    OptionsConfigurationAction<TOptions> action,
  ) {
    if (!containsService<OptionsFactory<TOptions>>()) {
      throw Exception('Options of type $TOptions are not defined');
    }

    addInstance(OptionsConfigurationHandler(name, action));

    addSingletonFactory<OptionsProvider<TOptions>>(
      (provider) => OptionsProviderImpl(
        provider.getRequired<OptionsManager>(),
      ),
    );

    addTransientFactory<TOptions>(
      (provider) =>
          provider.getRequired<OptionsManager>().getRequired<TOptions>(),
    );
  }
}
