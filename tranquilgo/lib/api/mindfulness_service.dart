import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MindfulnessService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
        String formattedDate =
            DateFormat('MMM d, yyyy').format(timestamp); // Format the date

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
