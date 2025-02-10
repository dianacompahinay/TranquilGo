import 'package:flutter/foundation.dart';
import 'package:my_app/api/activity_service.dart';

class ActivityProvider with ChangeNotifier {
  final ActivityService _activityService = ActivityService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> createWeeklyActivityForAllUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _activityService.createWeeklyActivityForAllUsers();
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
