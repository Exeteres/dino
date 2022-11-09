import 'package:dino/dino.dart';
import 'package:dino_flutter/src/widgets/dino_provider.dart';
import 'package:flutter/widgets.dart';

extension DinoFlutterBuildContextExtensions on BuildContext {
  /// The [ServiceProvider] associated with this [BuildContext].
  ServiceProvider get sp => DinoProvider.of(this);
}
