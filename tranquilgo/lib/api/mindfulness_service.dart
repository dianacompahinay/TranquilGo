import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:image/image.dart' as img;

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:my_app/local_db.dart';

class MindfulnessService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // cloudinary instance
  final cloudinary = Cloudinary.full(
    apiKey: '483599581764523',
    apiSecret: 'vVuK6Dnhi0rr-Qg_wFFjSKcRoAo',
    cloudName: 'de8e3mj0x',
  );

  // MOOD RECORD

  Future<double> getWeeklyAverageMood(String userId) async {
    try {
      DateTime now = DateTime.now();

      // get the current start and end of the week
      DateTime startOfWeek =
          DateTime(now.year, now.month, now.day - (now.weekday - 1));
      DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

      CollectionReference moodCollection = firestore
          .collection('mindfulness')
          .doc(userId)
          .collection('mood_record');

      QuerySnapshot moodSnapshot = await moodCollection.get();

      List<double> weeklyMoods = [];

      for (QueryDocumentSnapshot doc in moodSnapshot.docs) {
        List<String> parts = doc.id.split('-');
        int month = int.parse(parts[0]);
        int year = int.parse(parts[1]);

        Map<String, dynamic> moods = doc.get('moods');

        moods.forEach((date, moodValue) {
          double moodDouble = (moodValue as num).toDouble();
          DateTime moodDate = DateTime(year, month, int.parse(date));

          // filter only records from monday to sunday of this week
          if (moodDate.isAfter(
                  startOfWeek.subtract(const Duration(milliseconds: 1))) &&
              moodDate
                  .isBefore(endOfWeek.add(const Duration(milliseconds: 1)))) {
            weeklyMoods.add(moodDouble);
          }
        });
      }

      if (weeklyMoods.isEmpty) return 0;

      // get the average
      double averageMood =
          weeklyMoods.reduce((a, b) => a + b) / weeklyMoods.length;
      return double.parse(averageMood.toStringAsFixed(1));
    } catch (e) {
      throw Exception('Failed to calculate weekly average mood');
    }
  }

  Future<Map<DateTime, int>> fetchAllMoodRecords(String userId) async {
    try {
      Map<DateTime, int> moodData = {};

      if (await LocalDatabase.isOnline()) {
        // fetch from Firestore if online
        CollectionReference moodCollection = FirebaseFirestore.instance
            .collection('mindfulness')
            .doc(userId)
            .collection('mood_record');

        QuerySnapshot moodSnapshot = await moodCollection.get();

        for (QueryDocumentSnapshot doc in moodSnapshot.docs) {
          List<String> parts = doc.id.split('-');
          int month = int.parse(parts[0]);
          int year = int.parse(parts[1]);

          Map<String, dynamic> moods = doc.get('moods');
          moods.forEach((date, moodValue) {
            int roundedMood = (moodValue as num).round();
            DateTime moodDate = DateTime(year, month, int.parse(date));
            moodData[moodDate] = roundedMood;

            // Save to local storage for offline access
            LocalDatabase.saveMood(userId, doc.id, date, roundedMood.toDouble(),
                roundedMood.toDouble(), 1, 1);
          });
        }
      } else {
        // Fetch from local storage if offline
        moodData = await LocalDatabase.getAllStoredMoodRecords(userId);
      }

      return moodData;
    } catch (e) {
      throw Exception('Failed to fetch all mood records: ${e.toString()}');
    }
  }

  Future<Map<DateTime, int>> fetchPerMonthMoodRecords(
      String userId, int month, int year) async {
    try {
      String monthYear = '${month.toString().padLeft(2, '0')}-$year';
      Map<DateTime, int> moodData = {};

      if (await LocalDatabase.isOnline()) {
        DocumentReference moodDocRef = FirebaseFirestore.instance
            .collection('mindfulness')
            .doc(userId)
            .collection('mood_record')
            .doc(monthYear);

        DocumentSnapshot moodSnapshot = await moodDocRef.get();

        if (moodSnapshot.exists) {
          Map<String, dynamic> moods = moodSnapshot.get('moods');

          moods.forEach((date, moodValue) {
            int roundedMood = (moodValue as num).round();
            DateTime moodDate = DateTime(year, month, int.parse(date));
            moodData[moodDate] = roundedMood;

            // save to local storage for offline use
            LocalDatabase.saveMood(userId, monthYear, date,
                roundedMood.toDouble(), roundedMood.toDouble(), 1, 1);
          });
        }
      } else {
        // fetch from local storage if offline
        moodData = await LocalDatabase.getStoredMoodRecords(userId, monthYear);
      }

      return moodData;
    } catch (e) {
      throw Exception('Failed to fetch mood records: ${e.toString()}');
    }
  }

  Future<void> saveMoodRecord(String userId, int selectedMood) async {
    try {
      DateTime now = DateTime.now();
      String monthYear = DateFormat('MM-yyyy').format(now);
      String date = DateFormat('dd').format(now);

      double newSum = selectedMood.toDouble();
      double newAvg = selectedMood.toDouble();
      int newCount = 1;

      if (await LocalDatabase.isOnline()) {
        // fetch from Firestore if online
        DocumentReference moodDocRef = FirebaseFirestore.instance
            .collection('mindfulness')
            .doc(userId)
            .collection('mood_record')
            .doc(monthYear);

        DocumentSnapshot moodSnapshot = await moodDocRef.get();

        if (moodSnapshot.exists && moodSnapshot.data() != null) {
          Map<String, dynamic> data =
              moodSnapshot.data() as Map<String, dynamic>;

          if (data.containsKey('daily_mood')) {
            Map<String, dynamic> dailyMood = data['daily_mood'];
            String lastUpdatedDate = dailyMood['current_date'] ?? "";

            if (lastUpdatedDate == date) {
              double prevSum = (dailyMood['sum'] as num).toDouble();
              int prevCount = (dailyMood['count'] as num).toInt();

              newSum = prevSum + selectedMood;
              newCount = prevCount + 1;
              newAvg = newSum / newCount;
            }
          }
        }

        // save to Firestore
        await moodDocRef.set({
          'daily_mood': {
            'current_date': date,
            'sum': newSum,
            'count': newCount,
            'average': newAvg,
          },
          'moods': {date: newAvg},
        }, SetOptions(merge: true));

        // save to local database (mark as synced)
        await LocalDatabase.saveMood(
            userId, monthYear, date, newAvg, newSum, newCount, 1);
      } else {
        // save to local storage when offline (mark as unsynced)
        await LocalDatabase.saveMood(
            userId, monthYear, date, newAvg, newSum, newCount, 0);
      }
    } catch (e) {
      throw Exception('Failed to save mood record: ${e.toString()}');
    }
  }

  // JOURNAL ENTRIES

  Future<DateTime> getUserCreatedAt(String userId) async {
    try {
      final db = await LocalDatabase.database;

      List<Map<String, dynamic>> result = await db.query(
        'users',
        columns: ['createdAt'],
        where: 'userId = ?',
        whereArgs: [userId],
      );

      if (result.isNotEmpty) {
        String createdAtStr = result.first['createdAt'];
        DateTime createdAt = DateTime.parse(createdAtStr);
        return DateTime(createdAt.year, createdAt.month);
      } else {
        // temporary only to prevent error
        DateTime today = DateTime.now();
        return DateTime(today.year, today.month);
      }
    } catch (e) {
      throw Exception("Failed to get user createdAt");
    }
  }

  Future<int> getUserEntriesCount(String userId, DateTime selectedMonth) async {
    try {
      final db = await LocalDatabase.database;

      // get the date range for the current month
      String startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1)
          .toIso8601String();
      String endOfMonth =
          DateTime(selectedMonth.year, selectedMonth.month + 1, 0, 23, 59, 59)
              .toIso8601String();

      // query local database for count of entries within the selected month
      List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM journal_entries 
        WHERE userId = ? 
        AND timestamp >= ? 
        AND timestamp <= ?
        AND deleted == 0
      ''', [userId, startOfMonth, endOfMonth]);

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception("Failed to get user entries count: ${e.toString()}");
    }
  }

  Future<List<Map<String, dynamic>>> fetchEntries(
      String userId, DateTime selectedMonth) async {
    try {
      final db = await LocalDatabase.database;

      String startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1)
          .toIso8601String();
      String endOfMonth =
          DateTime(selectedMonth.year, selectedMonth.month + 1, 0, 23, 59, 59)
              .toIso8601String();

      // base query
      String query = '''
        SELECT * FROM journal_entries 
          WHERE userId = ? 
          AND timestamp >= ? 
          AND timestamp <= ? 
          AND deleted == 0
          ORDER BY timestamp DESC 
        ''';

      List<dynamic> queryArgs = [userId, startOfMonth, endOfMonth];

      // execute query
      List<Map<String, dynamic>> result = await db.rawQuery(query, queryArgs);
      return result.map((entry) {
        DateTime dateTime = DateTime.parse(entry["timestamp"]);
        String formattedDate = DateFormat('MMMM dd, yyyy').format(dateTime);

        // ensure images field is a valid JSON array, fallback to empty list if invalid
        List<String> images =
            entry["images"] != null && entry["images"].isNotEmpty
                ? entry["images"].split('-*-') // unique separator
                : [];

        return {
          "entryId": entry["id"],
          "timestamp": dateTime.millisecondsSinceEpoch,
          "date": formattedDate,
          "images": images,
          "content": entry["content"] ?? "",
          "updatedAt": entry["updatedAt"],
        };
      }).toList();
    } catch (e) {
      throw Exception("Failed to fetch journal entries");
    }
  }

  Future<File> convertToJpg(File imageFile) async {
    final token = ServicesBinding.rootIsolateToken;
    if (token == null) {
      throw Exception(
          "RootIsolateToken is null. Ensure this runs in UI isolate.");
    }

    return compute(convertToJpgIsolate, Args(imageFile.path, token));
  }

  // isolate function to avoid UI thread overload
  Future<File> convertToJpgIsolate(Args params) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(params.token);

    String filePath = params.filePath;
    String newPath = filePath.replaceAll(RegExp(r'\.\w+$'), '.jpg');
    File imageFile = File(filePath);

    try {
      Uint8List imageBytes;

      // heic/heif conversion
      if (filePath.toLowerCase().endsWith('.heic') ||
          filePath.toLowerCase().endsWith('.heif')) {
        String? jpgPath =
            await HeifConverter.convert(filePath, output: newPath);
        if (jpgPath == null) {
          throw Exception("HEIC conversion failed");
        }

        File jpgFile = File(jpgPath);
        img.Image converted = await fixImageOrientation(jpgFile);

        // convert back to file
        await jpgFile.writeAsBytes(img.encodeJpg(converted, quality: 80));

        return jpgFile;
      }

      // read image bytes
      imageBytes = await imageFile.readAsBytes();

      // decode Image
      img.Image? decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        throw Exception("Unsupported image format: $filePath");
      }

      // reduce size
      decodedImage = img.copyResize(decodedImage, width: 1000);
      List<int> jpgBytes = img.encodeJpg(decodedImage, quality: 90);

      // save new file
      File jpgFile = File(newPath);
      await jpgFile.writeAsBytes(jpgBytes);

      return jpgFile;
    } catch (e) {
      throw Exception("Error converting image: $e");
    }
  }

  Future<img.Image> fixImageOrientation(File imageFile) async {
    try {
      img.Image? decodedImage = img.decodeImage(imageFile.readAsBytesSync());
      if (decodedImage == null) {
        throw Exception("Failed to decode image.");
      }
      return img.copyRotate(decodedImage, angle: 90); // rotate 90°
    } catch (e) {
      throw Exception("Image rotation failed.");
    }
  }

  Future<File> compressImage(File file) async {
    return await compute(compressImageInIsolate, file);
  }

  File compressImageInIsolate(File file) {
    final bytes = file.readAsBytesSync();
    final image = img.decodeImage(bytes);
    final compressedFile = File(file.path)
      ..writeAsBytesSync(img.encodeJpg(image!, quality: 85));
    return compressedFile;
  }

  Future<void> createJournalEntry(
      String userId, List<File> images, String content) async {
    try {
      List<String> localImagePaths = [];
      Directory appDir = await getApplicationDocumentsDirectory();
      String imagesDir = "${appDir.path}/journal_images";
      await Directory(imagesDir).create(recursive: true);

      // save images locally
      for (File imageFile in images) {
        if (!imageFile.existsSync()) continue;

        File processedFile = await convertToJpg(imageFile);
        File resizedFile = await compressImage(processedFile);
        String uniqueFileName = "${const Uuid().v4()}.jpg";
        File savedFile = File("$imagesDir/$uniqueFileName");

        await resizedFile.copy(savedFile.path);
        localImagePaths.add(savedFile.path);
      }

      // generate journal id
      String journalId = const Uuid().v4();
      DateTime timestamp = DateTime.now();

      // save locally
      await LocalDatabase.saveJournalEntry(
          journalId, userId, content, localImagePaths, timestamp);
    } catch (e) {
      throw Exception("Failed to save journal entry");
    }
  }

  Future<void> editEntry(String userId, String entryId, List<String> images,
      String content) async {
    final db = await LocalDatabase.database;
    String updatedAt =
        DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now().toUtc());
    try {
      await db.update(
        'journal_entries',
        {
          "images": images.join('-*-'),
          "content": content,
          "updatedAt": updatedAt,
          "synced": 0, // mark as needing sync
        },
        where: "id = ? AND userId = ?",
        whereArgs: [entryId, userId],
      );
    } catch (e) {
      throw Exception("Failed to edit journal entry");
    }
  }

  Future<void> deleteEntry(String userId, String entryId) async {
    final db = await LocalDatabase.database;

    // mark as deleted locally
    await db.update(
      'journal_entries',
      {"deleted": 1}, // mark as deleted but unsynced
      where: "id = ? AND userId = ?",
      whereArgs: [entryId, userId],
    );
  }

  // GRATITUDE LOGS

  Future<int> getUserLogsCount(String userId) async {
    try {
      final db = await LocalDatabase.database;

      List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM gratitude_logs WHERE userId = ? AND deleted == 0',
        [userId],
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception("Failed to get logs count");
    }
  }

  Future<List<Map<String, dynamic>>> fetchLogs(String userId) async {
    final db = await LocalDatabase.database;

    try {
      // fetch logs stored in local database
      String query = '''
      SELECT * FROM gratitude_logs 
      WHERE userId = ? 
      AND deleted == 0
      ORDER BY timestamp DESC 
    ''';
      List<dynamic> queryArgs = [userId];

      List<Map<String, dynamic>> localLogs =
          await db.rawQuery(query, queryArgs);
      return localLogs.map((log) {
        String timestampString = log["timestamp"];
        DateTime timestamp = DateTime.parse(timestampString);
        String formattedDate = DateFormat('MMM d, yyyy').format(timestamp);

        return {
          "logId": log["id"],
          "date": formattedDate,
          "content": log["content"],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch logs: ${e.toString()}');
    }
  }

  Future<void> createLog(String userId, String content) async {
    try {
      DateTime timestamp = DateTime.now().toUtc();

      String logId = const Uuid().v4();

      // prepare log data
      Map<String, dynamic> logData = {
        "id": logId,
        "userId": userId,
        "timestamp": timestamp.toIso8601String(),
        "content": content,
        "synced": 0, // mark as unsynced by default
      };

      if (await LocalDatabase.isOnline()) {
        // If online, save directly to Firestore
        await firestore
            .collection("mindfulness")
            .doc(userId)
            .collection("gratitude_logs")
            .doc(logId)
            .set({
          "timestamp": timestamp,
          "content": content,
        });

        logData["synced"] = 1; // mark as synced
      }
      // save log locally
      await LocalDatabase.saveGratitudeLog(logData);
    } catch (e) {
      throw Exception('Failed to create log: ${e.toString()}');
    }
  }

  Future<void> deleteLog(String userId, String logId) async {
    try {
      final db = await LocalDatabase.database;

      // soft delete: mark as deleted locally
      await db.update(
        'gratitude_logs',
        {"deleted": 1}, // Mark as deleted
        where: "id = ? AND userId = ?",
        whereArgs: [logId, userId],
      );

      // if online, sync the deletion to Firestore
      if (await LocalDatabase.isOnline()) {
        await firestore
            .collection("mindfulness")
            .doc(userId)
            .collection("gratitude_logs")
            .doc(logId)
            .delete();

        // remove from local database after successful sync
        await db.delete(
          'gratitude_logs',
          where: "id = ? AND userId = ?",
          whereArgs: [logId, userId],
        );
      }
    } catch (e) {
      throw Exception("Failed to delete log");
    }
  }
}

class Args {
  final String filePath;
  final RootIsolateToken token;
  Args(this.filePath, this.token);
}
