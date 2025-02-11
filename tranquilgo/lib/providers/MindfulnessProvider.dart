import 'package:flutter/foundation.dart';

import 'package:my_app/api/mindfulness_service.dart';

class MindfulnessProvider with ChangeNotifier {
  final MindfulnessService service = MindfulnessService();

  Future<int?> getUserLogsCount(String userId) async {
    try {
      int? count = await service.getUserLogsCount(userId);
      return count;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> fetchLogs(
      String userId, String? lastLogId) async {
    List<Map<String, dynamic>> logs = [];
    logs = await service.fetchLogs(userId, lastLogId);

    return logs;
  }

  Future<String> addLog(String userId, String content) async {
    try {
      await service.createLog(userId, content);
      notifyListeners();

      return "success";
    } catch (e) {
      return "Unexpected error occurred while creating the log.";
    }
  }

  Future<String> deleteLog(String userId, String logId) async {
    try {
      await service.deleteLog(userId, logId);
      notifyListeners();

      return "success";
    } catch (e) {
      return "Unexpected error occurred while deleting the log.";
    }
  }
}
