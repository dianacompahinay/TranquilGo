import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:my_app/api/activity_service.dart';

class ActivityProvider with ChangeNotifier {
  final ActivityService activityService = ActivityService();

  Future<bool?> checkIfWeeklyGoalExists(String userId) async {
    try {
      return await activityService.checkIfWeeklyGoalExists(userId);
    } catch (e) {
      return null;
    }
  }

  Future<String> createFirstWeeklyGoal(String userId, int targetSteps) async {
    try {
      await activityService.createWeeklyGoalForNewUser(userId, targetSteps);
      notifyListeners();
      return 'success';
    } catch (e) {
      return 'failed';
    }
  }

  Future<String> updateWeeklyGoal(String userId) async {
    try {
      await activityService.updateWeeklyGoal(userId);
      notifyListeners();
      return 'success';
    } catch (e) {
      return 'failed';
    }
  }

  Future<String> createWeeklyActivity(String userId) async {
    try {
      await activityService.createWeeklyActivityForNewUser(userId);
      notifyListeners();
      return 'success';
    } catch (e) {
      return 'failed';
    }
  }

  Future<String> updateWeeklyActivity(String userId) async {
    try {
      await activityService.updateWeeklyActivity(userId);
      notifyListeners();
      return 'success';
    } catch (e) {
      return 'failed';
    }
  }

  Future<String> createActivity(
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
      await activityService.createActivity(userId, date, startTime, endTime,
          timeDuration, numSteps, distanceCovered, avgSpeed, seScore);
      notifyListeners();
      return 'success';
    } catch (e) {
      return 'failed';
    }
  }
}
