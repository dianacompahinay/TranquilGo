import 'package:flutter/material.dart';
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
import 'screens/Social/FindCompanions.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: 'TranquilGo',
      home: const LandingPage(),
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
      },
    );
  }
}
