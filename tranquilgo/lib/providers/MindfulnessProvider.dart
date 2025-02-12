import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:my_app/api/mindfulness_service.dart';

class MindfulnessProvider with ChangeNotifier {
  final MindfulnessService service = MindfulnessService();

  // JOURNAL ENTRIES

  Future<DateTime?> getUserCreatedAt(String userId) async {
    try {
      DateTime? monthYear = await service.getUserCreatedAt(userId);
      return monthYear;
    } catch (e) {
      return null;
    }
  }

  Future<int?> getUserEntriesCount(
      String userId, DateTime selectedMonth) async {
    try {
      int? count = await service.getUserEntriesCount(userId, selectedMonth);
      return count;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> fetchEntries(
      String userId, String? lastEntryId, DateTime selectedMonth) async {
    List<Map<String, dynamic>> entries = [];
    entries = await service.fetchEntries(userId, lastEntryId, selectedMonth);

    return entries;
  }

  Future<String> addEntry(
      String userId, List<File> images, String content) async {
    try {
      await service.createJournalEntry(userId, images, content);
      notifyListeners();

      return "success";
    } catch (e) {
      return "Unexpected error occurred while creating the entry.";
    }
  }

  Future<String> editEntry(String userId, String entryId, List<String> images,
      String content) async {
    try {
      await service.editEntry(userId, entryId, images, content);
      notifyListeners();

      return "success";
    } catch (e) {
      return "Unexpected error occurred while editing the entry.";
    }
  }

  Future<String> deleteEntry(String userId, String entryId) async {
    try {
      await service.deleteEntry(userId, entryId);
      notifyListeners();

      return "success";
    } catch (e) {
      return "Unexpected error occurred while deleting the entry.";
    }
  }

  // GRATITUDE LOGS

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
