import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:my_app/api/activity_service.dart';

class ActivityProvider with ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ActivityService activityService = ActivityService();

  int _steps = 0;
  int _goalSteps = 0;
  double _targetChange = 0.0;

  Map<String, dynamic> _weeklyActivitySummary = {
    'totalSteps': 0,
    'avgStepsPerDay': 0,
    'totalDistance': 0,
  };

  Map<String, dynamic> _todayActivitySummary = {
    'totalSteps': 0,
    'totalDistance': 0,
    'progress': 0.0,
    'totalDuration': 0,
  };

  bool _isLoading = true;
  bool _isGraphLoading = true; // separate loading for stats graphs

  bool isOverviewFetch = false;
  bool isStatsFetch = false;

  int get steps => _steps;
  int get goalSteps => _goalSteps;
  double get targetChange => _targetChange;

  Map<String, dynamic> get weeklyActivitySummary => _weeklyActivitySummary;
  Map<String, dynamic> get todayActivitySummary => _todayActivitySummary;

  bool get isLoading => _isLoading;
  bool get isGraphLoading => _isGraphLoading;

  void listenToActivityChanges(String userId) {
    firestore
        .collection('weekly_activity')
        .doc(userId)
        .collection('activities')
        .snapshots()
        .listen((snapshot) async {
      // needs to delay for few seconds to wait for creating activity
      await Future.delayed(const Duration(seconds: 2));

      if (!isOverviewFetch) {
        isOverviewFetch = true;
        await getTotalSteps(userId);
        await fetchtWeeklyActivityOverview(userId);
      }
    });
  }

  void listenToActivityStatsChanges(String userId) {
    firestore
        .collection('weekly_activity')
        .doc(userId)
        .collection('activities')
        .snapshots()
        .listen((snapshot) async {
      // needs to delay for few seconds to wait for creating activity
      await Future.delayed(const Duration(seconds: 2));

      if (!isStatsFetch) {
        isStatsFetch = true;
        _goalSteps = await getTargetSteps(userId);
        _targetChange = await getTargetStepChange(userId);
        await fetchtTodayActivityOverview(userId);
      }
    });
  }

  void setFetchToFalse() {
    isOverviewFetch = false;
    isStatsFetch = false;
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

  Future<int> getTargetSteps(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      int targetSteps = await activityService.getTargetSteps(userId);
      return targetSteps;
    } catch (e) {
      print("Error fetching user's target steps: $e");
    }

    _isLoading = false;
    notifyListeners();

    return 0; // return 0 if error occurs
  }

  Future<double> getTargetStepChange(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      double targetStepChange =
          await activityService.getTargetStepChange(userId);
      return targetStepChange;
    } catch (e) {
      print("Error fetching user's target steps: $e");
    }

    _isLoading = false;
    notifyListeners();

    return 0; // return 0 if error occurs
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

  Future<void> fetchtTodayActivityOverview(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _todayActivitySummary =
          await activityService.getTodayActivitySummary(userId);
      notifyListeners();
    } catch (e) {
      print("Error fetching stats activity overview: $e");
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
    isOverviewFetch = false;
    isStatsFetch = false;

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
