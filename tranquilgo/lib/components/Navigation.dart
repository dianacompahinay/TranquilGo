import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/local_db.dart';
import 'package:my_app/providers/NotifProvider.dart';
import 'NavigationBar.dart';

import 'package:my_app/screens/Dashboard.dart';
import 'package:my_app/screens/Mindfulness/Mindfulness.dart';
import 'package:my_app/screens/Social/SocialPage.dart';
import 'package:my_app/screens/Walking/Statistics.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/UserProvider.dart';
import 'package:my_app/providers/ActivityProvider.dart';

class DashboardWithNavigation extends StatefulWidget {
  const DashboardWithNavigation({super.key});

  @override
  _DashboardWithNavigationState createState() =>
      _DashboardWithNavigationState();
}

class _DashboardWithNavigationState extends State<DashboardWithNavigation>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<SocialPageState> socialPageKey = GlobalKey<SocialPageState>();
  final userId = FirebaseAuth.instance.currentUser?.uid;

  int currentIndex = 0;

  final List<String> pagesTitle = [
    'Dashboard',
    'Mindfulness',
    'Social Hub',
    'Statistics'
  ];

  late List<Widget> pages;
  late PageController pageController;

  @override
  void initState() {
    super.initState();

    final notifProvider =
        Provider.of<NotificationsProvider>(context, listen: false);
    if (userId != null) {
      notifProvider.hasUnreadNotifOnlineDB(userId!);
      notifProvider.listenForNewNotifsMark(userId!, socialPageKey);
    }

    updateWeeklyGoalActivity();
    syncData();

    WidgetsBinding.instance.addObserver(this);
    setActiveStatus(true);

    pageController = PageController();

    // list of pages for each tab
    pages = [
      const Dashboard(),
      const Mindfulness(),
      SocialPage(key: socialPageKey), // assign the key inside initState
      const StatisticsPage(),
    ];

    // for fetching username in sidebar profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Provider.of<UserDetailsProvider>(context, listen: false)
            .fetchUserDetails(userId);
      }
    });
  }

  void syncData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    await LocalDatabase.syncUserCreatedAt(userId!);
    await LocalDatabase.syncOnlineMoodRecords(userId);
  }

  void updateWeeklyGoalActivity() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);

    // update streak
    await activityProvider.updateStreak(userId, "open");

    // update goal and reset weekly activity if the start of the week is not the current week's monday
    await activityProvider.updateWeeklyGoal(userId);
    await activityProvider.updateWeeklyActivity(userId);

    activityProvider.initialLoad(userId);
  }

  void setActiveStatus(bool isOnline) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Provider.of<UserDetailsProvider>(context, listen: false)
            .updateUserStatus(isOnline, userId);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setActiveStatus(true); // user comes back, set online
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      setActiveStatus(false); // app minimized or closed, set offline
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    WidgetsBinding.instance.addObserver(this);
    setActiveStatus(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<NotificationsProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        // for sidebar menu
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 60,
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
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF110000),
                  ),
                  iconSize: 26,
                  onPressed: () async {
                    final result =
                        await Navigator.pushNamed(context, '/notifs');

                    if (result == "newFriendAdded") {
                      // call a method in Companions to refresh user list
                      socialPageKey.currentState?.refreshConnections();
                    }
                  },
                ),
              ),
              if (notifProvider.hasUnreadNotif)
                Transform.translate(
                  offset: const Offset(27, 14),
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
          )
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
                      left: 8, right: 8, top: 35, bottom: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          Consumer<UserDetailsProvider>(
                            builder: (context, userDetailsProvider, child) {
                              String? imageUrl = userDetailsProvider
                                  .userDetails?['profileImage'];

                              return Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Container(
                                              padding: const EdgeInsets.all(12),
                                              color: Colors.grey[50],
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.grey[300],
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.person,
                                              size: 48,
                                              color: Color(0xFF73C2C4),
                                            );
                                          },
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 48,
                                        color: Color(0xFF73C2C4),
                                      ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Consumer<UserDetailsProvider>(
                                builder: (context, userProfileProvider, child) {
                                  final userDetails =
                                      userProfileProvider.userDetails;
                                  return Text(
                                    "${userDetails == null ? 'Username' : userDetails['username']}",
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                  item('Start Walking', 'assets/icons/sidebar_footprint.png',
                      '/walk'),
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
                      '/journalentries'),
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
      "/journalentries": 1,
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
