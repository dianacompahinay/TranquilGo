import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<int> getTotalSteps(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();

      // check if the document exists and has the 'steps' field
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['steps'] ?? 0; // return steps or 0 if not found
      } else {
        return 0; // if document doesn't exist
      }
    } catch (e) {
      throw Exception("Failed to fetch user total steps: $e");
    }
  }

  Future<Map<String, dynamic>> getWeeklyActivitySummary(String userId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfWeek =
          DateTime(now.year, now.month, now.day - (now.weekday - 1));
      int daysPassed = now.difference(startOfWeek).inDays + 1;

      // fetch the weekly activity summary
      DocumentSnapshot weeklyActivityDoc =
          await firestore.collection('weekly_activity').doc(userId).get();

      Map<String, dynamic> data =
          weeklyActivityDoc.data() as Map<String, dynamic>;

      int totalSteps = data['totalStepsTaken'] ?? 0;
      double totalDistance = (data['totalDistance'] as num?)?.toDouble() ?? 0.0;

      // calculate the average steps per day
      int avgStepsPerDay =
          (daysPassed > 0 ? totalSteps / daysPassed : 0).toInt();

      return {
        'totalSteps': totalSteps,
        'avgStepsPerDay': avgStepsPerDay,
        'totalDistance': totalDistance,
      };
    } catch (e) {
      throw Exception('Failed to fetch weekly activity summary');
    }
  }

  Future<void> createWeeklyGoalForNewUser(
      String userId, int targetSteps) async {
    DateTime today = DateTime.now();
    DateTime sunday = getSundayOfCurrentWeek();
    String startDate = formatDate(today);
    String endDate = formatDate(sunday);

    try {
      QuerySnapshot existingGoal = await firestore
          .collection('weekly_goal')
          .where(FieldPath.documentId, isEqualTo: userId)
          .limit(1)
          .get();

      if (existingGoal.docs.isEmpty) {
        await firestore.collection('weekly_goal').doc(userId).set({
          'startDate': startDate,
          'endDate': endDate,
          'targetSteps': targetSteps,
          'weeklyHistory': {
            "$startDate - $endDate": targetSteps,
          },
        });
      }
    } catch (e) {
      throw Exception('Failed to create first weekly goal: ${e.toString()}');
    }
  }

  Future<bool> checkIfWeeklyGoalExists(String userId) async {
    try {
      DocumentSnapshot docSnapshot =
          await firestore.collection('weekly_goal').doc(userId).get();
      return docSnapshot.exists;
    } catch (e) {
      throw Exception('Failed to check weekly goal: ${e.toString()}');
    }
  }

  Future<void> updateWeeklyGoal(String userId) async {
    DateTime startOfWeek = getMondayOfCurrentWeek();
    DateTime endOfWeek = getSundayOfCurrentWeek();
    String startDate = formatDate(startOfWeek);
    String endDate = formatDate(endOfWeek);
    String now = formatDate(DateTime.now());

    try {
      DocumentReference docRef =
          firestore.collection('weekly_goal').doc(userId);
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        // check if it's a new week
        if (data['startDate'] != startDate &&
            data['weeklyHistory'] != null &&
            !data['weeklyHistory'].containsKey("$now - $endDate")) {
          int previousTarget = data['targetSteps'];
          int targetSteps = calculateNewTarget(previousTarget);
          // update the weekly goal for the new week
          await docRef.set({
            'startDate': startDate,
            'endDate': endDate,
            'targetSteps': targetSteps,
            'weeklyHistory': {"$startDate - $endDate": targetSteps}
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      throw Exception('Failed to update weekly goal: ${e.toString()}');
    }
  }

  int calculateNewTarget(int prevTarget) {
    return 2000;
  }

  // create weekly activity for a newly created account
  Future<void> createWeeklyActivityForNewUser(String userId) async {
    DateTime today = DateTime.now();
    DateTime sunday = getSundayOfCurrentWeek();
    String startDate = formatDate(today);
    String endDate = formatDate(sunday);

    try {
      QuerySnapshot existingGoal = await firestore
          .collection('weekly_activity')
          .where(FieldPath.documentId, isEqualTo: userId)
          .limit(1)
          .get();

      if (existingGoal.docs.isEmpty) {
        await firestore.collection('weekly_activity').doc(userId).set({
          'activityCount': 0,
          'startDate': startDate,
          'endDate': endDate,
          'totalDistance': 0,
          'totalSEscore': 0,
          'totalStepsTaken': 0
        });
      }
    } catch (e) {
      throw Exception(
          'Failed to create first weekly activity: ${e.toString()}');
    }
  }

  Future<void> updateWeeklyActivity(String userId) async {
    DateTime startOfWeek = getMondayOfCurrentWeek();
    DateTime endOfWeek = getSundayOfCurrentWeek();
    String startDate = formatDate(startOfWeek);
    String endDate = formatDate(endOfWeek);

    try {
      DocumentReference docRef =
          firestore.collection('weekly_activity').doc(userId);
      DocumentSnapshot docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        // if the document doesn't exist, create a one
        await docRef.set({
          'activityCount': 0,
          'startDate': startDate,
          'endDate': endDate,
          'totalDistance': 0,
          'totalSEscore': 0,
          'totalStepsTaken': 0
        });
      } else {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        // check if it's a new week
        if (data['startDate'] != startDate) {
          await docRef.set({
            'activityCount': 0, // reset for the new week
            'startDate': startDate,
            'endDate': endDate,
            'totalDistance': 0,
            'totalSEscore': 0,
            'totalStepsTaken': 0
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to update weekly activity: ${e.toString()}');
    }
  }

  Future<void> createActivity(
    String userId,
    DateTime date,
    Timestamp startTime,
    Timestamp endTime,
    int timeDuration,
    int numSteps,
    double distanceCovered,
    double avgSpeed,
    int seScore,
  ) async {
    try {
      DocumentReference weeklyActivityRef =
          firestore.collection('weekly_activity').doc(userId);

      String activityId = firestore.collection('weekly_activity').doc().id;
      String formattedDate = formatDate(date);
      CollectionReference activitiesRef =
          weeklyActivityRef.collection('activities');

      // create the activity entry in the subcollection
      await activitiesRef.doc(activityId).set({
        'date': formattedDate,
        'startTime': startTime,
        'endTime': endTime,
        'timeDuration': timeDuration,
        'numSteps': numSteps,
        'distanceCovered': distanceCovered,
        'avgSpeed': avgSpeed,
        'seScore': seScore,
      });

      // update the weekly summary
      DocumentSnapshot weeklySnapshot = await weeklyActivityRef.get();
      if (weeklySnapshot.exists) {
        Map<String, dynamic> weeklyData =
            weeklySnapshot.data() as Map<String, dynamic>;

        await weeklyActivityRef.update({
          'activityCount': (weeklyData['activityCount'] ?? 0) + 1,
          'totalSEscore': (weeklyData['totalSEscore'] ?? 0.0) + seScore,
          'totalDistance':
              (weeklyData['totalDistance'] ?? 0.0) + distanceCovered,
          'totalStepsTaken': (weeklyData['totalStepsTaken'] ?? 0) + numSteps,
        });
      }

      // update user's steps
      await firestore.collection('users').doc(userId).update({
        "steps": FieldValue.increment(numSteps),
      });
    } catch (e) {
      throw Exception('Failed to create activity: ${e.toString()}');
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
