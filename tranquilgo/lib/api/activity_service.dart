import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createWeeklyActivityForAllUsers() async {
    DateTime monday = getMondayOfCurrentWeek();
    DateTime sunday = getSundayOfCurrentWeek();
    String startDate = formatDate(monday);
    String endDate = formatDate(sunday);

    QuerySnapshot usersSnapshot = await firestore.collection('users').get();

    for (var userDoc in usersSnapshot.docs) {
      String userId = userDoc.id;
      await createWeeklyActivity(userId, startDate, endDate);
    }
  }

  // create weekly activity for a newly created account
  Future<void> createWeeklyActivityForNewUser(String userId) async {
    DateTime monday = getMondayOfCurrentWeek();
    DateTime sunday = getSundayOfCurrentWeek();
    String startDate = formatDate(monday);
    String endDate = formatDate(sunday);

    await createWeeklyActivity(userId, startDate, endDate);
  }

  Future<void> createWeeklyActivity(
      String userId, String startDate, String endDate) async {
    QuerySnapshot existingActivity = await firestore
        .collection('weeklyActivity')
        .where('userId', isEqualTo: userId)
        .where('startDate', isEqualTo: startDate)
        .limit(1)
        .get();

    if (existingActivity.docs.isEmpty) {
      await firestore.collection('weeklyActivity').add({
        'weeklyActivityID': firestore.collection('weeklyActivity').doc().id,
        'userId': userId,
        'startDate': startDate,
        'endDate': endDate,
        'seAvgScore': 0.0,
        'totalStepsTaken': 0
      });

      print("Weekly Activity created for user: $userId");
    } else {
      print("Weekly Activity already exists for user: $userId");
    }
  }

  DateTime getMondayOfCurrentWeek() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday; // Monday = 1, Sunday = 7
    return now.subtract(Duration(days: currentWeekday - 1));
  }

  DateTime getSundayOfCurrentWeek() {
    DateTime monday = getMondayOfCurrentWeek();
    return monday.add(const Duration(days: 6));
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
