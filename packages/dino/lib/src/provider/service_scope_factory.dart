import 'package:dino/src/provider/service_scope.dart';

/// A factory for creating [ServiceScope] instances.
abstract class ServiceScopeFactory {
  /// Creates a new [ServiceScope].
  ServiceScope createScope();
}
