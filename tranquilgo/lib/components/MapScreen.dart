import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/providers/TrackerProvider.dart';

class MapScreen extends StatefulWidget {
  final int targetSteps;
  final bool isSuggestRouteEnabled;

  const MapScreen(
      {super.key,
      required this.targetSteps,
      required this.isSuggestRouteEnabled});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  bool isDestinationVisible = true;
  GoogleMapController? controller;

  @override
  Widget build(BuildContext context) {
    final trackerProvider = Provider.of<TrackerProvider>(context);
    final currentLocation = trackerProvider.currentLocation;
    bool isSuggestedRouteCalled = false;

    if (currentLocation == null) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: Text(
            'GPS is not detected. It may be disabled \nor encountering an issue.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    } else {
      return Consumer<TrackerProvider>(
        builder: (context, provider, child) {
          if (!isSuggestedRouteCalled &&
              widget.isSuggestRouteEnabled &&
              provider.currentLocation != null &&
              provider.suggestedDestination == null) {
            // to prevent multiple function call
            isSuggestedRouteCalled = true;

            LatLng currentLatLng = LatLng(
              provider.currentLocation!.latitude!,
              provider.currentLocation!.longitude!,
            );

            provider.suggestRoute(widget.targetSteps, currentLatLng);
          }
          return Stack(
            children: [
              provider.isFetchingRoute
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF36B9A5),
                        strokeWidth: 5,
                      ),
                    )
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          currentLocation.latitude!,
                          currentLocation.longitude!,
                        ),
                        zoom: 15,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      polylines: {
                        // suggested route if enabled
                        if (provider.routePoints.isNotEmpty &&
                            widget.isSuggestRouteEnabled)
                          Polyline(
                            polylineId: const PolylineId("suggested_route"),
                            color: Colors.blue,
                            width: 5,
                            points: provider.routePoints,
                          ),

                        // user's actual route
                        if (provider.userRoutePoints.isNotEmpty)
                          Polyline(
                            polylineId: const PolylineId("user_route"),
                            color: Colors.green,
                            width: 6,
                            points: provider.userRoutePoints,
                          ),
                      },
                      markers: {
                        if (provider.suggestedDestination != null)
                          Marker(
                            markerId: const MarkerId("destination"),
                            position: provider.suggestedDestination!,
                            infoWindow: const InfoWindow(
                                title: "Suggested Destination"),
                          ),
                      },
                      onMapCreated: (GoogleMapController controller) {
                        setState(() {
                          mapController = controller;
                        });
                      },
                    ),

              // show destination when suggest route is enabled
              widget.isSuggestRouteEnabled && !provider.isFetchingRoute
                  ? isDestinationVisible
                      ? buildExpandedView()
                      : buildCollapsedView()
                  : const SizedBox(),

              // recenter map position based on current location button
              Positioned(
                top: 10,
                left: 10,
                child: FloatingActionButton(
                  heroTag: "recenter",
                  mini: true,
                  elevation: 1,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    mapController?.animateCamera(
                      CameraUpdate.newLatLng(
                        LatLng(
                          currentLocation.latitude!,
                          currentLocation.longitude!,
                        ),
                      ),
                    );
                  },
                  child:
                      const Icon(Icons.my_location, color: Color(0xFF55AC9F)),
                ),
              ),

              // line
              Container(
                height: 8,
                width: double.infinity,
                // margin: const EdgeInsets.only(top: 8),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFECECEC),
                      width: 8,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Widget buildExpandedView() {
    final trackerProvider =
        Provider.of<TrackerProvider>(context, listen: false);

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        width: 254,
        height: 100,
        padding: const EdgeInsets.fromLTRB(6, 6, 0, 6),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.horizontal(left: Radius.circular(6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 1.5,
              offset: Offset(0, 1),
            )
          ],
        ),
        child: Stack(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/icons/destination.png",
                  width: 25,
                  height: 55,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 5),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildTextContainer(trackerProvider.startLocationName!),
                    const SizedBox(height: 8),
                    buildTextContainer(
                        trackerProvider.destinationLocationName!),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Transform.translate(
                offset: const Offset(7, 0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 20),
                  onPressed: () {
                    setState(() {
                      isDestinationVisible = false;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCollapsedView() {
    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: () {
          setState(() {
            isDestinationVisible = true;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          height: 100,
          width: 32,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 1.5,
                offset: Offset(0, 1),
              )
            ],
          ),
          child: Center(
            child: Transform.translate(
              offset: const Offset(5, 0),
              child: const Icon(Icons.arrow_back_ios, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextContainer(String text) {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensures alignment
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                text,
                style: GoogleFonts.inter(
                  color: Colors.black87,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (text == "" || text == null) // show loader when text is empty
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
