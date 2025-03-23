import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/api/mindfulness_service.dart';
import 'package:my_app/providers/ActivityProvider.dart';
import 'package:permission_handler/permission_handler.dart';

class MindfulnessProvider with ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final MindfulnessService service = MindfulnessService();
  ActivityProvider activityProvider = ActivityProvider();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // MOOD RECORDS
  double _mood = 0;
  double get mood => _mood;

  void listenToMoodChanges(String userId) {
    firestore
        .collection('mindfulness')
        .doc(userId)
        .collection('mood_record')
        .snapshots()
        .listen((snapshot) async {
      // needs to delay for few seconds to wait for creating activity
      await Future.delayed(const Duration(seconds: 3));
      await fetchWeeklyAverageMood(userId);
      notifyListeners();
    });
  }

  Future<void> fetchWeeklyAverageMood(String userId) async {
    // if (_isMoodFetched) return;

    _isLoading = true;
    notifyListeners();

    try {
      _mood = await service.getWeeklyAverageMood(userId);
      notifyListeners();
    } catch (e) {
      print("Error fetching mood: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<DateTime, int>> fetchAllMoodRecords(String userId) async {
    try {
      Map<DateTime, int> record = await service.fetchAllMoodRecords(userId);
      notifyListeners();

      return record;
    } catch (e) {
      return {};
    }
  }

  Future<Map<DateTime, int>> fetchPerMonthMoodRecords(
      String userId, int month, int year) async {
    try {
      Map<DateTime, int> record =
          await service.fetchPerMonthMoodRecords(userId, month, year);
      notifyListeners();

      return record;
    } catch (e) {
      return {};
    }
  }

  Future<String> saveMoodRecord(String userId, int selectedMood) async {
    try {
      await service.saveMoodRecord(userId, selectedMood);
      notifyListeners();

      return "success";
    } catch (e) {
      return "Unexpected error occurred while saving the mood record.";
    }
  }

  // JOURNAL ENTRIES

  Future<DateTime> getUserCreatedAt(String userId) async {
    try {
      DateTime monthYear = await service.getUserCreatedAt(userId);
      return monthYear;
    } catch (e) {
      DateTime today = DateTime.now();
      return DateTime(today.year, today.month);
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
      String userId, DateTime selectedMonth) async {
    List<Map<String, dynamic>> entries = [];
    entries = await service.fetchEntries(userId, selectedMonth);

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

  Future<List<Map<String, dynamic>>> fetchLogs(String userId) async {
    List<Map<String, dynamic>> logs = [];
    logs = await service.fetchLogs(userId);

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

  Future<void> checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.isDenied) {
        await Permission.photos.request();
      }
      if (await Permission.camera.isDenied) {
        await Permission.camera.request();
      }
      if (await Permission.storage.isDenied &&
          Platform.version.startsWith('10')) {
        await Permission.storage.request();
      }
    }
  }
}
