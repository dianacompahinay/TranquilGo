import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class TrackerService {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? locationSubscription;
  StreamSubscription<AccelerometerEvent>? accelerometerSubscription;

  int stepCount = 0;
  double distance = 0.0;
  double previousAcceleration = 0.0;
  LatLng? lastLocation;

  double currentSpeed = 0.0;

  final String googleMapsApiKey = "AIzaSyDnZq2v-CpHrfkTzA0N-Iu4rfuDw0GUIGw";

  void resetValues() async {
    stepCount = 0;
    distance = 0;
    previousAcceleration = 0;
    lastLocation = null;
    currentSpeed = 0;
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

  void startForegroundService() async {
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (isRunning) {
      return;
    }

    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'pedometer_service',
        channelName: 'Pedometer Service',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    await FlutterForegroundTask.startService(
      notificationTitle: "Pedometer Service",
      notificationText:
          "Steps: $stepCount, Distance: ${distance.toStringAsFixed(2)} km",
    );

    // update service notification
    FlutterForegroundTask.updateService(
      notificationTitle: "Pedometer Service",
      notificationText:
          "Steps: $stepCount, Distance: ${distance.toStringAsFixed(2)} km",
    );
  }

  void startTracking(Function(int, double) onUpdate) async {
    startForegroundService();
    // check if location permission is granted
    bool hasPermission = await requestLocationPermission();
    if (!hasPermission) return;

    // check if GPS is enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    // cancel any existing tracking subscriptions to avoid duplicates
    accelerometerSubscription?.cancel();
    locationSubscription?.cancel();

    int lastStepTime = DateTime.now().millisecondsSinceEpoch;
    List<double> lastReadings = [];
    bool updated = false;

    int minStepInterval = 340; // minimum time between steps (in ms)
    double stepSensitivity = 1.0;
    double stepDistance = 0.0007; // estimated step distance in km

    // start step tracking using accelerometer
    accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      double magnitude =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      // store last 5 readings for noise reduction
      lastReadings.add(magnitude);
      if (lastReadings.length > 5) {
        lastReadings.removeAt(0);
      }

      // compute average acceleration from the last readings
      double avgAcceleration =
          lastReadings.reduce((a, b) => a + b) / lastReadings.length;
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      int timeSinceLastStep = currentTime - lastStepTime;

      // detect step if acceleration change is significant and enough time has passed
      if ((avgAcceleration - previousAcceleration).abs() > stepSensitivity &&
          timeSinceLastStep > minStepInterval) {
        stepCount++;
        lastStepTime = currentTime;

        // add estimated distance per step
        distance += stepDistance;
        updated = true;
      }

      previousAcceleration = avgAcceleration;
    });

    // update ui only when a step is detected
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (updated) {
        FlutterForegroundTask.updateService(
          notificationTitle: "Pedometer Service",
          notificationText:
              "Steps: $stepCount, Distance: ${distance.toStringAsFixed(2)} km",
        );

        onUpdate(stepCount, distance);
        updated = false;
      }
    });
  }

  Future<LatLng> findClosestLandmark(LatLng currentLocation) async {
    String url = "https://maps.googleapis.com/maps/api/geocode/json"
        "?latlng=${currentLocation.latitude},${currentLocation.longitude}"
        "&key=$googleMapsApiKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == "OK" && data["results"].isNotEmpty) {
          for (var result in data["results"]) {
            for (var component in result["address_components"]) {
              // check for a landmark or point of interest
              if (component["types"].contains("point_of_interest") ||
                  component["types"].contains("establishment")) {
                double lat = result["geometry"]["location"]["lat"];
                double lng = result["geometry"]["location"]["lng"];
                return LatLng(lat, lng);
              }
            }
          }
        }
      }
    } catch (e) {
      throw Exception("Error fetching landmark: $e");
    }
    return currentLocation; // return the random destination if no landmark is found
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
      mode: TravelMode.walking, // walking route
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
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$googleMapsApiKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == "OK" && data["results"].isNotEmpty) {
          var result = data["results"][0];
          String formattedAddress = result["formatted_address"];

          // extract specific components (landmark, building, establishment)
          String? landmark;
          for (var component in result["address_components"]) {
            if (component["types"].any((type) => [
                  "point_of_interest",
                  "establishment",
                  "premise",
                  "street_address"
                ].contains(type))) {
              landmark = component["long_name"];
              break;
            }
          }

          return landmark ?? formattedAddress; // prefer landmark if available
        } else {
          throw Exception("Google API error: ${data['status']}");
        }
      } else {
        throw Exception("Failed to load place name");
      }
    } catch (e) {
      return "Unknown Location";
    }
  }

  void disposeService() {
    locationSubscription?.cancel();
    locationSubscription = null;
    accelerometerSubscription?.cancel();
    accelerometerSubscription = null;
  }
}
