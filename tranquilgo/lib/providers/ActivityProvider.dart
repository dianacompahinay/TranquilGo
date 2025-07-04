import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:my_app/api/activity_service.dart';

class ActivityProvider with ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ActivityService activityService = ActivityService();

  int _steps = 0;
  int _goalSteps = 0;
  String _targetChange = "";

  // for stats graph view
  String rangeType = 'Weekly';
  DateTime graphStartDate = DateTime.now();
  List<int> _stepsPerDateRange = [];
  Map<String, dynamic> _activityStats = {
    'totalSteps': 0,
    'totalDistance': 0.0,
    'totalDuration': 0,
    'selfEfficacy': "Low",
  };

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
  bool _isStatsLoading = true;
  bool _isGraphLoading = true; // separate loading for stats graphs

  bool isOverviewFetch = false;
  bool isStatsFetch = false;

  int get steps => _steps;
  int get goalSteps => _goalSteps;
  String get targetChange => _targetChange;
  List<int> get stepsPerDateRange => _stepsPerDateRange;

  Map<String, dynamic> get weeklyActivitySummary => _weeklyActivitySummary;
  Map<String, dynamic> get todayActivitySummary => _todayActivitySummary;
  Map<String, dynamic> get activityStats => _activityStats;

  bool get isLoading => _isLoading;
  bool get isStatsLoading => _isStatsLoading;
  bool get isGraphLoading => _isGraphLoading;

  void initialLoad(String userId) async {
    if (!isOverviewFetch && !isStatsFetch) {
      await getTotalSteps(userId);
      await fetchtWeeklyActivityOverview(userId);
      _goalSteps = await getTargetSteps(userId);
      _targetChange = await getTargetStepChange(userId);
      await fetchtTodayActivityOverview(userId);
      await fetchStepsByDateRange(userId, rangeType, graphStartDate);
      isOverviewFetch = true;
      isStatsFetch = true;
    }
  }

  void listenToActivityChanges(String userId) {
    firestore
        .collection('weekly_activity')
        .doc(userId)
        .collection('activities')
        .snapshots()
        .listen((snapshot) async {
      // needs to delay for few seconds to wait for creating activity
      await Future.delayed(const Duration(seconds: 3));

      if (!isOverviewFetch) {
        isOverviewFetch = true;
        await getTotalSteps(userId);
        await fetchtWeeklyActivityOverview(userId);
      }
    });
  }

  void listenToActivityStatsChanges(String userId) {
    graphStartDate = getMondayOfCurrentWeek();

    firestore
        .collection('weekly_activity')
        .doc(userId)
        .collection('activities')
        .snapshots()
        .listen((snapshot) async {
      // needs to delay for few seconds to wait for creating activity
      await Future.delayed(const Duration(seconds: 1));
      if (!isStatsFetch) {
        isStatsFetch = true;
        _goalSteps = await getTargetSteps(userId);
        _targetChange = await getTargetStepChange(userId);
        await fetchtTodayActivityOverview(userId);
        await fetchStepsByDateRange(userId, rangeType, graphStartDate);
      }
    });
  }

  void setGraphView(String currentTab, DateTime date) {
    rangeType = currentTab;
    graphStartDate = date;
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
    _isStatsLoading = true;
    notifyListeners();

    try {
      int targetSteps = await activityService.getTargetSteps(userId);
      return targetSteps;
    } catch (e) {
      print("Error fetching user's target steps: $e");
    }

    _isStatsLoading = false;
    notifyListeners();

    return 0; // return 0 if error occurs
  }

  Future<String> getTargetStepChange(String userId) async {
    _isStatsLoading = true;
    notifyListeners();

    try {
      String targetStepChange =
          await activityService.getTargetStepChange(userId);
      return targetStepChange;
    } catch (e) {
      print("Error fetching user's target steps: $e");
    }

    _isStatsLoading = false;
    notifyListeners();

    return ""; // return 0 if error occurs
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
    _isStatsLoading = true;
    notifyListeners();

    try {
      _todayActivitySummary =
          await activityService.getTodayActivitySummary(userId);
      notifyListeners();
    } catch (e) {
      print("Error fetching stats activity overview: $e");
    }

    _isStatsLoading = false;
    notifyListeners();
  }

  Future<void> fetchStepsByDateRange(
      String userId, String rangeType, DateTime startDate) async {
    _isGraphLoading = true;
    notifyListeners();

    try {
      _stepsPerDateRange = await activityService.fetchStepsByDateRange(
          userId, rangeType, startDate);
      _activityStats = await activityService.fetchActivityStats(
          userId, rangeType, startDate);
    } catch (e) {
      print("Error fetching stats activity overview: $e");

      // return default lists filled with 0s
      if (rangeType == 'Weekly') {
        _stepsPerDateRange = List.generate(7, (index) => 0);
      } else if (rangeType == 'Monthly') {
        _stepsPerDateRange = List.generate(31, (index) => 0);
      } else if (rangeType == 'Yearly') {
        _stepsPerDateRange = List.generate(12, (index) => 0);
      } else {
        _stepsPerDateRange = [];
      }

      _activityStats = {
        'totalSteps': 0,
        'totalDistance': 0.0,
        'totalDuration': 0,
        'selfEfficacy': "Low",
      };
    }
    _isGraphLoading = false;
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
    int seScore,
    int mood,
  ) async {
    isOverviewFetch = false;
    isStatsFetch = false;

    try {
      await activityService.createActivity(userId, date, startTime, endTime,
          timeDuration, numSteps, distanceCovered, seScore, mood);
      notifyListeners();

      return 'success';
    } catch (e) {
      return 'failed';
    }
  }

  DateTime getMondayOfCurrentWeek() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday; // monday = 1, sunday = 7
    return now.subtract(Duration(days: currentWeekday - 1));
  }

  Future<String> updateStreak(String userId, String type) async {
    try {
      await activityService.updateStreak(userId, type);
      notifyListeners();
      return 'success';
    } catch (e) {
      return 'failed';
    }
  }
}
