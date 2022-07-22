import 'package:dino/src/lifecycle/lifecycle.dart';
import 'package:dino/src/lifecycle/lifecycle_manager.dart';
import 'package:dino/src/lifecycle/lifecycle_manager_extensions.dart';
import 'package:dino/src/provider/service_provider_extensions.dart';
import 'package:dino/src/provider/service_scope.dart';

extension LifecycleServiceScopeExtensions on ServiceScope {
  /// A [LifecycleManager] instance associated with this [ServiceScope].
  LifecycleManager get lifecycleManager {
    return serviceProvider.getRequired<LifecycleManager>();
  }

  /// Initializes all [Initializable] services in this [ServiceScope].
  Future<void> initialize() async {
    final initializables = serviceProvider.getServiceIterable(
      Initializable,
      true,
    );

    for (var initializable in initializables) {
      await lifecycleManager.initialize(initializable as Initializable);
    }
  }

  /// Disposes all [Disposable] services in this [ServiceScope].
  Future<void> dispose() async {
    // Resolve lifecycle manager before iteration
    // to prevent collection modification
    final _lifecycleManager = lifecycleManager;

    final disposables = createdServices.whereType<Disposable>();

    for (var disposable in disposables) {
      await _lifecycleManager.dispose(disposable);
    }
  }
}
