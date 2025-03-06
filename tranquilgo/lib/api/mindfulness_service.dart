import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

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
      CollectionReference moodCollection = firestore
          .collection('mindfulness')
          .doc(userId)
          .collection('mood_record');

      QuerySnapshot moodSnapshot = await moodCollection.get();

      Map<DateTime, int> moodData = {};

      for (QueryDocumentSnapshot doc in moodSnapshot.docs) {
        // extract month and year from the ID
        List<String> parts = doc.id.split('-');
        int month = int.parse(parts[0]);
        int year = int.parse(parts[1]);

        // mood data map
        Map<String, dynamic> moods = doc.get('moods');

        moods.forEach((date, moodValue) {
          int roundedMood = (moodValue as num).round();

          DateTime moodDate = DateTime(year, month, int.parse(date));
          moodData[moodDate] = roundedMood;
        });
      }

      return moodData;
    } catch (e) {
      throw Exception('Failed to fetch all mood records');
    }
  }

  Future<Map<DateTime, int>> fetchPerMonthMoodRecords(
      String userId, int month, int year) async {
    try {
      String monthYear = '${month.toString().padLeft(2, '0')}-$year';

      DocumentReference moodDocRef = firestore
          .collection('mindfulness')
          .doc(userId)
          .collection('mood_record')
          .doc(monthYear);

      DocumentSnapshot moodSnapshot = await moodDocRef.get();

      Map<DateTime, int> moodData = {};

      if (moodSnapshot.exists) {
        Map<String, dynamic> moods = moodSnapshot.get('moods');

        moods.forEach((date, moodValue) {
          int roundedMood = (moodValue as num).round();
          DateTime moodDate = DateTime(year, month, int.parse(date));
          moodData[moodDate] = roundedMood;
        });
      }

      return moodData;
    } catch (e) {
      print('Error fetching mood records: $e');
      throw Exception('Failed to fetch mood records');
    }
  }

  Future<void> saveMoodRecord(String userId, int selectedMood) async {
    try {
      DateTime now = DateTime.now();
      String monthYear = DateFormat('MM-yyyy').format(now);
      String date = DateFormat('dd').format(now);

      DocumentReference moodDocRef = firestore
          .collection('mindfulness')
          .doc(userId)
          .collection('mood_record')
          .doc(monthYear);

      DocumentSnapshot moodSnapshot = await moodDocRef.get();

      // if multiple activities are recorded in a day, the mood value is averaged
      // daily_mood field is included to maintain the day's average

      double newSum = selectedMood.toDouble();
      double newAvg = selectedMood.toDouble();
      int newCount = 1;

      if (moodSnapshot.exists && moodSnapshot.data() != null) {
        Map<String, dynamic> data = moodSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey('daily_mood')) {
          Map<String, dynamic> dailyMood = data['daily_mood'];

          String lastUpdatedDate = dailyMood['current_date'] ?? "";
          if (lastUpdatedDate == date) {
            // if same day, update sum and count
            double prevSum = (dailyMood['sum'] as num).toDouble();
            int prevCount = (dailyMood['count'] as num).toInt();

            newSum = prevSum + selectedMood;
            newCount = prevCount + 1;
            newAvg = newSum / newCount;
          }
        }
      }

      await moodDocRef.set({
        'daily_mood': {
          'current_date': date, // track the last updated date
          'sum': newSum,
          'count': newCount,
          'average': newAvg,
        },
        'moods': {
          date: newAvg, // save daily average in moods map
        },
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save mood record: ${e.toString()}');
    }
  }

  // JOURNAL ENTRIES

  Future<DateTime?> getUserCreatedAt(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Timestamp? createdAtTimestamp = userDoc['createdAt'] as Timestamp?;
        if (createdAtTimestamp != null) {
          DateTime createdAt = createdAtTimestamp.toDate();
          return DateTime(createdAt.year, createdAt.month);
          // format: DateTime(YYYY, MM)
        }
      }
    } catch (e) {
      throw Exception('Failed to fetch logs: ${e.toString()}');
    }
    return null;
  }

  Future<int?> getUserEntriesCount(
      String userId, DateTime selectedMonth) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DateTime startOfMonth =
        DateTime(selectedMonth.year, selectedMonth.month, 1);
    DateTime endOfMonth =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 0, 23, 59, 59);

    // convert DateTime to Timestamp
    Timestamp startTimestamp = Timestamp.fromDate(startOfMonth);
    Timestamp endTimestamp = Timestamp.fromDate(endOfMonth);

    AggregateQuerySnapshot query = await firestore
        .collection('mindfulness')
        .doc(userId)
        .collection('journal_entries')
        .where("timestamp", isGreaterThanOrEqualTo: startTimestamp)
        .where("timestamp", isLessThanOrEqualTo: endTimestamp)
        .count()
        .get();

    return query.count;
  }

  Future<List<Map<String, dynamic>>> fetchEntries(
      String userId, String? lastEntryId, DateTime selectedMonth) async {
    int limit = 6; // fetch in batches
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DateTime startOfMonth =
          DateTime(selectedMonth.year, selectedMonth.month, 1);
      // moves to the next month and sets the time to 11:59:59 PM
      DateTime endOfMonth =
          DateTime(selectedMonth.year, selectedMonth.month + 1, 0, 23, 59, 59);

      Query query = firestore
          .collection("mindfulness")
          .doc(userId)
          .collection("journal_entries")
          .where("timestamp", isGreaterThanOrEqualTo: startOfMonth)
          .where("timestamp", isLessThanOrEqualTo: endOfMonth)
          .orderBy("timestamp", descending: true)
          .limit(limit);

      if (lastEntryId != null) {
        DocumentSnapshot lastDoc = await firestore
            .collection("mindfulness")
            .doc(userId)
            .collection("journal_entries")
            .doc(lastEntryId)
            .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        } else {
          return [];
        }
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        Timestamp timestamp = doc["timestamp"] as Timestamp;
        DateTime dateTime = timestamp.toDate();
        String formattedDate = DateFormat('MMMM dd, yyyy').format(dateTime);

        return {
          "entryId": doc.id,
          "timestamp": timestamp.millisecondsSinceEpoch,
          "date": formattedDate,
          "images": List<String>.from(doc["images"] ?? []),
          "content": doc["content"] ?? "",
          "updatedAt": (doc.data() as Map<String, dynamic>?)?["updatedAt"],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch journal entries: ${e.toString()}');
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
      List<String> uploadedImageUrls = [];

      if (images.isNotEmpty) {
        List<Future<String?>> uploadTasks = images.map((imageFile) async {
          if (!imageFile.existsSync()) {
            print("File does not exist: ${imageFile.path}");
            return null;
          }

          // compress and check for null
          final resizedFile = await compressImage(imageFile);
          if (resizedFile == null) {
            print("Failed to resize image: ${imageFile.path}");
            return null;
          }

          final response = await cloudinary.uploadResource(
            CloudinaryUploadResource(
              filePath: resizedFile.path,
              resourceType: CloudinaryResourceType.image,
              folder: 'journal_entries/$userId',
              publicId: "$userId${DateTime.now().millisecondsSinceEpoch}",
            ),
          );

          if (response.isSuccessful) {
            return response.secureUrl;
          } else {
            print("Cloudinary upload failed: ${response.error}");
            return null;
          }
        }).toList();

        uploadedImageUrls =
            (await Future.wait(uploadTasks)).whereType<String>().toList();
      }

      // ensure Firestore is initialized before writing
      if (firestore == null) {
        throw Exception("Firestore is not initialized.");
      }

      Timestamp timestamp = Timestamp.now();
      await firestore
          .collection("mindfulness")
          .doc(userId)
          .collection("journal_entries")
          .add({
        "timestamp": timestamp,
        "images": uploadedImageUrls, // empty list if no images
        "content": content,
      });

      print("Journal entry created successfully!");
    } catch (e) {
      print("Error creating journal entry: $e");
      throw Exception("Failed to create journal entry");
    }
  }

  Future<void> editEntry(String userId, String entryId, List<String> images,
      String content) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference entryRef = firestore
          .collection("mindfulness")
          .doc(userId)
          .collection("journal_entries")
          .doc(entryId);

      DocumentSnapshot entrySnapshot = await entryRef.get();
      if (entrySnapshot.exists) {
        String updatedAt = DateFormat('MMM dd, yyyy hh:mm a')
            .format(DateTime.now().toUtc().add(const Duration(hours: 8)));

        await entryRef.update({
          "images": images,
          "content": content,
          "updatedAt": updatedAt,
        });
      }
    } catch (e) {
      throw Exception("Failed to edit journal entry");
    }
  }

  Future<void> deleteEntry(String userId, String entryId) async {
    try {
      await firestore
          .collection("mindfulness")
          .doc(userId)
          .collection("journal_entries")
          .doc(entryId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete entry: ${e.toString()}');
    }
  }

  // GRATITUDE LOGS

  Future<int?> getUserLogsCount(String userId) async {
    AggregateQuerySnapshot query = await firestore
        .collection('mindfulness')
        .doc(userId)
        .collection('gratitude_logs')
        .count()
        .get();
    return query.count;
  }

  Future<List<Map<String, dynamic>>> fetchLogs(
      String userId, String? lastLogId) async {
    int limit = 8; // fetch by batch

    try {
      Query query = firestore
          .collection("mindfulness")
          .doc(userId)
          .collection("gratitude_logs")
          .orderBy("timestamp", descending: true) // Order by timestamp
          .limit(limit);

      if (lastLogId != null) {
        DocumentSnapshot lastDoc = await firestore
            .collection('mindfulness')
            .doc(userId)
            .collection("gratitude_logs")
            .doc(lastLogId)
            .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        } else {
          return [];
        }
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        DateTime timestamp = (doc["timestamp"] as Timestamp).toDate();
        String formattedDate = DateFormat('MMM d, yyyy').format(timestamp);

        return {
          "logId": doc.id,
          "date": formattedDate,
          "content": doc["content"],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch logs: ${e.toString()}');
    }
  }

  Future<void> createLog(String userId, String content) async {
    try {
      DateTime timestamp = DateTime.now().toUtc();

      await firestore
          .collection("mindfulness")
          .doc(userId)
          .collection("gratitude_logs")
          .add({
        "timestamp": timestamp,
        "content": content,
      });
    } catch (e) {
      throw Exception('Failed to create log: ${e.toString()}');
    }
  }

  Future<void> deleteLog(String userId, String logId) async {
    try {
      await firestore
          .collection("mindfulness")
          .doc(userId)
          .collection("gratitude_logs")
          .doc(logId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete log: ${e.toString()}');
    }
  }
}
