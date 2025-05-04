import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/TrackerProvider.dart';

class SearchLocationDialog {
  void show({
    required BuildContext context,
    required VoidCallback onSave,
  }) {
    final TextEditingController controller = TextEditingController();
    bool hasSelectedDestination = false;
    LayerLink layerLink = LayerLink();
    OverlayEntry? overlayEntry;
    void showDropdown(BuildContext context, TrackerProvider trackerProvider) {
      if (overlayEntry != null) {
        overlayEntry!.remove();
      }

      final overlay = Overlay.of(context);
      final renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);

      overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: position.dx,
          top: position.dy +
              renderBox.size.height +
              5, // Positioned below TextField
          width: renderBox.size.width,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(5),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView.builder(
                itemCount: trackerProvider.suggestions!.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final place = trackerProvider.suggestions![index];
                  return ListTile(
                    title: Text(place["name"]),
                    onTap: () {
                      controller.text = place["name"];
                      hasSelectedDestination = true;
                      trackerProvider.clearSuggestions();
                      overlayEntry?.remove(); // Remove dropdown after selection
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry!);
    }

    showDialog(
      context: context,
      builder: (context) {
        return Consumer<TrackerProvider>(
            builder: (context, trackerProvider, child) {
          trackerProvider.getCurrentLocName(trackerProvider.currentLocation!);
          String currentLoc = trackerProvider.startLocationName ?? "";

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Set Destination',
                          style: GoogleFonts.manrope(
                            textStyle: const TextStyle(
                              color: Color(0xFF464646),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.translate(
                            offset: const Offset(-5, 0),
                            child: Center(
                              child: Image.asset(
                                "assets/icons/destination.png",
                                width: 25,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildTextContainer(currentLoc),
                                const SizedBox(height: 10),

                                CompositedTransformTarget(
                                  link: layerLink,
                                  child: TextField(
                                    controller: controller,
                                    onChanged: (query) async {
                                      // await trackerProvider.fetchPlaces(query);
                                      setState(() {});
                                      if (trackerProvider
                                          .suggestions!.isNotEmpty) {
                                        showDropdown(context, trackerProvider);
                                      } else {
                                        overlayEntry?.remove();
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      hintText: "Enter a place",
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.search),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // list of searched places
                                trackerProvider.suggestions!.isNotEmpty
                                    ? SizedBox(
                                        height: 200,
                                        child: ListView.builder(
                                          itemCount: trackerProvider
                                              .suggestions!.length,
                                          itemBuilder: (context, index) {
                                            final place = trackerProvider
                                                .suggestions![index];
                                            return ListTile(
                                              title: Text(place["name"]),
                                              onTap: () {
                                                controller.text = place["name"];
                                                setState(() {
                                                  hasSelectedDestination = true;
                                                  trackerProvider
                                                      .clearSuggestions();
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  Container(
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // close dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: const Size(120, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: const BorderSide(
                                color: Color(0xFFB1B1B1),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Color(0xFF4C4B4B),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: hasSelectedDestination
                              ? () {
                                  onSave();
                                  Navigator.of(context).pop();
                                }
                              : null, // disabled when false
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF55AC9F),
                            minimumSize: const Size(120, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            'Save',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        });
      },
    );
  }

  Widget buildTextContainer(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
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
