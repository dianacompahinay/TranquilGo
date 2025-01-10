import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/ReceivedMessage.dart';
import 'package:my_app/components/InviteConfirmation.dart';

class NotificationsPage extends StatefulWidget {
  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> {
  int selectedTabIndex = 0;

  List<Map<String, dynamic>> allNotifications = [
    {
      "type": "friend_request",
      "userid": "0",
      "username": "John Doe",
      "userImage": "assets/images/user.jpg",
      "time": "2m",
      "status": "pending",
      "isRead": false,
    },
    {
      "type": "walk_invitation",
      "userid": "1",
      "username": "Alice",
      "userImage": "assets/images/user.jpg",
      "details": [
        {
          "date": "January 12, 2025",
          "weekday": "Sunday",
          "time": "4:00 PM",
          "location": "Central Park",
          "message": ""
        }
      ],
      "time": "5h",
      "status": "pending",
      "isRead": false,
    },
    {
      "type": "message",
      "userid": "2",
      "username": "Bob",
      "userImage": "assets/images/user.jpg",
      "content": "Hello! How have you been.",
      "time": "3d",
      "isRead": false,
    },
    {
      "type": "friend_request",
      "userid": "3",
      "username": "Emma",
      "userImage": "assets/images/user.jpg",
      "time": "5d",
      "status": "accepted",
      "isRead": true,
    },
    {
      "type": "walk_invitation",
      "userid": "4",
      "username": "Chris",
      "userImage": "assets/images/user.jpg",
      "details": [
        {
          "date": "January 3, 2025",
          "weekday": "Friday",
          "time": "5:00 PM",
          "location": "City Square",
          "message": ""
        }
      ],
      "time": "8d",
      "status": "accepted",
      "isRead": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding:
            const EdgeInsets.only(left: 10, right: 26, top: 10, bottom: 24),
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Column(
              children: [
                // title
                Container(
                  height: 94,
                  padding: const EdgeInsets.only(top: 55),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Center(
                    child: Text(
                      "Notifications",
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Color(0xFF110000),
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                buildTabs(),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: filteredNotifications.length,
                    separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        indent: 26,
                        endIndent: 8,
                        color: Color(0xFFE1E1E1)),
                    itemBuilder: (context, index) {
                      final notif = filteredNotifications[index];
                      return GestureDetector(
                        onTap: () => {
                          if (notif["type"] == "message")
                            {
                              ReceivedMessageModal(notif["userid"],
                                      notif["username"], notif["content"])
                                  .show(context),
                              toggleReadStatus(index)
                            },
                          if (notif["type"] == "walk_invitation")
                            {
                              InviteConfirmationModal(
                                      notif["userid"],
                                      notif["username"],
                                      notif["details"][0],
                                      notif["status"])
                                  .show(context),
                              toggleReadStatus(index)
                            }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 14, bottom: 14, left: 28),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User image and unread indicator
                              Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    height: 42,
                                    width: 42,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        colorFilter: ColorFilter.mode(
                                          const Color(0xFFADD8E6)
                                              .withOpacity(0.5),
                                          BlendMode.overlay,
                                        ),
                                        image:
                                            AssetImage('${notif["userImage"]}'),
                                        fit: BoxFit.contain,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  if (!notif["isRead"])
                                    Transform.translate(
                                      offset: const Offset(-18, 16),
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF73D2C3),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 3),
                                    // username and notification details
                                    Text.rich(
                                      TextSpan(
                                        text: notif["username"],
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: getNotificationDetails(notif),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    // message content (if applicable)
                                    if (notif["type"] == "message")
                                      Text(
                                        "\"${notif["content"]}\"",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF727272),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    // action buttons for requests
                                    if (notif["type"] != "message" &&
                                        notif["status"] == "pending")
                                      Row(
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF6BC7B9),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 0),
                                            child: TextButton(
                                              onPressed: () => onAccept(index),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Text(
                                                "Accept",
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            height: 30,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color:
                                                      const Color(0xFFBBBFC6)),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 0),
                                            child: TextButton(
                                              onPressed: () => onDecline(index),
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    const Color(0xFF475569),
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Text(
                                                "Decline",
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                    // status display (accepted/declined)
                                    if (notif["status"] == "accepted")
                                      Text(
                                        "Accepted",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF888888),
                                        ),
                                      ),
                                    if (notif["status"] == "declined")
                                      Text(
                                        "Declined",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF888888),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // time elapsed and popup menu
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    notif["time"],
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF546466),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(0, -12),
                                    child: PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.more_horiz,
                                        color: Color(0xFF1E293B),
                                      ),
                                      onSelected: (value) {
                                        if (value == "toggle_read") {
                                          toggleReadStatus(index);
                                        } else if (value == "delete") {
                                          onDelete(index);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return [
                                          PopupMenuItem<String>(
                                            value: 'toggle_read',
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Text(
                                                notif["isRead"]
                                                    ? "Mark as Unread"
                                                    : "Mark as Read",
                                              ),
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: const Text("Delete")),
                                          ),
                                        ];
                                      },
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // back button
            Positioned(
              top: 52,
              left: 0,
              child: Container(
                width: 42.0,
                height: 42.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: SizedBox(
                    width: 30,
                    height: 30,
                    child: Image.asset(
                      'assets/images/back-arrow.png',
                      fit: BoxFit.contain,
                      color: const Color(0xFF6C6C6C),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabs() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 50,
                child: buildTabItem("All", 0),
              ),
              SizedBox(
                width: 75,
                child: buildTabItem("Messages", 1),
              ),
              SizedBox(
                width: 75,
                child: buildTabItem("Requests", 2),
              ),
            ],
          ),
          Container(
            height: 1.0,
            width: 255,
            color: const Color(0xFFE1E1E1),
          ),
        ],
      ),
    );
  }

  Widget buildTabItem(String label, int index) {
    bool isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF1E293B)
                  : const Color(0xFF6C8082),
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2.5,
              width: label == "All" ? 50 : 80,
              decoration: const BoxDecoration(
                color: Color(0xFF55AC9F),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            )
        ],
      ),
    );
  }

