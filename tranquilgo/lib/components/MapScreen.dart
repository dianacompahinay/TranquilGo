import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/TrackerProvider.dart';

class MapScreen extends StatefulWidget {
  final int targetSteps;

  const MapScreen({super.key, required this.targetSteps});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late TrackerProvider trackerProvider;
  GoogleMapController? mapController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    trackerProvider = Provider.of<TrackerProvider>(context, listen: false);

    if (trackerProvider.suggestedDestination == null &&
        trackerProvider.currentLocation != null) {
      LatLng currentLatLng = LatLng(
        trackerProvider.currentLocation!.latitude!,
        trackerProvider.currentLocation!.longitude!,
      );

      trackerProvider.suggestRoute(widget.targetSteps, currentLatLng);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = trackerProvider.currentLocation!;

    if (currentLocation == null) {
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

    return Consumer<TrackerProvider>(
      builder: (context, provider, child) {
        if (provider.isFetchingRoute) {
          return const Center(child: CircularProgressIndicator());
        }

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              currentLocation.latitude!,
              currentLocation.longitude!,
            ),
            zoom: 15,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          polylines: {
            if (provider.routePoints.isNotEmpty)
              Polyline(
                polylineId: const PolylineId("suggested_route"),
                color: Colors.blue,
                width: 5,
                points: provider.routePoints,
              ),
          },
          markers: {
            if (provider.suggestedDestination != null)
              Marker(
                markerId: const MarkerId("destination"),
                position: provider.suggestedDestination!,
                infoWindow: const InfoWindow(title: "Suggested Destination"),
              ),
          },
        );
      },
    );
  }
}
