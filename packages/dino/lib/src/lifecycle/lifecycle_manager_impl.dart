import 'dart:collection';

import 'package:dino/src/lifecycle/lifecycle_manager.dart';

/// This is an internal API that is not intended for use by developers.
///
/// It may be changed or removed without notice.
class LifecycleManagerImpl implements LifecycleManager {
  final Map<Type, HashSet<Object>> _serviceSets = {};

  @override
  Future<void> process<TService extends Object>(
    TService service,
    Future<void> Function(TService) operation,
  ) async {
    var serviceSet = _serviceSets[TService];

    if (serviceSet == null) {
      serviceSet = HashSet();
      _serviceSets[TService] = serviceSet;
    }

    if (!serviceSet.contains(service)) {
      serviceSet.add(service);
      await operation(service);
    }
  }
}
