import 'package:dino/src/lifecycle/lifecycle.dart';
import 'package:dino/src/lifecycle/lifecycle_manager.dart';

extension LifecycleManagerExtensions on LifecycleManager {
  /// Initializes the service if it has not been initialized yet.
  Future<void> initialize(Initializable initializable) {
    return process<Initializable>(
      initializable,
      (x) => x.initialize(),
    );
  }

  /// Disposes the service if it has been disposed yet.
  Future<void> dispose(Disposable disposable) {
    return process<Disposable>(
      disposable,
      (x) => x.dispose(),
    );
  }
}
