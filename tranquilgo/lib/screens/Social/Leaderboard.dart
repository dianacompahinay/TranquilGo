import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/components/PodiumLeaderboard.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/UserProvider.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  LeaderboardPageState createState() => LeaderboardPageState();
}

class LeaderboardPageState extends State<LeaderboardPage> {
  bool isConnectionFailed = false;

  @override
  void initState() {
    super.initState();
    initializeLeaderboard();
  }

  Future<void> initializeLeaderboard() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // fetch only if users list is empty
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userProvider =
            Provider.of<UserDetailsProvider>(context, listen: false);
        userProvider.fetchTopUsers(userId);
      });
    } catch (e) {
      setState(() {
        isConnectionFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserDetailsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: userProvider.isLoading
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
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // top 3 podium with image
                      PodiumWidgetWithImage(
                          topUsers: userProvider.topUsers.take(3).toList()),

                      // remaining leaderboard
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        // limit to top 10 ranking
                        itemCount: userProvider.topUsers.length > 7
                            ? 7
                            : userProvider.topUsers.length > 3
                                ? userProvider.topUsers.length - 3
                                : 0,
                        itemBuilder: (context, index) {
                          if (index + 3 >= userProvider.topUsers.length) {
                            return const SizedBox();
                          }

                          final user = userProvider.topUsers[index + 3];
                          return Container(
                            margin: const EdgeInsets.fromLTRB(2, 8, 2, 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDFDFD),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // rank
                                Container(
                                  height: 18,
                                  width: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFBBBBBB),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    "${index + 4}",
                                    style: GoogleFonts.inter(
                                      textStyle: const TextStyle(
                                        color: Color(0xFF484848),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // user image
                                TopUserImage(
                                    img: user["profileImage"], size: 38),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18),
                                    child: Text(
                                      user["username"],
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
                                // total step count
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      NumberFormat.decimalPattern()
                                          .format(user["steps"]),
                                      style: GoogleFonts.inter(
                                        textStyle: const TextStyle(
                                          color: Color(0xFF7A7A7A),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "steps",
                                      style: GoogleFonts.inter(
                                        textStyle: const TextStyle(
                                          color: Color(0xFFC2C2C2),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }
}

// for checking if user image exist, if not will return user icon
class TopUserImage extends StatelessWidget {
  final String img;
  final double size;

  const TopUserImage({required this.img, required this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
      builder: (context, userDetailsProvider, child) {
        String imageUrl = img;

        return Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
            borderRadius: BorderRadius.circular(50),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: imageUrl != "no_image"
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
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
                        color: const Color(0xFFADD8E6).withOpacity(0.5),
                        colorBlendMode: BlendMode.overlay,
                      );
                    },
                  )
                : Image.asset(
                    'assets/images/user.jpg',
                    fit: BoxFit.cover,
                    color: const Color(0xFFADD8E6).withOpacity(0.5),
                    colorBlendMode: BlendMode.overlay,
                  ),
          ),
        );
      },
    );
  }

  Future<bool> doesAssetExist(String assetPath) async {
    try {
      await rootBundle.load(assetPath); // Check if the asset can be loaded
      return true;
    } catch (e) {
      print("Asset not found: $assetPath");
      return false;
    }
  }
}
