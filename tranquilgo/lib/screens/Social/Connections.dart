import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/SocialInviteUser.dart';
import 'package:my_app/components/SocialUserDetailsModal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/UserProvider.dart';
import 'package:my_app/local_db.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({Key? key}) : super(key: key);

  @override
  ConnectionsPageState createState() => ConnectionsPageState();
}

class ConnectionsPageState extends State<ConnectionsPage> {
  bool isConnectionFailed = false;

  @override
  void initState() {
    super.initState();
    initializeFriends();
  }

  Future<void> initializeFriends() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    // final userProvider = Provider.of<UserDetailsProvider>(context, listen: false);
    // String? userId = FirebaseAuth.instance.currentUser?.uid;

    try {
      // fetch only if users list is empty
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userProvider =
            Provider.of<UserDetailsProvider>(context, listen: false);
        if (userId != null) {
          userProvider.fetchFriends(userId);
          userProvider.listenToFriends(userId);
        }
      });
    } catch (e) {
      setState(() {
        isConnectionFailed = true;
      });
    }
  }

  Future<bool> checkIfOnline() async {
    return await LocalDatabase.isOnline();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserDetailsProvider>(context);

    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            userProvider.isLoading
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
                    : userProvider.friends.isEmpty
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
                            itemCount: userProvider.friends.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () async {
                                  // UserDetailsModal.show(context, users[index]);
                                  String? result = await UserDetailsModal.show(
                                      context, userProvider.friends[index]);

                                  if (result != null && result.isNotEmpty) {
                                    final userProvider =
                                        Provider.of<UserDetailsProvider>(
                                            context,
                                            listen: false);
                                    userProvider.setFetchToFalse();
                                    await initializeFriends();
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 6, top: 8),
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 12, 14, 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Consumer<UserDetailsProvider>(
                                        builder: (context, userDetailsProvider,
                                            child) {
                                          String imageUrl = userProvider
                                              .friends[index]['profileImage'];

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
                                            '${userProvider.friends[index]["username"]}',
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
                                      FutureBuilder<bool>(
                                        future: checkIfOnline(),
                                        builder: (context, snapshot) {
                                          bool isOnline =
                                              snapshot.data ?? false;
                                          return Row(
                                            children: [
                                              userProvider.friends[index][
                                                              "activeStatus"] ==
                                                          "active" &&
                                                      isOnline
                                                  ? const Icon(Icons.circle,
                                                      size: 12,
                                                      color: Color(0xFFA8EFD3))
                                                  : const Icon(
                                                      Icons.circle_outlined,
                                                      size: 12,
                                                      color: Color(0xFFB5B5B5)),
                                              const SizedBox(width: 5),
                                              Text(
                                                userProvider.friends[index][
                                                                "activeStatus"] ==
                                                            "active" &&
                                                        isOnline
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
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 22),
                                      InviteUser(
                                          receiverId:
                                              '${userProvider.friends[index]["userId"]}',
                                          userName:
                                              '${userProvider.friends[index]["username"]}')
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
                  elevation: 3,
                  onPressed: () async {
                    String? result =
                        await Navigator.pushNamed(context, '/searchusers');
                    if (result != null && result.isNotEmpty) {
                      final userProvider = Provider.of<UserDetailsProvider>(
                          context,
                          listen: false);
                      userProvider.setFetchToFalse();
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
