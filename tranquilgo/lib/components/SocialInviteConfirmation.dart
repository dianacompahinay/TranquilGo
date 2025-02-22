import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/NotifProvider.dart';

class InviteConfirmationModal {
  final String notificationId;
  final String senderId;
  final String receiverId;
  final String userName;
  final Map<String, dynamic> details;
  final String status;

  const InviteConfirmationModal(this.notificationId, this.senderId,
      this.receiverId, this.userName, this.details, this.status);

  Future<String?> show(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: true, // allow dismiss by tapping outside
      builder: (BuildContext context) {
        return Center(
          child: StatefulBuilder(
            builder: (BuildContext dialogContext, Function setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // rounded corners
                ),
                backgroundColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                content: SizedBox(
                  width: 400,
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Row(
                              // modal title
                              children: [
                                const Icon(
                                  Icons.directions_walk_rounded,
                                  size: 22,
                                  color: Color(0xFF41B8A7),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Invite to walk',
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      color: Color(0xFF323232),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              margin: const EdgeInsets.only(left: 5),
                              child: Text(
                                // user to send invitation to
                                'To: $userName',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: Color(0xFF555555),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // date details
                                Expanded(
                                  child: invitationDetail(
                                    "Date",
                                    "${details["date"]}, ${details["weekday"]}",
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // time details
                                Expanded(
                                  child: invitationDetail(
                                    "Time",
                                    "${details["time"]}",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // location details
                            invitationDetail(
                                "Location", "${details["location"]}"),
                            const SizedBox(height: 16),
                            // message details
                            invitationDetail(
                                "Message", "${details["message"]}"),
                            const SizedBox(height: 20),
                            if (status == "pending")
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // decline button
                                  ElevatedButton(
                                    onPressed: () {
                                      declineInvitation(dialogContext, details);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      minimumSize: const Size(120, 34),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        side: const BorderSide(
                                          color: Color(0xFFB1B1B1),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Decline',
                                      style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(
                                          color: Color(0xFF4C4B4B),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // accept button
                                  ElevatedButton(
                                    onPressed: () =>
                                        {acceptInvitation(dialogContext)},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF55AC9F),
                                      minimumSize: const Size(120, 34),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Text(
                                      'Accept',
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
                          ],
                        ),
                      ),
                      // close button
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
                            Icons.close,
                            size: 24,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void acceptInvitation(dialogContext) async {
    String result = await Provider.of<NotificationsProvider>(dialogContext,
            listen: false)
        .acceptInvitationRequest(receiverId, senderId, details, notificationId);

    if (result == "success") {
      // returns a value to render the action made in notifications
      Navigator.pop(dialogContext, "accepted");
    } else {
      showBottomSnackBar(dialogContext, result);
      Navigator.pop(dialogContext);
    }
  }

  void declineInvitation(dialogContext, details) async {
    String result = await Provider.of<NotificationsProvider>(dialogContext,
            listen: false)
        .rejectInvitationRequest(receiverId, senderId, details, notificationId);

    if (result == "success") {
      // returns a value to render the action made in notifications
      Navigator.pop(dialogContext, "declined");
    } else {
      showBottomSnackBar(dialogContext, result);
      Navigator.pop(dialogContext);
    }
  }

  // displays invitation details
  Widget invitationDetail(String label, content) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          content != "" && content != null && content.isNotEmpty
              ? content
              : "-",
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              color: Color(0xFF8B8B8B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void showBottomSnackBar(BuildContext context, String text) {
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
