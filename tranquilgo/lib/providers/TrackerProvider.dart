import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_app/api/tracker_service.dart';
import 'package:my_app/providers/ActivityProvider.dart';
import 'package:location/location.dart' as loc;
import 'package:latlong2/latlong.dart' as latlong;
import 'landmarks.dart';

class TrackerProvider with ChangeNotifier {
  LocationData? _currentLocation;
  final TrackerService trackerService = TrackerService();
  final ActivityProvider activityProvider = ActivityProvider();

  Stream<loc.LocationData>? locationStream;

  Timer? timer;
  int timeDuration = 0;
  String displayTime = '0:00:00';
  int stepCount = 0;
  double distance = 0.0;
  bool isFetching = true;
  double progress = 0.0;
  int targetSteps = 0;

  LatLng? _suggestedDestination;
  List<LatLng> routePoints = [];
  List<LatLng> userRoutePoints = [];

  bool isFetchingRoute = false;
  bool isStarted = false;

  List<Map<String, dynamic>> _suggestions = [];

  String _startLocationName = "";
  String _destinationLocationName = "";

  double _currentSpeed = 0.0;
  bool isTrackingPaused = false;

  double get currentSpeed => _currentSpeed;

  LatLng? get suggestedDestination => _suggestedDestination;
  LocationData? get currentLocation => _currentLocation;
  String? get startLocationName => _startLocationName;
  String? get destinationLocationName => _destinationLocationName;
  List<Map<String, dynamic>>? get suggestions => _suggestions;

  final String placesApiKey = "AIzaSyAF97pejfG-jgwBotC2RVB0wj2-Tbn6SSU";

  void resetValues(String userId) async {
    timeDuration = 0;
    displayTime = '0:00:00';
    stepCount = 0;
    distance = 0.0;
    isFetching = false;
    progress = 0.0;

    trackerService.resetValues();
    targetSteps = await activityProvider.getTargetSteps(userId);
    isTrackingPaused = false;
    isStarted = false;

    _suggestedDestination = null;
    isFetchingRoute = false;
    _startLocationName = "";
    _destinationLocationName = "";
    routePoints.clear();
    userRoutePoints.clear();

    locationStream = null;
    trackerService.resetValues();
    timer?.cancel();
  }

