import 'package:dino_extensions/src/options/options_manager.dart';
import 'package:dino_extensions/src/options/options_provider.dart';

/// This is an internal API that is not intended for use by developers.
///
/// It may be changed or removed without notice.
class OptionsProviderImpl<TOptions extends Object>
    implements OptionsProvider<TOptions> {
  OptionsProviderImpl(this._optionsManager);
  final OptionsManager _optionsManager;

  @override
  TOptions? get([String name = '']) {
    return _optionsManager.get<TOptions>(name);
  }
}
