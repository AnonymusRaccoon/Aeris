import 'package:aeris/src/aeris_api.dart';
import 'package:aeris/src/models/service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

/// Provider used to store every Service the User is authenticated to
class ServiceProvider extends ChangeNotifier {
  /// List of [Service] related to the user
  List<Service> _connectedServices = [];
  List<Service> get connectedServices => _connectedServices;

  /// Get the services the user is not connected to
  List<Service> get disconnectedServices => Service.all()
      .where((element) => !_connectedServices.contains(element))
      .toList();

  ServiceProvider() {
    refreshServices();
  }

  /// Adds a service into the Provider
  addService(Service service, String code) async {
    _connectedServices.add(service);
    if (service != const Service.utils()) {
      GetIt.I<AerisAPI>()
          .connectService(service, code)
          .then((value) => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  /// Refresh services from API
  refreshServices() async {
    _connectedServices = await GetIt.I<AerisAPI>().getConnectedService();
    notifyListeners();
  }

  /// Removes a service from the Provider, and calls API
  removeService(Service service) async {
    _connectedServices.remove(service);
    notifyListeners();
    await GetIt.I<AerisAPI>().disconnectService(service);
  }
}
