import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/UserProvider.dart';
import 'package:my_app/providers/MindfulnessProvider.dart';
import 'package:my_app/providers/ActivityProvider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final userProvider =
          Provider.of<UserDetailsProvider>(context, listen: false);
      final activityProvider =
          Provider.of<ActivityProvider>(context, listen: false);
      final mindfulnessProvider =
          Provider.of<MindfulnessProvider>(context, listen: false);
      userProvider.fetchUserDetails(userId);

      activityProvider.listenToActivityChanges(userId);
      mindfulnessProvider.listenToMoodChanges(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserDetailsProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    final mindfulnessProvider = Provider.of<MindfulnessProvider>(context);

    final userDetails = userProfileProvider.userDetails;

    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
        ),
        padding: const EdgeInsets.only(left: 6.0, right: 6.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // total steps card
                Container(
                  padding: const EdgeInsets.only(
                      left: 24.0, right: 24.0, top: 20.0, bottom: 15.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF5EC7B7),
                        Color(0xFF67DCCB),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total steps for this week',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              activityProvider.isLoading
                                  ? Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.grey[300],
                                      ),
                                    )
                                  : Text(
                                      '${activityProvider.weeklyActivitySummary["totalSteps"]}',
                                      style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                              const SizedBox(width: 10),
                              activityProvider.isLoading
                                  ? const SizedBox()
                                  : Text(
                                      '${formatSteps(activityProvider.steps)} overall steps',
                                      style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                            ],
                          )
                        ],
                      ),
                      const Icon(
                        Icons.directions_walk_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // stats overview section
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.05,
                  children: [
                    buildStatsCard(
                        'Avg Steps',
                        '${activityProvider.weeklyActivitySummary["avgStepsPerDay"]}',
                        'footprint',
                        const Color(0xFFE7F3EC)),
                    buildStatsCard(
                        'Total Distance',
                        '${activityProvider.weeklyActivitySummary["totalDistance"]}',
                        'distance',
                        const Color(0xFFF5F5F5)),
                    buildStatsCard(
                        'Streak',
                        '${activityProvider.weeklyActivitySummary["totalStreak"]} days',
                        'streak',
                        const Color(0xFFF5F5F5)),
                    buildStatsCard(
                        'Mood Tracking',
                        '${mindfulnessProvider.mood}',
                        'mood',
                        const Color(0xFFE7F3EC)),
                  ],
                ),

                const SizedBox(height: 14),

                // start walking activity section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Let's Get Moving, ${userDetails == null ? 'User' : userDetails['username']}!",
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Color(0xFF404040),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Text(
                          'Kickstart your walk and enjoy a healthy stride toward your goals.',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            backgroundColor: const Color(0xFF55AC9F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/walk');
                          },
                          child: Text(
                            'Start walking',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStatsCard(
      String title, String value, String str, Color backgroundColor) {
    final activityProvider = Provider.of<ActivityProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // icon
            height: 40,
            width: 40,
            padding: const EdgeInsets.all(5.0),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            child: Image.asset(
              'assets/icons/$str.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            // title data
            title,
            style: GoogleFonts.manrope(
              textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          activityProvider.isLoading
              ? Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.grey[300],
                  ),
                )
              : Text(
                  // data
                  value,
                  style: GoogleFonts.manrope(
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  String formatSteps(int steps) {
    if (steps >= 1000000) {
      // Format in millions
      return "${(steps / 1000000).toStringAsFixed(1)}m";
    } else if (steps >= 1000) {
      // Format in thousands
      return "${(steps / 1000).toStringAsFixed(1)}k";
    } else {
      // Less than a thousand
      return steps.toString();
    }
  }
}
