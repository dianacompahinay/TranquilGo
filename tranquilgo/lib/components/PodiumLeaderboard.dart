import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:my_app/screens/Social/Leaderboard.dart';

class PodiumWidgetWithImage extends StatelessWidget {
  final List<Map<String, dynamic>> topUsers;
  final String podiumImage = 'assets/images/podium.png';

  const PodiumWidgetWithImage({required this.topUsers, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: doesAssetExist(podiumImage),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // show loading indicator
        }

        if (snapshot.data != true) {
          return ListView.builder(
            // return the first 3 if podium image does not exist
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: topUsers.length,
            itemBuilder: (context, index) {
              final user = topUsers[index];
              return Container(
                margin: const EdgeInsets.fromLTRB(2, 8, 2, 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
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
                        "${index + 1}",
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
                    TopUserImage(img: user["userImage"], size: 34),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          user["username"],
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              color: Color(0xFF656263),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
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
          );
        }

        // main content
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                // background podium image
                Image.asset(
                  podiumImage,
                  width: MediaQuery.of(context).size.width * 0.7,
                ),
                const SizedBox(height: 40),
              ],
            ),

            Positioned(
              top: 185,
              child: userContainer(context, topUsers),
            ),

            // user images on the podium
            if (topUsers.isNotEmpty)
              Positioned(
                top: 38,
                left: MediaQuery.of(context).size.width * 0.307,
                child: TopUserImage(img: topUsers[0]["userImage"], size: 34),
              ),
            if (topUsers.length > 1)
              Positioned(
                top: 60,
                left: MediaQuery.of(context).size.width * 0.159,
                child: TopUserImage(img: topUsers[1]["userImage"], size: 34),
              ),
            if (topUsers.length > 2)
              Positioned(
                top: 75,
                right: MediaQuery.of(context).size.width * 0.158,
                child: TopUserImage(img: topUsers[2]["userImage"], size: 34),
              ),
          ],
        );
      },
    );
  }

  Future<bool> doesAssetExist(String assetPath) async {
    try {
      await rootBundle.load(assetPath); // check if the asset can be loaded
      return true;
    } catch (e) {
      print("Asset not found: $assetPath");
      return false;
    }
  }
}

Widget userColumn(Map<String, dynamic> user, Color crownColor,
    {bool isRankOne = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        'assets/icons/crown.png',
        width: 14,
        height: 14,
        color: crownColor,
        fit: BoxFit.contain,
      ),
      Text(
        '${user["username"]}',
        style: GoogleFonts.inter(
          textStyle: const TextStyle(
            color: Color(0xFF7A7A7A),
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
      Text(
        NumberFormat.decimalPattern().format(user["steps"]),
        style: GoogleFonts.inter(
          textStyle: TextStyle(
            color: const Color(0xFF6C6C6C),
            fontWeight: isRankOne ? FontWeight.w700 : FontWeight.w600,
            fontSize: isRankOne ? 16 : 13,
          ),
        ),
      ),
      // Text(
      //   'steps',
      //   style: GoogleFonts.inter(
      //     textStyle: const TextStyle(
      //       color: Color(0xFFC2C2C2),
      //       fontWeight: FontWeight.w600,
      //       fontSize: 10,
      //     ),
      //   ),
      // ),
    ],
  );
}

Widget userContainer(
    BuildContext context, List<Map<String, dynamic>> topUsers) {
  List<Widget> userWidgets = [];
  List<Widget> usersRankInfo = [];

  List<Color> crownColors = [
    const Color(0xFFF9DD8B), // gold for 1st place
    const Color(0xFFD2D2D2), // silver for 2nd place
    const Color(0xFFD6AA97), // bronze for 3rd place
  ];

  for (int i = 0; i < topUsers.length; i++) {
    if (i > 0) {
      userWidgets.add(const VerticalDivider(thickness: 1, width: 20));
    }
    userWidgets.add(userColumn(topUsers[i], crownColors[i], isRankOne: i == 0));
    usersRankInfo
        .add(userColumn(topUsers[i], crownColors[i], isRankOne: i == 0));
  }

  // adjust the alignment based on the number of users
  MainAxisAlignment alignment;
  if (topUsers.length == 1) {
    alignment = MainAxisAlignment.center;
  } else if (topUsers.length == 2) {
    alignment = MainAxisAlignment.spaceEvenly;
  } else {
    // for three users: middle one first, left and right next
    userWidgets = [
      usersRankInfo[1],
      const VerticalDivider(thickness: 1, width: 20),
      usersRankInfo[0],
      const VerticalDivider(thickness: 1, width: 20),
      usersRankInfo[2],
    ];
    alignment = MainAxisAlignment.spaceEvenly;
  }

  return Container(
    margin: const EdgeInsets.all(2),
    padding: const EdgeInsets.fromLTRB(25, 8, 25, 8),
    width: 270,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 0.2,
          blurRadius: 2,
          offset: const Offset(0, 1.2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: alignment,
      children: userWidgets,
    ),
  );
}
