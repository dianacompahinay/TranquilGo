import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/SocialInviteUser.dart';
import 'package:my_app/components/SocialUserDetailsModal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/UserProvider.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key});

  @override
  _ConnectionsPageState createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  UserDetailsProvider userList = UserDetailsProvider();
  List<Map<String, dynamic>> users = [];
  bool isConnectionFailed = false;

  // List<Map<String, dynamic>> users = [
  //   {
  //     "userid": "1",
  //     "profileImage": "assets/images/user.jpg",
  //     "username": "jandoe",
  //     "name": "John Doe",
  //     "activeStatus": "offline",
  //     "steps": 2081,
  //     "distance": "1.5 km",
  //     "mood": 5.0,
  //     "weeklySteps": 10088,
  //     "weeklyDistance": "7.57 km",
  //     "weeklyMood": 4.5,
  //   },
  // ];

  @override
  void initState() {
    super.initState();
    initializeFriends();
  }

  Future<void> initializeFriends() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      List<Map<String, dynamic>> fetchedUsers =
          await userList.fetchFriends(userId);
      setState(() {
        users = fetchedUsers;
      });
    } catch (e) {
      setState(() {
        isConnectionFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            userList.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF36B9A5),
                      strokeWidth: 5,
                    ),
                  )
                : isConnectionFailed
                    ? Center(
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
                    : users.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/rainy.png',
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.contain,
                                  color: const Color(0xFF999999),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "It's empty here...",
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
                        : ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () async {
                                  // UserDetailsModal.show(context, users[index]);
                                  String? result = await UserDetailsModal.show(
                                      context, users[index]);

                                  if (result != null && result.isNotEmpty) {
                                    await initializeFriends();
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 6, top: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFCFCFC),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 0.2,
                                        blurRadius: 2,
                                        offset: const Offset(0, 1.2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Consumer<UserDetailsProvider>(
                                        builder: (context, userDetailsProvider,
                                            child) {
                                          String imageUrl =
                                              users[index]['profileImage'];

                                          return Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: imageUrl != "no_image"
                                                  ? Image.network(
                                                      imageUrl,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (context,
                                                          child,
                                                          loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) {
                                                          return child;
                                                        }
                                                        return Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12),
                                                          color:
                                                              Colors.grey[50],
                                                          child: Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Colors
                                                                  .grey[300],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Image.asset(
                                                          'assets/images/user.jpg',
                                                          fit: BoxFit.cover,
                                                          color: const Color(
                                                                  0xFFADD8E6)
                                                              .withOpacity(0.5),
                                                          colorBlendMode:
                                                              BlendMode.overlay,
                                                        );
                                                      },
                                                    )
                                                  : Image.asset(
                                                      'assets/images/user.jpg',
                                                      fit: BoxFit.cover,
                                                      color: const Color(
                                                              0xFFADD8E6)
                                                          .withOpacity(0.5),
                                                      colorBlendMode:
                                                          BlendMode.overlay,
                                                    ),
                                            ),
                                          );
                                        },
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Text(
                                            '${users[index]["username"]}',
                                            style: GoogleFonts.inter(
                                              textStyle: const TextStyle(
                                                color: Color(0xFF656263),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          users[index]["activeStatus"] ==
                                                  "active"
                                              ? const Icon(Icons.circle,
                                                  size: 12,
                                                  color: Color(0xFFA8EFD3))
                                              : const Icon(
                                                  Icons.circle_outlined,
                                                  size: 12,
                                                  color: Color(0xFFB5B5B5)),
                                          const SizedBox(width: 5),
                                          Text(
                                            users[index]["activeStatus"] ==
                                                    "active"
                                                ? "Active"
                                                : "Offline",
                                            style: GoogleFonts.inter(
                                              textStyle: const TextStyle(
                                                color: Color(0xFF656263),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 22),
                                      InviteUser(
                                          userId: '${users[index]["userid"]}',
                                          userName:
                                              '${users[index]["username"]}')
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
            // search user
            Align(
              alignment: const Alignment(1.05, 0.95),
              child: SizedBox(
                width: 55,
                height: 55,
                child: FloatingActionButton(
                  onPressed: () async {
                    String? result =
                        await Navigator.pushNamed(context, '/searchusers');
                    if (result != null && result.isNotEmpty) {
                      initializeFriends();
                    }
                  },
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.person_search_outlined,
                    color: Color(0xFF55AC9F),
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
