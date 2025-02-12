import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
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

  Future<void> createJournalEntry(
      String userId, List<File> images, String content) async {
    try {
      List<String?> uploadedImageUrls = [];

      for (File imageFile in images) {
        if (!imageFile.existsSync()) {
          return;
        }

        final compressedFile = await compressImage(File(imageFile.path));

        // upload image to cloudinary
        final response = await cloudinary.uploadResource(
          CloudinaryUploadResource(
            filePath: compressedFile.path,
            resourceType: CloudinaryResourceType.image,
            folder: 'journal_entries/$userId',
            publicId: "$userId${DateTime.now().millisecondsSinceEpoch}",
            progressCallback: (count, total) {
              print('Uploading: $count/$total');
            },
          ),
        );

        if (response.isSuccessful) {
          uploadedImageUrls.add(response.secureUrl);
        }
      }

      Timestamp timestamp = Timestamp.now();

      await firestore
          .collection("mindfulness")
          .doc(userId)
          .collection("journal_entries")
          .add({
        "timestamp": timestamp,
        "images": uploadedImageUrls,
        "content": content,
      });
    } catch (e) {
      print("Error creating journal entry: $e");
      throw Exception("Failed to create journal entry");
    }
  }

  Future<File> compressImage(File imageFile) async {
    final rawImage = img.decodeImage(await imageFile.readAsBytes());
    final compressed = img.encodeJpg(rawImage!, quality: 80);
    final newFile = File(imageFile.path)..writeAsBytesSync(compressed);
    return newFile;
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
