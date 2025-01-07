import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'NavigationBar.dart';
import '../screens/Dashboard.dart';
import '../screens/Mindfulness/Mindfulness.dart';
import '../screens/Social/SocialPage.dart';

class DashboardWithNavigation extends StatefulWidget {
  const DashboardWithNavigation({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardWithNavigationState createState() =>
      _DashboardWithNavigationState();
}

class _DashboardWithNavigationState extends State<DashboardWithNavigation> {
  int currentIndex = 0;

  final List<String> pagesTitle = [
    'Dashboard',
    'Mindfulness',
    'Social Hub',
    'Statistics'
  ];

  // list of pages for each tab
  final List<Widget> pages = [
    const Dashboard(),
    const Mindfulness(),
    const SocialPage(),
    Center(child: Text('Progress Page')),
  ];

  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        // for sidebar menu
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 50,
        leading: GestureDetector(
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 12.0, bottom: 12.0),
            child: Image.asset(
              'assets/icons/sidebar.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF110000),
              ),
              iconSize: 26,
              onPressed: () {},
            ),
          ),
        ],

        title: Text(
          pagesTitle[currentIndex],
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
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.zero),
        ),
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: const EdgeInsets.only(left: 2, right: 2),
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/user');
                }, // action
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 60, bottom: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person,
                                size: 48, color: Color(0xFF73C2C4)),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Username",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFFC3C3C3), thickness: 1),
                    ],
                  ),
                ),
              ),

              // -- menu items --

              // first section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Home',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  item('Dashboard', 'assets/icons/home_outlined.png', 'home'),
                ],
              ),

              const SizedBox(height: 5),

              // second section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 10),
                    child: Text(
                      'Walking',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  item('Daily Goals', 'assets/icons/sidebar_goals.png',
                      '/navigation'),
                  item('Activity Summary', 'assets/icons/sidebar_activity.png',
                      'progress'),
                ],
              ),

              const SizedBox(height: 5),

              // third section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 10),
                    child: Text(
                      'Mindfulness',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  item('Mood Record', 'assets/icons/sidebar_mood.png',
                      '/moodrecord'),
                  item('Journal Notes', 'assets/icons/sidebar_logs.png',
                      '/journalnotes'),
                  item('Gratitude Logs', 'assets/icons/sidebar_notes.png',
                      '/gratitudelogs'),
                ],
              ),

              const SizedBox(height: 5),

              // fourth section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 10),
                    child: Text(
                      'Social',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  item('Connections', 'assets/icons/group_outlined.png',
                      'social'),
                ],
              ),

              const SizedBox(height: 5),

              // fifth section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 10),
                    child: Text(
                      'More',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  item('Settings', 'assets/icons/sidebar_settings.png',
                      '/navigation'),
                  item('About Us', 'assets/icons/sidebar_info.png',
                      '/navigation'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: PageView(
        // allow page swipe
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: pages, // pages to display
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index; // update the active tab
          });
          pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  ListTile item(String label, String icon, String navigation) {
    final navigationMap = {
      "home": 0,
      "/moodrecord": 1,
      "/journalnotes": 1,
      "/gratitudelogs": 1,
      "social": 2,
      "progress": 3
    };

    bool isActive;

    if (navigation.startsWith("/")) {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      isActive = currentRoute == navigation;
    } else {
      isActive = currentIndex == navigationMap[navigation];
    }

    return ListTile(
      dense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
      leading: Image.asset(
        icon,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        color: isActive ? const Color(0xFF258471) : const Color(0xFF757575),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          color: isActive ? const Color(0xFF258471) : const Color(0xFF757575),
        ),
      ),
      onTap: () {
        Navigator.pop(context); // close the drawer
        if (!isActive) {
          if (navigationMap.containsKey(navigation)) {
            final index = navigationMap[navigation]!;
            setState(() {
              currentIndex = index;
            });
            if (navigation.startsWith("/")) {
              Navigator.pushNamed(context, navigation);
            }
            pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            Navigator.pushNamed(context, navigation);
          }
        }
      },
    );
  }
}
