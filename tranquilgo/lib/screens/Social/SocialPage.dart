import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Connections.dart';
import 'Leaderboard.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({Key? key}) : super(key: key);

  @override
  SocialPageState createState() => SocialPageState();
}

class SocialPageState extends State<SocialPage> {
  int currentIndex = 0; // 0 for connections, 1 for leaderboard

  final GlobalKey<ConnectionsPageState> companionsKey =
      GlobalKey<ConnectionsPageState>();
  void refreshConnections() {
    companionsKey.currentState?.initializeFriends();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(left: 28, right: 28),
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = 0; // select connections tab
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8.5),
                        decoration: BoxDecoration(
                          color: currentIndex == 0
                              ? const Color(0xFF59D1BE)
                              : const Color(0xFFFAFAFA),
                          borderRadius: currentIndex == 0
                              ? BorderRadius.circular(5)
                              : const BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  bottomLeft: Radius.circular(5),
                                ),
                          boxShadow: [
                            currentIndex == 0
                                ? const BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                    offset: Offset(1, 2),
                                  )
                                : const BoxShadow(
                                    color: Colors.white,
                                  ),
                          ],
                        ),
                        child: Text(
                          'Connections',
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              color: currentIndex == 0
                                  ? Colors.white
                                  : const Color(0xFF717171),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5),
                        bottomRight: Radius.circular(5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = 1; // select leaderboard tab
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8.5),
                        decoration: BoxDecoration(
                          color: currentIndex == 1
                              ? const Color(0xFF59D1BE)
                              : const Color(0xFFFAFAFA),
                          borderRadius: currentIndex == 1
                              ? BorderRadius.circular(5)
                              : const BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                ),
                          boxShadow: [
                            currentIndex == 1
                                ? const BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                    offset: Offset(1, 2),
                                  )
                                : const BoxShadow(
                                    color: Colors.white,
                                  ),
                          ],
                        ),
                        child: Text(
                          'Leaderboard',
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              color: currentIndex == 1
                                  ? Colors.white
                                  : const Color(0xFF717171),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // content area
            Expanded(
              child: currentIndex == 0
                  ? ConnectionsPage(key: companionsKey)
                  : const LeaderboardPage(),
            ),
          ],
        ),
      ),
    );
  }
}
