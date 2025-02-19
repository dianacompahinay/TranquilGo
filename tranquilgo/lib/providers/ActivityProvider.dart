import 'package:flutter/foundation.dart';
import 'package:my_app/api/activity_service.dart';

class ActivityProvider with ChangeNotifier {
  final ActivityService activityService = ActivityService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

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

  Future<String> updateWeeklyGoal(String userId, int targetSteps) async {
    try {
      await activityService.updateWeeklyGoal(userId, targetSteps);
      notifyListeners();
      return 'success';
    } catch (e) {
      return 'failed';
    }
  }

  Future<void> createWeeklyActivityForAllUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      await activityService.createWeeklyActivityForAllUsers();
    } catch (error) {
      if (kDebugMode) {
        print("Error creating weekly activity: $error");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
