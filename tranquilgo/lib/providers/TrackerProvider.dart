import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_app/api/tracker_service.dart';
import 'package:my_app/providers/ActivityProvider.dart';
import 'package:location/location.dart' as loc;

// import 'package:http/http.dart' as http;
// import 'dart:convert';

class TrackerProvider with ChangeNotifier {
  LocationData? _currentLocation;
  final TrackerService trackerService = TrackerService();
  final ActivityProvider activityProvider = ActivityProvider();

  Stream<loc.LocationData>? locationStream;

  int stepCount = 0;
  double distance = 0.0;
  bool isFetching = true;
  double progress = 0.0;
  int targetSteps = 0;

  LatLng? _suggestedDestination;
  List<LatLng> routePoints = [];
  List<LatLng> userRoutePoints = [];

  bool isFetchingRoute = false;

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
    stepCount = 0;
    distance = 0.0;
    isFetching = false;
    progress = 0.0;

    trackerService.resetValues();
    targetSteps = await activityProvider.getTargetSteps(userId);
    isTrackingPaused = false;

    _suggestedDestination = null;
    isFetchingRoute = false;
    _startLocationName = "";
    _destinationLocationName = "";

    trackerService.resetValues();
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
    trackerService.accelerometerSubscription?.cancel();
    trackerService.locationSubscription?.cancel();
  }

  void resumeTracking() {
    isTrackingPaused = false;
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
    const double strideLengthKm = 0.0007; // 0.7m per step (converted to km)
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

  // suggests a route based on user's target steps
  Future<void> suggestRoute(int targetSteps, LatLng currentLocation) async {
    isFetchingRoute = true;
    notifyListeners();

    try {
      double estimatedDistance = estimateDistanceFromSteps(targetSteps);

      LatLng randomDest =
          estimateDestination(currentLocation, estimatedDistance);

      _suggestedDestination =
          await trackerService.findClosestLandmark(randomDest);

      // get place names for start and destination
      _startLocationName = await trackerService.getPlaceName(currentLocation);
      _destinationLocationName =
          await trackerService.getPlaceName(_suggestedDestination!);

      if (_suggestedDestination != null) {
        routePoints = await trackerService.fetchRoute(
            currentLocation, _suggestedDestination!);
      }
    } catch (e) {
      print("Error suggesting route: $e");
    }

    isFetchingRoute = false;
    notifyListeners();
  }

  Future<void> trackUserRoute(Stream<LocationData> locationStream) async {
    locationStream.listen((locData) {
      if (locData.latitude != null && locData.longitude != null) {
        LatLng newPoint = LatLng(locData.latitude!, locData.longitude!);

        // add to user route list if it is a significant move
        if (userRoutePoints.isEmpty || isSignificantMove(newPoint)) {
          userRoutePoints.add(newPoint);
          notifyListeners();
        }
      }
    }, onError: (e) {
      print("Error tracking user route: $e");
    });
  }

  bool isSignificantMove(LatLng newPoint) {
    if (userRoutePoints.isEmpty) return true;

    LatLng lastPoint = userRoutePoints.last;
    double distanceMoved = trackerService.calculateDistance(lastPoint.latitude,
        lastPoint.longitude, newPoint.latitude, newPoint.longitude);

    return distanceMoved > 1; // only log movement if > 1 meters
  }

  // Future<void> fetchPlacesFromMapbox(String query) async {
  //   const String mapboxApiKey =
  //       "pk.eyJ1IjoiYXFjZGFlbmEiLCJhIjoiY203dTR4MXR2MDBpZTJrcTJ4NjU3YXZpeSJ9.pagAH_l6pvm4GTeq--bPAg";

  //   if (query.isEmpty) return;
  //   final url = Uri.parse(
  //       "https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?access_token=$mapboxApiKey&country=PH");

  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> data = jsonDecode(response.body);
  //     _suggestions = (data["features"] as List).map((place) {
  //       return {
  //         "name": place["place_name"],
  //         "lat": place["geometry"]["coordinates"][1],
  //         "lng": place["geometry"]["coordinates"][0],
  //       };
  //     }).toList();
  //   } else {
  //     _suggestions = [];
  //   }
  // }

  // Future<void> fetchPlaces(String query) async {
  //   if (query.isEmpty) return;

  //   final url =
  //       Uri.parse("https://maps.googleapis.com/maps/api/place/autocomplete/json"
  //           "?input=$query"
  //           "&key=$placesApiKey"
  //           "&components=country:PH" // Limits to the Philippines
  //           );

  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> data = jsonDecode(response.body);

  //     if (data["status"] == "OK") {
  //       _suggestions = (data["predictions"] as List).map((place) {
  //         return {
  //           "name": place["description"], // Place name
  //           "place_id":
  //               place["place_id"], // Google Place ID (needed for details)
  //         };
  //       }).toList();
  //     } else {
  //       print("Google Places API error: ${data["error_message"]}");
  //       _suggestions = [];
  //     }
  //   } else {
  //     print("HTTP error: ${response.statusCode}");
  //     _suggestions = [];
  //   }
  // }

  void clearSuggestions() {
    _suggestions = [];
  }

  void disposeService() {
    trackerService.disposeService();
    locationStream = null;
  }
}
