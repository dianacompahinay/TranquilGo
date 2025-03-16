import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_app/local_db.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/AuthProvider.dart';
import 'providers/UserProvider.dart';
import 'providers/NotifProvider.dart';
import 'providers/MindfulnessProvider.dart';
import 'package:my_app/providers/ActivityProvider.dart';
import 'package:my_app/providers/TrackerProvider.dart';

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
import 'screens/Mindfulness/JournalEntries.dart';
import 'screens/Mindfulness/ViewJournal.dart';
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

  syncOfflineActivities(); // sync offline data at startup

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context) => AuthenticationProvider())),
        ChangeNotifierProvider(create: ((context) => UserDetailsProvider())),
        ChangeNotifierProvider(create: ((context) => NotificationsProvider())),
        ChangeNotifierProvider(create: ((context) => MindfulnessProvider())),
        ChangeNotifierProvider(create: ((context) => ActivityProvider())),
        ChangeNotifierProvider(create: ((context) => TrackerProvider())),
      ],
      child: const MainApp(),
    ),
  );
}

void syncOfflineActivities() async {
  if (!await LocalDatabase.isOnline()) return;

  Future.microtask(() async {
    await LocalDatabase.syncActivities();
    await LocalDatabase.syncStreakData();
    await LocalDatabase.syncMoodRecords();
    await LocalDatabase.syncJournalEntries();
    await LocalDatabase.syncDeletedEntries();
    await LocalDatabase.syncGratitudeLogs();
    await LocalDatabase.syncDeletedLogs();
  });
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
        '/journalentries': (context) => const JournalEntries(),
        '/gratitudelogs': (context) => const GratitudeLogs(),
        '/walk': (context) => const WalkingTracker(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/searchusers') {
          return MaterialPageRoute<String?>(
            builder: (context) => const FindCompanionsPage(),
          );
        }
        if (settings.name == '/notifs') {
          return MaterialPageRoute<String?>(
            builder: (context) => const NotificationsPage(),
          );
        }
        if (settings.name == '/addlog') {
          return MaterialPageRoute<String?>(
            builder: (context) => const AddGratitudeLogPage(),
          );
        }
        if (settings.name == '/addentry') {
          return MaterialPageRoute<String?>(
            builder: (context) => const AddJournalPage(),
          );
        }
        if (settings.name == '/viewentry') {
          // pass arguments to the page
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute<String?>(
            builder: (context) => ViewJournalPage(arguments: args),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
