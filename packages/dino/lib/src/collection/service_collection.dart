import 'dart:collection';

import 'package:dino/src/collection/service_descriptor.dart';
import 'package:dino/src/lifecycle/lifecycle_registration_helper.dart';

/// A collection of service descriptors.
class ServiceCollection extends ListBase<ServiceDescriptor>
    implements List<ServiceDescriptor> {
  ServiceCollection() {
    LifecycleRegistrationHelper.addLifecycleManager(this);
  }

  final List<ServiceDescriptor> _descriptors = [];

  @override
  int get length => _descriptors.length;

  @override
  set length(int newLength) {
    _descriptors.length = newLength;
  }

  @override
  ServiceDescriptor operator [](int index) {
    return _descriptors[index];
  }

  @override
  void operator []=(int index, ServiceDescriptor value) {
    _descriptors[index] = value;
  }

  @override
  void add(ServiceDescriptor element) {
    _descriptors.add(element);
  }

  @override
  void addAll(Iterable<ServiceDescriptor> iterable) {
    _descriptors.addAll(iterable);
  }
}