  Future<void> requestPlatformPermissions() async {
    if (Platform.isAndroid) {
      final isIgnoring =
          await FlutterForegroundTask.isIgnoringBatteryOptimizations;

      if (isIgnoring == false) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  }

  void startTimer() {
    // cancel any existing timer to avoid duplicates
    FlutterForegroundTask.updateService(
      notificationTitle: "Pedometer Service",
      notificationText:
          "Steps: $stepCount, Distance: ${distance.toStringAsFixed(2)} km, Time: $displayTime",
    );

    timer?.cancel(); // ensure no duplicate timers
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeDuration++;
      displayTime = formatDuration(timeDuration);
      notifyListeners();
      FlutterForegroundTask.updateService(
        notificationTitle: "Pedometer Service",
        notificationText:
            "Steps: $stepCount, Distance: ${distance.toStringAsFixed(2)} km, Time: $displayTime",
      );
    });
  }

  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    return "${hours.toString()}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  Future<void> stop() async {
    final ServiceRequestResult result =
        await FlutterForegroundTask.stopService();

    if (result is ServiceRequestFailure) {
      throw result.error;
    }
  }

  void monitorSpeed() {
    const double maxWalkingSpeed = 9.0; // 9 km/h
    int highSpeedCount = 0; // track consecutive high-speed occurrences

    trackerService.monitorSpeed((speedMps) {
      double speedKph = speedMps * 3.6; // convert to km/h
      _currentSpeed = speedKph;
      notifyListeners();

      if (speedKph > maxWalkingSpeed) {
        highSpeedCount++;
      } else {
        highSpeedCount = 0; // reset count when back to normal speed
      }

      if (highSpeedCount >= 3) {
        isTrackingPaused = true;
        pauseTracking();
      }
    });
  }

  void startRealTimeTracking() {
    locationStream = trackerService.location.onLocationChanged;

    // start tracking movement
    trackUserRoute(locationStream!);

    trackerService.startTracking((int newSteps, double newDistance) {
      stepCount = newSteps;
      distance = newDistance;
      progress = newSteps / targetSteps;
      notifyListeners();
    });
  }

  void pauseTracking() {
    timer?.cancel();
    trackerService.accelerometerSubscription?.cancel();
    trackerService.locationSubscription?.cancel();
  }

  void resumeTracking() {
    isTrackingPaused = false;
    startTimer();
    startRealTimeTracking();
  }

  Future<void> fetchCurrentLocation() async {
    trackerService.startLocationUpdates((locationData) {
      _currentLocation = locationData;
      notifyListeners();
    });
  }

  // estimates distance based on target steps
  double estimateDistanceFromSteps(int targetSteps) {
    const double strideLengthKm = 0.0004;
    return targetSteps * strideLengthKm;
  }

  // suggests a randomized destination based on estimated distance
  LatLng estimateDestination(LatLng currentLocation, double distanceKm) {
    const double earthRadiusKm = 6371.0; // Earth's radius

    // randomize the direction angle (0 to 360 degrees)
    double randomAngle = Random().nextDouble() * 360;
    double radianAngle = randomAngle * pi / 180;

    double deltaLat = (distanceKm / earthRadiusKm) * (180 / pi);
    double deltaLng = deltaLat / cos(currentLocation.latitude * pi / 180);

    // apply random direction
    return LatLng(
      currentLocation.latitude + deltaLat * sin(radianAngle),
      currentLocation.longitude + deltaLng * cos(radianAngle),
    );
  }

  Future<void> getCurrentLocName(LocationData currentLocation) async {
    LatLng currentLatLng = LatLng(
      currentLocation.latitude!,
      currentLocation.longitude!,
    );
    try {
      _startLocationName = await trackerService.getPlaceName(currentLatLng);
    } catch (e) {
      throw Exception("Failed to fetch location name");
    }
  }

  bool isWithinUPLB(LatLng currentLocation) {
    // define UPLB bounding box (approximate)
    const double minLat = 14.155, maxLat = 14.180;
    const double minLng = 121.235, maxLng = 121.270;

    bool isWithinUPLB = (currentLocation.latitude >= minLat &&
        currentLocation.latitude <= maxLat &&
        currentLocation.longitude >= minLng &&
        currentLocation.longitude <= maxLng);

    return isWithinUPLB;
  }

  // suggests a route based on user's target steps
  Future<void> suggestRoute(int targetSteps, LatLng currentLocation) async {
    isFetchingRoute = true;
    notifyListeners();

    try {
      double estimatedDistance = estimateDistanceFromSteps(targetSteps);

      if (isWithinUPLB(currentLocation)) {
        if (uplbLandmarks.isNotEmpty) {
          double estimatedDistanceMeters = estimatedDistance * 1000;

          List<Map<String, dynamic>> validLandmarks = [];

          for (var landmark in uplbLandmarks) {
            LatLng landmarkLocation = LatLng(landmark["lat"], landmark["lng"]);
            double distance = trackerService.calculateDistance(
                currentLocation.latitude,
                currentLocation.longitude,
                landmarkLocation.latitude,
                landmarkLocation.longitude);

            // filter landmark based on distance
            if (distance <= estimatedDistanceMeters &&
                distance > estimatedDistanceMeters / 2) {
              validLandmarks.add({"landmark": landmark, "distance": distance});
            }
          }

          if (validLandmarks.isNotEmpty) {
            // make filtered landmarks random
            validLandmarks.shuffle();

            Map<String, dynamic> chosenLandmark =
                validLandmarks.first["landmark"];

            _suggestedDestination =
                LatLng(chosenLandmark["lat"], chosenLandmark["lng"]);
            _destinationLocationName = chosenLandmark["name"];
          }
        }
      }

      if (_suggestedDestination == null) {
        // get random destination based on the target steps
        LatLng randomDest =
            estimateDestination(currentLocation, estimatedDistance);

        // if not in UPLB, use google maps API to find a general landmark
        _suggestedDestination =
            await trackerService.findClosestLandmark(randomDest);
        _destinationLocationName =
            await trackerService.getPlaceName(_suggestedDestination!);
      }

      // fetch route if a valid destination was found
      if (_suggestedDestination != null) {
        routePoints = await trackerService.fetchRoute(
            currentLocation, _suggestedDestination!);
      }
      // get place name for start location
      _startLocationName = await trackerService.getPlaceName(currentLocation);
    } catch (e) {
      throw Exception("Error suggesting route: $e");
    }

    isFetchingRoute = false;
    notifyListeners();
  }

  Future<void> trackUserRoute(Stream<LocationData> locationStream) async {
    locationStream.listen((locData) async {
      if (locData.latitude != null && locData.longitude != null) {
        LatLng newPoint = LatLng(locData.latitude!, locData.longitude!);

        // add to user route list if it is a significant move
        if ((userRoutePoints.isEmpty || isSignificantMove(newPoint)) &&
            isStarted) {
          userRoutePoints.add(newPoint);

          // update route points when current location changes
          if (_suggestedDestination != null) {
            routePoints = await trackerService.fetchRoute(
                newPoint, _suggestedDestination!);
          }
          notifyListeners();
        }
      }
    }, onError: (e) {
      print("Error tracking user route: $e");
    });
  }

  bool checkUserOnRoute(LatLng currentLocation) {
    if (routePoints.isEmpty) return false;

    latlong.Distance distance = const latlong.Distance();
    const double deviationThreshold = 15.0; // in meters
    for (LatLng point in routePoints) {
      double dist = distance(
        latlong.LatLng(currentLocation.latitude, currentLocation.longitude),
        latlong.LatLng(point.latitude, point.longitude),
      );
      if (dist <= deviationThreshold) {
        return true; // user is still following the route
      }
    }
    return false; // user is far away from the route
  }

  bool isSignificantMove(LatLng newPoint) {
    if (userRoutePoints.isEmpty) return true;

    LatLng lastPoint = userRoutePoints.last;
    double distanceMoved = trackerService.calculateDistance(lastPoint.latitude,
        lastPoint.longitude, newPoint.latitude, newPoint.longitude);

    return distanceMoved > 1; // only log movement if > 1 meters
  }

  void clearSuggestions() {
    _suggestions = [];
  }

  void disposeService() {
    trackerService.disposeService();
    FlutterForegroundTask.stopService();
    locationStream = null;

    // stop the background service
    stop();
  }
}
