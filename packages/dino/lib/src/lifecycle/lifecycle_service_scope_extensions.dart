import 'package:dino/src/lifecycle/lifecycle.dart';
import 'package:dino/src/lifecycle/lifecycle_manager.dart';
import 'package:dino/src/lifecycle/lifecycle_manager_extensions.dart';
import 'package:dino/src/provider/service_provider_extensions.dart';
import 'package:dino/src/provider/service_scope.dart';

extension LifecycleServiceScopeExtensions on ServiceScope {
  /// A [LifecycleManager] instance associated with this [ServiceScope].
  LifecycleManager getLifecycleManager() {
    return serviceProvider.getRequired<LifecycleManager>();
  }

  /// Initializes all [Initializable] services in this [ServiceScope].
  Future<void> initialize() async {
    final initializables = serviceProvider.getServiceIterable(
      Initializable,
      true,
    );

    for (final initializable in initializables) {
      await getLifecycleManager().initialize(initializable as Initializable);
    }
  }

  /// Disposes all [Disposable] services in this [ServiceScope].
  Future<void> dispose() async {
    final lifecycleManager = getLifecycleManager();

    final disposables = createdServices.whereType<Disposable>();

    for (final disposable in disposables) {
      await lifecycleManager.dispose(disposable);
    }
  }
}
