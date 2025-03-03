import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_app/api/tracker_service.dart';
import 'package:my_app/providers/ActivityProvider.dart';

class TrackerProvider with ChangeNotifier {
  LocationData? _currentLocation;
  final TrackerService trackerService = TrackerService();
  final ActivityProvider activityProvider = ActivityProvider();

  int stepCount = 0;
  double distance = 0.0;
  bool isFetching = true;
  double _progress = 0.0;
  int _targetSteps = 0;

  LatLng? _suggestedDestination;
  List<LatLng> routePoints = [];
  bool isFetchingRoute = false;

  LatLng? get suggestedDestination => _suggestedDestination;
  LocationData? get currentLocation => _currentLocation;
  double? get progress => _progress;
  int? get targetSteps => _targetSteps;

  void resetValues(String userId) async {
    stepCount = 0;
    distance = 0.0;
    isFetching = false;
    _progress = 0.0;
    _targetSteps = await activityProvider.getTargetSteps(userId);
  }

  Future<void> fetchCurrentLocation() async {
    trackerService.startLocationUpdates((locationData) {
      _currentLocation = locationData;
      notifyListeners();
    });
  }

  Future<void> fetchStepAndDistance() async {
    isFetching = true;
    notifyListeners();

    final data = await trackerService.fetchStepAndDistance();

    stepCount = data["steps"];
    distance = data["distance"];
    _progress = (stepCount / _targetSteps).clamp(0.0, 1.0);

    isFetching = false;
    notifyListeners();
  }

  void startFallbackTracking() {
    trackerService.startFallbackStepTracking();
    Timer.periodic(const Duration(seconds: 2), (timer) {
      stepCount = trackerService.stepCount;
      distance = trackerService.distance;
      notifyListeners();
    });
  }

  // estimates distance based on target steps
  double estimateDistanceFromSteps(int targetSteps) {
    const double strideLengthKm = 0.0008; // 0.8m per step (converted to km)
    return targetSteps * strideLengthKm;
  }

  // suggests a destination based on estimated distance
  LatLng estimateDestination(LatLng currentLocation, double distanceKm) {
    const double earthRadiusKm = 6371.0; // earth's radius

    double deltaLat = (distanceKm / earthRadiusKm) * (180 / pi);
    double deltaLng = deltaLat / cos(currentLocation.latitude * pi / 180);

    return LatLng(
      currentLocation.latitude + deltaLat,
      currentLocation.longitude + deltaLng,
    );
  }

  // suggests a route based on user's target steps
  Future<void> suggestRoute(int targetSteps, LatLng currentLocation) async {
    isFetchingRoute = true;
    notifyListeners();

    try {
      double estimatedDistance = estimateDistanceFromSteps(targetSteps);
      _suggestedDestination =
          estimateDestination(currentLocation, estimatedDistance);

      if (_suggestedDestination != null) {
        routePoints = await trackerService.fetchRoute(
            currentLocation, _suggestedDestination!);
        print("Suggested route fetched!");
      } else {
        print("Failed to calculate a destination.");
      }
    } catch (e) {
      print("Error suggesting route: $e");
    }

    isFetchingRoute = false;
    notifyListeners();
  }

  void disposeService() {
    trackerService.disposeService();
  }
}
