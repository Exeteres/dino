import 'package:dino/dino.dart';

class TestObject {}

ServiceScope createServiceScope(List<ServiceDescriptor> descriptors) {
  final services = ServiceCollection();

  services.addAll(descriptors);

  return services.buildRootScope();
}

ServiceProvider createServiceProvider(List<ServiceDescriptor> descriptors) {
  return createServiceScope(descriptors).serviceProvider;
}
