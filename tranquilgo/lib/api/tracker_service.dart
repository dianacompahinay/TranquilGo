import 'dart:async';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as perm;

class TrackerService {
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  Future<bool> requestLocationPermission() async {
    var status = await perm.Permission.location.request();
    return status == perm.PermissionStatus.granted;
  }

  Future<LocationData?> getCurrentLocation() async {
    bool hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      return null; // permission denied
    }

    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return null; // GPS service not enabled
      }
    }

    return await _location.getLocation();
  }

  void startLocationUpdates(Function(LocationData) onLocationUpdate) {
    _locationSubscription =
        _location.onLocationChanged.listen(onLocationUpdate);
  }

  void disposeService() {
    _locationSubscription?.cancel(); // cancel the subscription
    _locationSubscription = null;
  }
}
