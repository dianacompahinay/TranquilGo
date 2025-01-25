import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/AuthProvider.dart';
import 'providers/UserProvider.dart';

import 'screens/Auth/LandingPage.dart';
import 'screens/Auth/LoginPage.dart';
import 'screens/Auth/SignupPage.dart';

import 'screens/Walking/FirstGoal.dart';
import 'screens/GetStarted.dart';
import 'components/Navigation.dart';
import 'screens/UserProfile.dart';

import 'screens/Mindfulness/MoodRecord.dart';
import 'screens/Mindfulness/MoodHistory.dart';
import 'screens/Mindfulness/GratitudeLogs.dart';
import 'screens/Mindfulness/JournalNotes.dart';
import 'screens/Mindfulness/AddJournal.dart';
import 'screens/Mindfulness/AddGratitudeLog.dart';

import 'screens/Walking/WalkingTracker.dart';
import 'screens/Social/FindCompanions.dart';
import 'screens/Notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context) => AuthenticationProvider())),
        ChangeNotifierProvider(create: ((context) => UserDetailsProvider())),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: 'TranquilGo',
      home: Consumer<AuthenticationProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isAuthenticated) {
            return const DashboardWithNavigation(); // authenticated users
          } else {
            return const LandingPage(); // non-authenticated users
          }
        },
      ),
      routes: {
        '/welcome': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/firstgoal': (context) => const FirstGoal(),
        '/getstarted': (context) => const Getstarted(),
        '/home': (context) => const DashboardWithNavigation(),
        '/user': (context) => const UserProfilePage(),
        '/moodrecord': (context) => const MoodRecord(),
        '/moodhistory': (context) => const MoodTrackingHistory(),
        '/journalnotes': (context) => const JournalNotes(),
        '/addentry': (context) => const AddJournalPage(),
        '/addlog': (context) => const AddGratitudeLogPage(),
        '/gratitudelogs': (context) => const GratitudeLogs(),
        '/searchusers': (context) => const FindCompanionsPage(),
        '/notifs': (context) => const NotificationsPage(),
        '/walk': (context) => const WalkingTracker(),
      },
    );
  }
}
