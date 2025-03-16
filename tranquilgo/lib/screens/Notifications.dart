import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/SocialReceivedMessage.dart';
import 'package:my_app/components/SocialInviteConfirmation.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/local_db.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/UserProvider.dart';
import 'package:my_app/providers/NotifProvider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int selectedTabIndex = 0;
  bool isConnectionFailed = false;
  bool addedNewFriend = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifProvider =
          Provider.of<NotificationsProvider>(context, listen: false);
      final userId = FirebaseAuth.instance.currentUser!.uid;

      try {
        if (!notifProvider.isNotifsFetched) {
          notifProvider.initializeNotifications(userId);
          notifProvider.listenForNewNotifications(userId);
        }
      } catch (e) {
        setState(() {
          isConnectionFailed = true;
        });
      }
    });
  }

  Future<bool> checkIfOnline() async {
    return await LocalDatabase.isOnline();
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<NotificationsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 60,
        leading: Container(
          margin: const EdgeInsets.only(left: 10),
          width: 42,
          height: 42,
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
              // to call initialize friends when there are changes
              if (addedNewFriend) {
                Navigator.pop(context, "newFriendAdded");
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              color: Color(0xFF110000),
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<bool>(
        future: checkIfOnline(),
        builder: (context, snapshot) {
          bool isOnline = snapshot.data ?? false;
          if (isOnline) {
            return Container(
              padding: const EdgeInsets.only(right: 20, bottom: 24),
              constraints: const BoxConstraints.expand(),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  buildTabs(),
                  isConnectionFailed
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/error.png',
                                width: 32,
                                height: 32,
                                fit: BoxFit.contain,
                                color: const Color(0xFF999999),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Connection Failed",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: Color(0xFF999999),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: filteredNotifications.length +
                                (notifProvider.isLoading ? 1 : 0),
                            separatorBuilder: (context, index) => const Divider(
                              height: 1.2,
                              indent: 26,
                              endIndent: 8,
                              color: Color(0xFFECECEC),
                            ),
                            itemBuilder: (context, index) {
                              if (notifProvider.isLoading &&
                                  index == filteredNotifications.length) {
                                return Container(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF36B9A5),
                                      strokeWidth: 5,
                                    ),
                                  ),
                                );
                              }

                              final notif = filteredNotifications[index];

                              String? result;
                              return GestureDetector(
                                onTap: () async => {
                                  if (notif["type"] == "message")
                                    {
                                      ReceivedMessageModal(
                                              notif["senderId"],
                                              notif["username"],
                                              notif["content"])
                                          .show(context),
                                      setReadStatusToTrue(
                                          index, notif["notifId"])
                                    },
                                  if (notif["type"] == "walk_invitation" ||
                                      notif["type"] ==
                                          "invitation_request_update")
                                    {
                                      result = await InviteConfirmationModal(
                                              notif["notifId"],
                                              notif["senderId"],
                                              notif["receiverId"],
                                              notif["username"],
                                              notif["details"],
                                              notif["status"])
                                          .show(context),
                                      if (result != null && result!.isNotEmpty)
                                        {
                                          setState(() {
                                            filteredNotifications[index]
                                                ["status"] = result;
                                          })
                                        },
                                      setReadStatusToTrue(
                                          index, notif["notifId"])
                                    }
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 14, bottom: 14, left: 28),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          notif['type'] == "system"
                                              ? Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 8),
                                                  height: 42,
                                                  width: 42,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    child: Image.asset(
                                                      'assets/images/tranquil.png',
                                                      fit: BoxFit.cover,
                                                      color: const Color(
                                                              0xFFADD8E6)
                                                          .withOpacity(0.5),
                                                      colorBlendMode:
                                                          BlendMode.overlay,
                                                    ),
                                                  ),
                                                )
                                              : Consumer<UserDetailsProvider>(
                                                  builder: (context,
                                                      userDetailsProvider,
                                                      child) {
                                                    String imageUrl =
                                                        notif['profileImage'];
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 8),
                                                      height: 42,
                                                      width: 42,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                        child:
                                                            imageUrl !=
                                                                    "no_image"
                                                                ? Image.network(
                                                                    imageUrl,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    loadingBuilder:
                                                                        (context,
                                                                            child,
                                                                            loadingProgress) {
                                                                      if (loadingProgress ==
                                                                          null) {
                                                                        return child;
                                                                      }
                                                                      return Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            12),
                                                                        color: Colors
                                                                            .grey[50],
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            strokeWidth:
                                                                                2,
                                                                            color:
                                                                                Colors.grey[300],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                    errorBuilder:
                                                                        (context,
                                                                            error,
                                                                            stackTrace) {
                                                                      return Image
                                                                          .asset(
                                                                        'assets/images/user.jpg',
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        color: const Color(0xFFADD8E6)
                                                                            .withOpacity(0.5),
                                                                        colorBlendMode:
                                                                            BlendMode.overlay,
                                                                      );
                                                                    },
                                                                  )
                                                                : Image.asset(
                                                                    'assets/images/user.jpg',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    color: const Color(
                                                                            0xFFADD8E6)
                                                                        .withOpacity(
                                                                            0.5),
                                                                    colorBlendMode:
                                                                        BlendMode
                                                                            .overlay,
                                                                  ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                          if (!notif["isRead"])
                                            Transform.translate(
                                              offset: const Offset(-12, 16),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 3),
                                            // username and notification details
                                            Text.rich(
                                              TextSpan(
                                                text: notif["type"] == "system"
                                                    ? "System"
                                                    : notif["username"],
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        getNotificationDetails(
                                                            notif),
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              maxLines: 3,
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
                                                  color:
                                                      const Color(0xFF727272),
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
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFF6BC7B9),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 0),
                                                    child: TextButton(
                                                      onPressed: () => {
                                                        if (notif["type"] ==
                                                            "friend_request")
                                                          {
                                                            onFriendAccept(
                                                                index,
                                                                notif[
                                                                    "receiverId"],
                                                                notif[
                                                                    "senderId"],
                                                                notif[
                                                                    "notifId"]),
                                                          }
                                                        else if (notif[
                                                                "type"] ==
                                                            "walk_invitation")
                                                          {
                                                            onInviteAccept(
                                                                index,
                                                                notif[
                                                                    "receiverId"],
                                                                notif[
                                                                    "senderId"],
                                                                notif[
                                                                    "details"],
                                                                notif[
                                                                    "notifId"])
                                                          }
                                                      },
                                                      style:
                                                          TextButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            EdgeInsets.zero,
                                                      ),
                                                      child: Text(
                                                        "Accept",
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: const Color(
                                                              0xFFBBBFC6)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 0),
                                                    child: TextButton(
                                                      onPressed: () => {
                                                        if (notif["type"] ==
                                                            "friend_request")
                                                          {
                                                            onDecline(
                                                                index,
                                                                notif[
                                                                    "receiverId"],
                                                                notif[
                                                                    "senderId"],
                                                                notif[
                                                                    "notifId"]),
                                                          }
                                                        else if (notif[
                                                                "type"] ==
                                                            "walk_invitation")
                                                          {
                                                            onInviteDecline(
                                                                index,
                                                                notif[
                                                                    "receiverId"],
                                                                notif[
                                                                    "senderId"],
                                                                notif[
                                                                    "details"],
                                                                notif[
                                                                    "notifId"])
                                                          }
                                                      },
                                                      style:
                                                          TextButton.styleFrom(
                                                        foregroundColor:
                                                            const Color(
                                                                0xFF475569),
                                                        padding:
                                                            EdgeInsets.zero,
                                                      ),
                                                      child: Text(
                                                        "Decline",
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                            // status display (accepted/declined)
                                            if (notif["status"] == "accepted" &&
                                                (notif["type"] !=
                                                        "friend_request_update" &&
                                                    notif["type"] !=
                                                        "invitation_request_update"))
                                              Text(
                                                "Accepted",
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      const Color(0xFF888888),
                                                ),
                                              ),
                                            if (notif["status"] == "declined" &&
                                                (notif["type"] !=
                                                        "friend_request_update" &&
                                                    notif["type"] !=
                                                        "invitation_request_update"))
                                              Text(
                                                "Declined",
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      const Color(0xFF888888),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      // time elapsed and popup menu
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                                  toggleReadStatus(
                                                      index, notif["notifId"]);
                                                } else if (value == "delete") {
                                                  onDelete(
                                                      index, notif["notifId"]);
                                                }
                                              },
                                              itemBuilder:
                                                  (BuildContext context) {
                                                return [
                                                  PopupMenuItem<String>(
                                                    value: 'toggle_read',
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
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
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10),
                                                        child: const Text(
                                                            "Delete")),
                                                  ),
                                                ];
                                              },
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
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
            );
          } else {
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/no-internet.png',
                  width: 55,
                  height: 55,
                  fit: BoxFit.contain,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildTabs() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 8, 20, 0),
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
      case "system":
        return " ${notif["content"]}";
      case "friend_request":
        return " sent a friend request.";
      case "friend_request_update":
        return " ${notif["status"]} your friend request.";
      case "invitation_request_update":
        return " ${notif["status"]} your walking invitation request.";
      case "walk_invitation": // format the invitation details in one text
        final details = notif["details"];
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
    final notifProvider =
        Provider.of<NotificationsProvider>(context, listen: false);

    if (selectedTabIndex == 1) {
      return notifProvider.allNotifications
          .where((notif) => notif["type"] == "message")
          .toList();
    } else if (selectedTabIndex == 2) {
      return notifProvider.allNotifications
          .where((notif) =>
              notif["type"] == "friend_request" ||
              notif["type"] == "friend_request_update" ||
              notif["type"] == "invitation_request_update" ||
              notif["type"] == "walk_invitation")
          .toList();
    }
    return notifProvider.allNotifications;
  }

  void toggleReadStatus(int index, String notificationId) async {
    setState(() {
      filteredNotifications[index]["isRead"] =
          !filteredNotifications[index]["isRead"];
    });

    if (filteredNotifications[index]["isRead"]) {
      await Provider.of<NotificationsProvider>(context, listen: false)
          .markAsRead(notificationId);
    } else {
      await Provider.of<NotificationsProvider>(context, listen: false)
          .markAsUnread(notificationId);
    }
  }

  void setReadStatusToTrue(int index, String notificationId) async {
    setState(() {
      filteredNotifications[index]["isRead"] = true;
    });
    await Provider.of<NotificationsProvider>(context, listen: false)
        .markAsRead(notificationId);
  }

  void onFriendAccept(int index, String receiverId, String senderId,
      String notificationId) async {
    setReadStatusToTrue(index, notificationId);

    String result =
        await Provider.of<NotificationsProvider>(context, listen: false)
            .acceptFriendRequest(receiverId, senderId, notificationId);

    if (result == "success") {
      setState(() {
        filteredNotifications[index]["status"] = "accepted";
        addedNewFriend = true;
      });
    } else {
      showBottomSnackBar(context, result);
    }
  }

  void onInviteAccept(int index, String receiverId, String senderId,
      Map<String, dynamic> details, String notificationId) async {
    setReadStatusToTrue(index, notificationId);

    String result = await Provider.of<NotificationsProvider>(context,
            listen: false)
        .acceptInvitationRequest(receiverId, senderId, details, notificationId);

    if (result == "success") {
      setState(() {
        filteredNotifications[index]["status"] = "accepted";
      });
    } else {
      showBottomSnackBar(context, result);
    }
  }

  void onDecline(int index, String receiverId, String senderId,
      String notificationId) async {
    setReadStatusToTrue(index, notificationId);

    String result =
        await Provider.of<NotificationsProvider>(context, listen: false)
            .rejectFriendRequest(receiverId, senderId, notificationId);

    if (result == "success") {
      setState(() {
        filteredNotifications[index]["status"] = "declined";
      });
    } else {
      showBottomSnackBar(context, result);
    }
  }

  void onInviteDecline(int index, String receiverId, String senderId,
      Map<String, dynamic> details, String notificationId) async {
    setReadStatusToTrue(index, notificationId);

    String result = await Provider.of<NotificationsProvider>(context,
            listen: false)
        .rejectInvitationRequest(receiverId, senderId, details, notificationId);

    if (result == "success") {
      setState(() {
        filteredNotifications[index]["status"] = "declined";
      });
    } else {
      showBottomSnackBar(context, result);
    }
  }

  void onDelete(int index, String notificationId) async {
    String result =
        await Provider.of<NotificationsProvider>(context, listen: false)
            .deleteNotif(notificationId);

    if (result == "success") {
      setState(() {
        filteredNotifications.removeAt(index);
      });
    } else {
      showBottomSnackBar(context, result);
    }
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