  String getNotificationDetails(Map<String, dynamic> notif) {
    switch (notif["type"]) {
      case "friend_request":
        return " sent a friend request.";
      // case "walk_invitation":
      //   return " is inviting you for a walk. ${notif["details"]}";
      case "walk_invitation": // format the invitation details in one text
        final details = notif["details"][0];
        final eventDetails =
            "Event is to be set on ${details["date"]} at ${details["time"]}, in ${details["location"]}.";
        final message = details["message"] != null &&
                details["message"].isNotEmpty &&
                details["message"] != ""
            ? " Message: ${details["message"]}."
            : "";
        return " is inviting you for a walk. $eventDetails$message";

      case "message":
        return " sent a message.";
      default:
        return "";
    }
  }

  List<Map<String, dynamic>> get filteredNotifications {
    if (selectedTabIndex == 1) {
      return allNotifications
          .where((notif) => notif["type"] == "message")
          .toList();
    } else if (selectedTabIndex == 2) {
      return allNotifications
          .where((notif) =>
              notif["type"] == "friend_request" ||
              notif["type"] == "walk_invitation")
          .toList();
    }
    return allNotifications;
  }

  void toggleReadStatus(int index) {
    setState(() {
      allNotifications[index]["isRead"] = !allNotifications[index]["isRead"];
    });
  }

  void onAccept(int index) {
    setState(() {
      allNotifications[index]["status"] = "accepted";
    });
  }

  void onDecline(int index) {
    setState(() {
      allNotifications[index]["status"] = "declined";
    });
  }

  void onDelete(int index) {
    setState(() {
      allNotifications.removeAt(index);
    });
  }
}
