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

  Future<int> getTargetSteps(String userId) async {
    try {
      DocumentSnapshot weeklyGoalDoc =
          await firestore.collection('weekly_goal').doc(userId).get();

      // check if the document exists and has the 'steps' field
      if (weeklyGoalDoc.exists && weeklyGoalDoc.data() != null) {
        Map<String, dynamic> data =
            weeklyGoalDoc.data() as Map<String, dynamic>;

        return data['targetSteps'] ?? 0; // return steps or 0 if not found
      } else {
        return 0; // if document doesn't exist
      }
    } catch (e) {
      throw Exception("Failed to fetch user target steps: $e");
    }
  }

  Future<String> getTargetStepChange(String userId) async {
    try {
      DocumentSnapshot weeklyGoalDoc =
          await firestore.collection('weekly_goal').doc(userId).get();

      if (!weeklyGoalDoc.exists || weeklyGoalDoc.data() == null) {
        return "";
      }

      Map<String, dynamic> data = weeklyGoalDoc.data() as Map<String, dynamic>;

      if (!data.containsKey('weeklyHistory')) {
        return ""; // no history available
      }

      Map<String, dynamic> weeklyHistory = data['weeklyHistory'];

      if (weeklyHistory.length <= 1) {
        return ""; // 0 or 1 length, not enough data to compare
      }

      // sort the history keys in descending order
      List<String> sortedWeeks = weeklyHistory.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      int currentSteps = weeklyHistory[sortedWeeks[0]] ?? 0;
      int previousSteps = weeklyHistory[sortedWeeks[1]] ?? 0;

      if (previousSteps == 0) {
        return ""; // avoid division by zero
      }

      // calculate percentage change
      double percentageChange =
          ((currentSteps - previousSteps) / previousSteps).toDouble();

      return formatTargetChange(
          percentageChange); // positive means increase, negative means decrease
    } catch (e) {
      throw Exception("Failed to fetch step change: $e");
    }
  }

  String formatTargetChange(double targetChange) {
    double percentage = targetChange * 100;
    String changeType = percentage >= 0 ? "higher" : "lower";
    percentage = percentage.abs(); // absolute value

    if (percentage == 0) return "Same as previous week";

    // format based on whether it has decimals
    String formattedPercentage = percentage % 1 == 0
        ? percentage.toInt().toString() // whole number, means no decimals
        : percentage.toStringAsFixed(2); // display up to 2 decimal places

    return '$formattedPercentage% $changeType than previous week';
  }

  Future<Map<String, dynamic>> getTodayActivitySummary(String userId) async {
    try {
      // access database
      DocumentReference weeklyActivityRef =
          firestore.collection('weekly_activity').doc(userId);
      CollectionReference activitiesRef =
          weeklyActivityRef.collection('activities');
      String todayDate = formatDate(DateTime.now());

      // fetch activities sorted by date (latest first)
      QuerySnapshot querySnapshot =
          await activitiesRef.orderBy('date', descending: true).get();

      int totalSteps = 0;
      double totalDistance = 0.0;
      int totalDuration = 0;

      // iterate through the records and sum values until the date changes
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // stop processing once the date is different from today
        if (data['date'] != todayDate) break;

        totalSteps += (data['numSteps'] as num).toInt();
        totalDistance += (data['distanceCovered'] as num).toDouble();
        totalDuration += (data['timeDuration'] as num).toInt();
      }

      // fetch the user's target steps
      int targetSteps = await getTargetSteps(userId);

      // calculate progress
      double progress =
          targetSteps > 0 ? (totalSteps / targetSteps).clamp(0.0, 1.0) : 0.0;

      return {
        'totalSteps': totalSteps,
        'totalDistance': totalDistance,
        'progress': progress,
        'totalDuration': totalDuration,
      };
    } catch (e) {
      throw Exception("Failed to fetch today's activity summary: $e");
    }
  }

  Future<List<int>> fetchStepsByDateRange(
      String userId, String rangeType, DateTime startDate) async {
    try {
      // access user's weekly activity document
      DocumentReference weeklyActivityRef =
          firestore.collection('weekly_activity').doc(userId);
      CollectionReference activitiesRef =
          weeklyActivityRef.collection('activities');

      DateTime endDate;
      int daysInMonth = DateTime(startDate.year, startDate.month + 1, 0).day;

      // define the end date based on range type
      if (rangeType == 'Weekly') {
        endDate = startDate.add(const Duration(days: 6));
      } else if (rangeType == 'Monthly') {
        endDate = DateTime(startDate.year, startDate.month, daysInMonth);
      } else if (rangeType == 'Yearly') {
        endDate = DateTime(startDate.year, 12, 31);
      } else {
        throw Exception("Invalid range type: $rangeType");
      }

      // convert dates to Firestore format
      String startDateString = formatDate(startDate);
      String endDateString = formatDate(endDate);

      // fetch activities within the date range
      QuerySnapshot querySnapshot = await activitiesRef
          .where('date', isGreaterThanOrEqualTo: startDateString)
          .where('date', isLessThanOrEqualTo: endDateString)
          .orderBy('date', descending: false)
          .get();

      // initialize data storage
      Map<String, int> stepsMap = {};
      List<int> stepsData = [];

      // populate stepsMap with zero values (to make sure missing days are handled)
      if (rangeType == 'Weekly') {
        for (int i = 0; i < 7; i++) {
          stepsMap[formatDate(startDate.add(Duration(days: i)))] = 0;
        }
      } else if (rangeType == 'Monthly') {
        for (int i = 1; i <= daysInMonth; i++) {
          stepsMap[formatDate(DateTime(startDate.year, startDate.month, i))] =
              0;
        }
      } else if (rangeType == 'Yearly') {
        for (int i = 1; i <= 12; i++) {
          stepsMap["${startDate.year}-${i.toString().padLeft(2, '0')}"] = 0;
        }
      }

      // sum up steps for each date
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String activityDate = data['date'];
        int steps = (data['numSteps'] as num).toInt();

        if (rangeType == 'Yearly') {
          // group by month (YYYY-MM format)
          String monthKey = activityDate.substring(0, 7);
          stepsMap[monthKey] = (stepsMap[monthKey] ?? 0) + steps;
        } else {
          // group by exact date
          stepsMap[activityDate] = (stepsMap[activityDate] ?? 0) + steps;
        }
      }

      // convert map values to list
      stepsData = stepsMap.values.toList();

      return stepsData;
    } catch (e) {
      throw Exception("Failed to fetch steps: $e");
    }
  }

  Future<Map<String, dynamic>> fetchActivityStats(
      String userId, String rangeType, DateTime startDate) async {
    try {
      // access the user's activity collection
      DocumentReference weeklyActivityRef =
          firestore.collection('weekly_activity').doc(userId);
      CollectionReference activitiesRef =
          weeklyActivityRef.collection('activities');

      DateTime endDate;
      int daysInMonth = DateTime(startDate.year, startDate.month + 1, 0).day;

      // get end date based on range type
      if (rangeType == 'Weekly') {
        endDate = startDate.add(const Duration(days: 6)); // 7-day range
      } else if (rangeType == 'Monthly') {
        endDate = DateTime(startDate.year, startDate.month, daysInMonth);
      } else if (rangeType == 'Yearly') {
        endDate = DateTime(startDate.year, 12, 31);
      } else {
        throw Exception("Invalid range type: $rangeType");
      }

      // convert dates to firestore format
      String startDateString = formatDate(startDate);
      String endDateString = formatDate(endDate);

      // fetch activities within the selected date range
      QuerySnapshot querySnapshot = await activitiesRef
          .where('date', isGreaterThanOrEqualTo: startDateString)
          .where('date', isLessThanOrEqualTo: endDateString)
          .orderBy('date', descending: false)
          .get();

      // initialize total values
      int totalSteps = 0;
      double totalDistance = 0.0;
      int totalDuration = 0;
      double totalSE = 0.0;
      int seCount = 0;

      // iterate through the records and sum values
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        totalSteps += (data['numSteps'] as num).toInt();
        totalDistance += (data['distanceCovered'] as num).toDouble();
        totalDuration += (data['timeDuration'] as num).toInt();

        if (data.containsKey('seScore')) {
          totalSE += (data['seScore'] as num).toDouble();
          seCount++;
        }
      }

      // calculate self-efficacy score (average SE)
      double avgSE = seCount > 0 ? totalSE / seCount : 0.0;
      String selfEfficacy = avgSE >= 2.5 ? "High" : "Low";

      return {
        'totalSteps': totalSteps,
        'totalDistance': totalDistance,
        'totalDuration': totalDuration,
        'selfEfficacy': selfEfficacy,
      };
    } catch (e) {
      throw Exception('Failed to fetch activity stats');
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
      int totalStreak = data['streak'] ?? 0;

      // calculate the average steps per day
      int avgStepsPerDay =
          (daysPassed > 0 ? totalSteps / daysPassed : 0).toInt();

      return {
        'totalSteps': totalSteps,
        'avgStepsPerDay': avgStepsPerDay,
        'totalDistance': totalDistance,
        'totalStreak': totalStreak,
      };
    } catch (e) {
      throw Exception('Failed to fetch weekly activity summary');
    }
  }

  Future<void> updateStreak(String userId, String type) async {
    try {
      final userDocRef = firestore.collection("weekly_activity").doc(userId);
      final userDoc = await userDocRef.get();
      int newStreak = 0;
      final today = DateTime.now();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final lastActivityDate = data['lastActivityDate']?.toDate();

        if (lastActivityDate != null) {
          final yesterday = today.subtract(const Duration(days: 1));

          newStreak = data['streak'] ?? 0;

          if (isSameDay(lastActivityDate, today) &&
              data['streak'] == 0 &&
              type == "create") {
            newStreak = 1; // set to 1 streak if it's currently zero
          } else if (isSameDay(lastActivityDate, yesterday) &&
              type == "create") {
            newStreak = (data['streak'] ?? 0) + 1;
          }

          // if restarting the app and the last activity day is not today and yesterday
          if (!isSameDay(lastActivityDate, today) &&
              !isSameDay(lastActivityDate, yesterday)) {
            if (type == "open") {
              newStreak = 0; // reset to 0
            } else {
              // set to 1 if recently created an activity but the last activity date is not today and yesterday
              newStreak = 1;
            }
          }
        } else {
          if (type == "create") {
            newStreak = 1;
          }
        }
      }

      await userDocRef.update({
        'streak': newStreak,
        if (type == "create") 'lastActivityDate': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to update streak: ${e.toString()}');
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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

    DateTime previousStartOfWeek =
        startOfWeek.subtract(const Duration(days: 7));

    try {
      DocumentReference docRef =
          firestore.collection('weekly_goal').doc(userId);
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        int previousTarget = data['targetSteps'];
        // fetch user's weekly activity summary
        Map<String, dynamic> activitySummary =
            await fetchActivityStats(userId, "Weekly", previousStartOfWeek);

        int totalSteps = activitySummary['totalSteps'];
        String selfEfficacy = activitySummary['selfEfficacy'];

        // determine new target steps based on Muoviti rules
        int newTargetSteps =
            calculateNewTarget(previousTarget, totalSteps, selfEfficacy);

        // check if it's a new week before updating
        if (data['startDate'] != startDate &&
            data['weeklyHistory'] != null &&
            !data['weeklyHistory'].containsKey("$now - $endDate")) {
          await docRef.set({
            'startDate': startDate,
            'endDate': endDate,
            'targetSteps': newTargetSteps,
            'weeklyHistory': {"$startDate - $endDate": newTargetSteps}
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      throw Exception('Failed to update weekly goal: ${e.toString()}');
    }
  }

  int calculateNewTarget(int prevTarget, int totalSteps, String selfEfficacy) {
    int avgDailySteps = (totalSteps / 7).toInt(); // get average daily steps
    bool achievedGoal = avgDailySteps >= prevTarget;
    bool highSE = selfEfficacy == "High";

    if (achievedGoal && highSE) {
      return prevTarget + 1000; // increase PA goal
    } else if (achievedGoal && !highSE) {
      return prevTarget; // mintain PA goal
    } else if (!achievedGoal && highSE) {
      return prevTarget; // maintain PA goal
    } else {
      return (prevTarget - 1000)
          .clamp(2000, prevTarget); // decrease PA goal (min 2000)
    }
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
          await docRef.update({
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
    int seScore,
    int mood,
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
        'seScore': seScore,
        'recentMood': mood,
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

      // update user's streak
      await updateStreak(userId, "create");
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
