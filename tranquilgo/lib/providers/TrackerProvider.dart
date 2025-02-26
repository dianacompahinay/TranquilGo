import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
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

  void disposeService() {
    trackerService.disposeService();
  }
}
