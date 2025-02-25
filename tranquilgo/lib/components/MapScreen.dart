import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_app/providers/TrackerProvider.dart';

class MapScreen extends StatelessWidget {
  final TrackerProvider locationProvider;

  const MapScreen({super.key, required this.locationProvider});

  @override
  Widget build(BuildContext context) {
    if (locationProvider.currentLocation == null) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: Text(
            'GPS permission denied or GPS is disabled.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    final currentLocation = locationProvider.currentLocation!;

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        ),
        zoom: 15,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          ),
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}
