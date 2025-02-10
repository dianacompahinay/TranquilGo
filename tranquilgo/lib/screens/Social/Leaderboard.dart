import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/components/PodiumLeaderboard.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // initial list of users with steps
    final List<Map<String, dynamic>> users = [
      {
        "username": "user_1",
        "steps": 1234117,
        "userImage": 'assets/images/user.jpg'
      },
      {
        "username": "user_2",
        "steps": 931275,
        "userImage": 'assets/images/user.jpg'
      },
      {
        "username": "user_3",
        "steps": 534631,
        "userImage": 'assets/images/user.jpg'
      },
      {
        "username": "user_4",
        "steps": 431275,
        "userImage": 'assets/images/user.jpg'
      },
      {
        "username": "user_5",
        "steps": 402562,
        "userImage": 'assets/images/user.jpg'
      },
      {
        "username": "user_6",
        "steps": 211756,
        "userImage": 'assets/images/user.jpg'
      },
      {
        "username": "user_7",
        "steps": 150000,
        "userImage": 'assets/images/user.jpg'
      },
    ];

    // sort users by steps (highest first) and limit to top 10
    final sortedUsers = List<Map<String, dynamic>>.from(users)
      ..sort((a, b) => b["steps"].compareTo(a["steps"]))
      ..sublist(0, users.length > 10 ? 10 : users.length);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // top 3 podium with image
            PodiumWidgetWithImage(topUsers: sortedUsers.take(3).toList()),

            // remaining leaderboard
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              // limit to top 10 ranking
              itemCount: sortedUsers.length > 7
                  ? 7
                  : sortedUsers.length > 3
                      ? sortedUsers.length - 3
                      : 0,
              itemBuilder: (context, index) {
                final user = sortedUsers[index + 3];
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
                      TopUserImage(img: user["userImage"], size: 38),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
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
                            NumberFormat.decimalPattern().format(user["steps"]),
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
    return FutureBuilder<bool>(
      future: doesAssetExist(img),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // loading indicator
        }

        final imageExists = snapshot.data ?? false;

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
            image: imageExists
                ? DecorationImage(
                    colorFilter: ColorFilter.mode(
                      const Color(0xFFADD8E6).withOpacity(0.5),
                      BlendMode.overlay,
                    ),
                    image: AssetImage(img),
                    fit: BoxFit.contain,
                  )
                : null,
          ),
          child: !imageExists
              ? const Icon(
                  Icons.person,
                  color: Colors.green,
                  size: 20,
                )
              : null, // add icon only if the image doesn't exist
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
