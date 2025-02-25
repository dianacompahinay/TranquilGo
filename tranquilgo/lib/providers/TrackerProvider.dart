import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:my_app/api/tracker_service.dart';

class TrackerProvider with ChangeNotifier {
  LocationData? _currentLocation;
  final TrackerService locationService = TrackerService();

  LocationData? get currentLocation => _currentLocation;

  Future<void> fetchCurrentLocation() async {
    locationService.startLocationUpdates((locationData) {
      _currentLocation = locationData;
      notifyListeners();
    });
  }

  void disposeService() {
    locationService.disposeService(); // cleanup when the widget is removed
  }
}
