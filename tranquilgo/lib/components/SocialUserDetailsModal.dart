import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/SocialMessageUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/UserProvider.dart';

class UserDetailsModal {
  static Future<String?> show(
      BuildContext context, Map<String, dynamic> user) async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Consumer<UserDetailsProvider>(
                    builder: (context, userDetailsProvider, child) {
                      String imageUrl = user['profileImage'];

                      return Container(
                        height: 65,
                        width: 65,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: imageUrl != "no_image"
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      color: Colors.grey[50],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/user.jpg',
                                      fit: BoxFit.cover,
                                      color: const Color(0xFFADD8E6)
                                          .withOpacity(0.5),
                                      colorBlendMode: BlendMode.overlay,
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/images/user.jpg',
                                  fit: BoxFit.cover,
                                  color:
                                      const Color(0xFFADD8E6).withOpacity(0.5),
                                  colorBlendMode: BlendMode.overlay,
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user["name"],
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xFF4D4D4D),
                            ),
                          ),
                        ),
                        Text(
                          user["username"],
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color(0xFF656263),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.email,
                              color: Color(0xFF92DBC9),
                              size: 28,
                            ),
                            onPressed: () {
                              MessageUserModal(user["userId"], user["username"])
                                  .show(context);
                            },
                          ),
                          const SizedBox(width: 5),
                          IconButton(
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.person_remove,
                              color: Color(0xFFC5C5C5),
                              size: 30,
                            ),
                            onPressed: () {
                              confirmationToUnfriend(
                                  context, user["userId"], user["username"]);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 26),
              _buildSectionTitle("Most Recent Activity"),
              _buildActivityRow(
                "Total Steps",
                "${user["steps"]}",
                "Total Distance",
                user["distance"],
                "Mood Rating",
                "${user["mood"]}",
              ),
              // const Divider(thickness: 0.7, height: 60),
              const SizedBox(height: 30),
              _buildSectionTitle("This Week's Progress"),
              _buildActivityRow(
                "Total Steps",
                "${user["weeklySteps"]}",
                "Total Distance",
                user["weeklyDistance"],
                "Mood Rating",
                "${user["weeklyMood"]}",
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF4BA093),
            ),
          ),
        ));
  }

  static Widget _buildActivityRow(
    String label1,
    String value1,
    String label2,
    String value2,
    String label3,
    String value3,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildActivityColumn(label1, value1),
        buildActivityColumn(label2, value2),
        buildActivityColumn(label3, value3),
      ],
    );
  }

  static Widget buildActivityColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Color(0xFF4D4D4D),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: Color(0xFF4D4D4D),
            ),
          ),
        ),
      ],
    );
  }

  static Future<void> removeFriend(
      BuildContext context, String friendId, String username) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    String result =
        await Provider.of<UserDetailsProvider>(context, listen: false)
            .removeFriend(userId, friendId);

    if (result == "success") {
      // close dialog and return the friendId to remove
      Navigator.pop(context);
      Navigator.pop(context, friendId);
      showBottomSnackBar(context, "$username has been removed as a friend.");
    } else {
      Navigator.pop(context, null);
      Navigator.pop(context, null);
      showBottomSnackBar(context, result);
    }
  }

  static void confirmationToUnfriend(
      BuildContext context, String userId, String username) {
    showDialog(
      context: context,
      builder: (context) {
        bool loadingState = false; // Moved inside the builder
        return StatefulBuilder(builder: (context, setState) {
          // StatefulBuilder for UI updates
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.white,
            content: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                "Are you sure you want to remove $username as your friend?",
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    color: Color(0xFF464646),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                textAlign: TextAlign.center,
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
                      onPressed: () async {
                        loadingState = true;
                        await removeFriend(context, userId, username);
                        loadingState = false;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF55AC9F),
                        minimumSize: const Size(120, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: loadingState
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Confirm',
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
        });
      },
    );
  }

  static void showBottomSnackBar(BuildContext context, String text) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 20,
        left: 16,
        right: 16,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF2BB1C0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              text,
              style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
