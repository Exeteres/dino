import 'package:dino/dino.dart';
import 'package:flutter/widgets.dart';

/// Provides a [ServiceProvider] to descendant widgets.
class DinoProvider extends InheritedWidget {
  DinoProvider({
    super.key,
    required this.serviceProvider,
    required super.child,
  });

  final ServiceProvider serviceProvider;

  /// Returns the [ServiceProvider] associated with the specified [BuildContext].
  static ServiceProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<DinoProvider>();

    assert(
      provider != null,
      'ServiceProvider not found in the context. '
      'Please add DinoProvider to the widget tree.',
    );

    return provider!.serviceProvider;
  }

  @override
  bool updateShouldNotify(DinoProvider oldWidget) {
    return serviceProvider != oldWidget.serviceProvider;
  }
}
