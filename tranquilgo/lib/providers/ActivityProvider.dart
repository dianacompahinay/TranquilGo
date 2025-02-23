import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:my_app/api/activity_service.dart';

class ActivityProvider with ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ActivityService activityService = ActivityService();

  int _steps = 0;
  Map<String, dynamic> _weeklyActivitySummary = {
    'totalSteps': 0,
    'avgStepsPerDay': 0,
    'totalDistance': 0,
  };
  bool _isLoading = true;

  int get steps => _steps;
  Map<String, dynamic> get weeklyActivitySummary => _weeklyActivitySummary;
  bool get isLoading => _isLoading;

  void listenToActivityChanges(String userId) {
    firestore
        .collection('weekly_activity')
        .doc(userId)
        .collection('activities')
        .snapshots()
        .listen((snapshot) async {
      // needs to delay for few seconds to wait for creating activity
      await Future.delayed(const Duration(seconds: 3));

      await getTotalSteps(userId);
      await fetchtWeeklyActivityOverview(userId);
    });
  }

  Future<void> getTotalSteps(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _steps = await activityService.getTotalSteps(userId);
      notifyListeners();
    } catch (e) {
      print("Error fetching user's total steps: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchtWeeklyActivityOverview(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _weeklyActivitySummary =
          await activityService.getWeeklyActivitySummary(userId);
      notifyListeners();
    } catch (e) {
      print("Error fetching activity overview: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

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
    notifyListeners();

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
