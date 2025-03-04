import 'dart:async';
import 'dart:math';
import 'package:googleapis/fitness/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class TrackerService {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? locationSubscription;
  StreamSubscription<AccelerometerEvent>? accelerometerSubscription;

  int stepCount = 0;
  double distance = 0.0;
  double previousAcceleration = 0.0;
  final double stepThreshold = 1.2;

  final String googleMapsApiKey = "AIzaSyDnZq2v-CpHrfkTzA0N-Iu4rfuDw0GUIGw";

  Future<bool> requestLocationPermission() async {
    var status = await perm.Permission.location.request();
    return status == perm.PermissionStatus.granted;
  }

  Future<loc.LocationData?> getCurrentLocation() async {
    bool hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      return null; // permission denied
    }

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null; // GPS service not enabled
      }
    }

    return await location.getLocation();
  }

  void startLocationUpdates(Function(loc.LocationData) onLocationUpdate) {
    locationSubscription = location.onLocationChanged.listen(onLocationUpdate);
  }

  // fetches step count and distance from Google Fit API
  Future<Map<String, dynamic>> fetchStepAndDistance() async {
    try {
      final client = clientViaApiKey("AIzaSyDnZq2v-CpHrfkTzA0N-Iu4rfuDw0GUIGw");
      final fitnessApi = FitnessApi(client);

      final DateTime now = DateTime.now();
      final DateTime startTime = now.subtract(const Duration(days: 1));

      final AggregateResponse response =
          await fitnessApi.users.dataset.aggregate(
        AggregateRequest(
          aggregateBy: [
            AggregateBy(dataTypeName: "com.google.step_count.delta"),
            AggregateBy(dataTypeName: "com.google.distance.delta"),
          ],
          bucketByTime: BucketByTime(durationMillis: "86400000"), // 1 day
          startTimeMillis: startTime.millisecondsSinceEpoch.toString(),
          endTimeMillis: now.millisecondsSinceEpoch.toString(),
        ),
        "me",
      );

      int stepCount = 0;
      double totalDistance = 0.0;

      for (var bucket in response.bucket!) {
        for (var dataset in bucket.dataset!) {
          for (var point in dataset.point!) {
            for (var value in point.value!) {
              if (point.dataTypeName == "com.google.step_count.delta") {
                stepCount += value.intVal ?? 0;
              } else if (point.dataTypeName == "com.google.distance.delta") {
                totalDistance += value.fpVal ?? 0.0;
              }
            }
          }
        }
      }

      return {"steps": stepCount, "distance": totalDistance};
    } catch (e) {
      print("Google Fit API unavailable, switching to fallback.");
      startFallbackStepTracking();
      return {"steps": stepCount, "distance": distance}; // use fallback values
    }
  }

  // starts fallback step tracking using accelerometer data
  void startFallbackStepTracking() {
    accelerometerSubscription?.cancel(); // ensure only one listener
    accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      double acceleration =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if ((acceleration - previousAcceleration).abs() > stepThreshold) {
        stepCount++;
        distance = stepCount * 0.8; // approximate stride length (0.8m per step)
      }

      previousAcceleration = acceleration;
    });
  }

  Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    PolylinePoints polylinePoints = PolylinePoints();

    // create a PolylineRequest object
    PolylineRequest request = PolylineRequest(
      origin: PointLatLng(start.latitude, start.longitude),
      destination: PointLatLng(end.latitude, end.longitude),
      mode: TravelMode.walking, // Walking route
    );

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: request,
      googleApiKey: googleMapsApiKey,
    );

    if (result.points.isNotEmpty) {
      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } else {
      throw Exception("Failed to fetch route");
    }
  }

  Future<String> getPlaceName(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // get only a general location name, not street numbers
        return place.name ??
            place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            "Unknown Location";
      }
    } catch (e) {
      print("Error getting place name: $e");
    }
    return "Unknown Location";
  }

  void disposeService() {
    locationSubscription?.cancel();
    locationSubscription = null;
    accelerometerSubscription?.cancel();
    accelerometerSubscription = null;
  }
}
