import 'package:dino/src/collection/service_descriptor.dart';

/// The annotation used to mark a class as a service that
/// can inject dependencies through the constructor.
class Service {
  const Service([this.lifetime]);

  final ServiceLifetime? lifetime;
}

/// The annotation used to mark a class as a service that
/// can inject dependencies through the constructor.
const service = Service();
