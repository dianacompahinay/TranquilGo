import 'dart:async';
import 'dart:math';
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
  LatLng? lastLocation;

  double currentSpeed = 0.0;

  final String googleMapsApiKey = "AIzaSyDnZq2v-CpHrfkTzA0N-Iu4rfuDw0GUIGw";

  void resetValues() async {
    stepCount = 0;
    distance = 0;
    previousAcceleration = 0;
  }

  Future<bool> requestLocationPermission() async {
    var status = await perm.Permission.location.request();
    return status == perm.PermissionStatus.granted;
  }

  void startLocationUpdates(Function(loc.LocationData) onLocationUpdate) {
    locationSubscription = location.onLocationChanged.listen(onLocationUpdate);
  }

  void monitorSpeed(Function(double) onSpeedUpdate) {
    // check if location permission is granted
    locationSubscription?.cancel();

    locationSubscription =
        location.onLocationChanged.listen((loc.LocationData locData) {
      currentSpeed = locData.speed ?? 0.0;

      onSpeedUpdate(currentSpeed); // update UI or provider
    });
  }

  void startTracking(Function(int, double) onUpdate) async {
    // check if location permission is granted
    bool hasPermission = await requestLocationPermission();
    if (!hasPermission) return;

    // check if GPS is enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    // cancel any existing tracking subscriptions
    accelerometerSubscription?.cancel();
    locationSubscription?.cancel();

    int lastStepTime = DateTime.now().millisecondsSinceEpoch;
    List<double> lastReadings = [];
    bool gpsEnabled = serviceEnabled; // check if GPS is available
    bool updated = false; // flag to track updates

    if (gpsEnabled) {
      // start GPS tracking if available
      locationSubscription =
          location.onLocationChanged.listen((loc.LocationData locData) {
        LatLng currentLocation = LatLng(locData.latitude!, locData.longitude!);

        if (lastLocation != null) {
          // calculate distance moved if there's a previous location
          double metersMoved = calculateDistance(
              lastLocation!.latitude,
              lastLocation!.longitude,
              currentLocation.latitude,
              currentLocation.longitude);

          if (metersMoved > 0) {
            distance += metersMoved;
            updated = true; // mark update as needed
          }
        }

        lastLocation = currentLocation;
      });
    }

    // start step tracking using accelerometer
    accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      double zAcceleration = event.z;
      lastReadings.add(zAcceleration);

      // keep only the last 5 readings
      if (lastReadings.length > 5) {
        lastReadings.removeAt(0);
      }

      // calculate average acceleration
      double avgAcceleration =
          lastReadings.reduce((a, b) => a + b) / lastReadings.length;
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      int timeSinceLastStep = currentTime - lastStepTime;

      // detect step only if enough time has passed
      if ((avgAcceleration - previousAcceleration).abs() > stepThreshold &&
          timeSinceLastStep > 400) {
        stepCount++;
        lastStepTime = currentTime;

        // when GPS is off, estimate distance using step count
        if (!gpsEnabled) {
          distance = stepCount * 0.0008; // 0.8m per step -> convert to km
        }

        updated = true; // mark update as needed
      }

      previousAcceleration = avgAcceleration;
    });

    // update UI only once per cycle
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (updated) {
        onUpdate(stepCount, distance);
        updated = false;
      }
    });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000; // earth's radius in meters
    double dLat = (lat2 - lat1) * (pi / 180);
    double dLon = (lon2 - lon1) * (pi / 180);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // distance in meters
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
