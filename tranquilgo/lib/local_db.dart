import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:my_app/api/activity_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _database;

  // initialize or get database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  // create database
  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'activities.db');
    return await openDatabase(
      path,
      version: 2, // increment version when modifying tables
      onCreate: (db, version) async {
        // create table for activities
        await db.execute('''
        CREATE TABLE activities(
          id TEXT PRIMARY KEY,
          userId TEXT,
          date TEXT,
          startTime TEXT,
          endTime TEXT,
          timeDuration INTEGER,
          numSteps INTEGER,
          distanceCovered REAL,
          seScore INTEGER,
          mood INTEGER,
          synced INTEGER DEFAULT 0
        )
        ''');

        // create table for tracking streaks
        await db.execute('''
        CREATE TABLE streaks(
          userId TEXT PRIMARY KEY,
          streak INTEGER,
          lastActivityDate TEXT
        )
        ''');

        // create table for mood records
        await db.execute('''
        CREATE TABLE mood_records(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT,
          monthYear TEXT,
          date TEXT,
          average REAL,
          sum REAL,
          count INTEGER,
          synced INTEGER DEFAULT 0
        )
        ''');

        await db.execute('''
        CREATE TABLE journal_entries(
          id TEXT PRIMARY KEY,
          userId TEXT,
          timestamp TEXT, -- Store original timestamp
          images TEXT, -- Store as comma-separated string
          content TEXT,
          updatedAt TEXT NULL, -- NULL initially, updated on edit
          synced INTEGER DEFAULT 0,
          deleted INTEGER DEFAULT 0 
        )
        ''');

        // create table for gratitude logs
        await db.execute('''
        CREATE TABLE gratitude_logs(
          id TEXT PRIMARY KEY,
          userId TEXT,
          timestamp TEXT,
          content TEXT,
          synced INTEGER DEFAULT 0,
          deleted INTEGER DEFAULT 0 -- 1 if deleted locally
        )
        ''');

        // for time when user is created (for journal page month tab)
        await db.execute('''
        CREATE TABLE users (
          userId TEXT PRIMARY KEY,
          createdAt TEXT
        )
        ''');
      },
    );
  }

  // check internet connectivity
  static Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // STREAK --------------------------------------------------------------------

  static Future<void> syncStreakData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> allStreaks =
        await getAllStoredStreaks(); // fetch all users data

    for (var streakData in allStreaks) {
      String userId = streakData['userId'];
      DateTime lastActivityDate =
          DateTime.parse(streakData['lastActivityDate']);
      int storedStreak = streakData['streak'];

      final userDocRef = firestore.collection("weekly_activity").doc(userId);

      await userDocRef.update({
        'streak': storedStreak,
        'lastActivityDate': lastActivityDate,
      });

      // clear synced data from local database
      await clearStreakData(userId);
    }
  }

  // save Last Activity Date & Streak Locally
  static Future<void> saveStreak(String userId, int streak) async {
    final db = await database;
    await db.insert(
      'streaks',
      {'userId': userId, 'streak': streak, 'lastActivityDate': DateTime.now()},
      conflictAlgorithm: ConflictAlgorithm.replace, // update if already exists
    );
  }

  // fetch All Stored Streaks (For All Users)
  static Future<List<Map<String, dynamic>>> getAllStoredStreaks() async {
    final db = await database;
    return await db.query('streaks'); // fetch all streaks stored in local DB
  }

  // clear Streak Data After Syncing
  static Future<void> clearStreakData(String userId) async {
    final db = await database;
    await db.delete(
      'streaks',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // ACTIVITY ------------------------------------------------------------------

  static Future<void> saveActivity(Map<String, dynamic> activity) async {
    final db = await database;
    await db.insert('activities', activity,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> syncActivities() async {
    List<Map<String, dynamic>> unsyncedActivities =
        await getUnsyncedActivities();

    for (var activity in unsyncedActivities) {
      await syncActivityToFirestore(activity);
    }
  }

  static Future<void> syncActivityToFirestore(
      Map<String, dynamic> activityData) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    ActivityService activityService = ActivityService();

    DocumentReference weeklyActivityRef =
        firestore.collection('weekly_activity').doc(activityData['userId']);
    CollectionReference activitiesRef =
        weeklyActivityRef.collection('activities');

    await activitiesRef.doc(activityData['id']).set({
      'date': activityData['date'],
      'startTime':
          Timestamp.fromDate(DateTime.parse(activityData['startTime'])),
      'endTime': Timestamp.fromDate(DateTime.parse(activityData['endTime'])),
      'timeDuration': activityData['timeDuration'],
      'numSteps': activityData['numSteps'],
      'distanceCovered': activityData['distanceCovered'],
      'seScore': activityData['seScore'],
      'recentMood': activityData['mood'],
    });

    // update the weekly summary
    DocumentSnapshot weeklySnapshot = await weeklyActivityRef.get();
    if (weeklySnapshot.exists) {
      Map<String, dynamic> weeklyData =
          weeklySnapshot.data() as Map<String, dynamic>;

      await weeklyActivityRef.update({
        'activityCount': (weeklyData['activityCount'] ?? 0) + 1,
        'totalSEscore':
            (weeklyData['totalSEscore'] ?? 0.0) + activityData['seScore'],
        'totalDistance': (weeklyData['totalDistance'] ?? 0.0) +
            activityData['distanceCovered'],
        'totalStepsTaken':
            (weeklyData['totalStepsTaken'] ?? 0) + activityData['numSteps'],
      });
    }

    // update user's steps
    await firestore.collection('users').doc(activityData['userId']).update({
      "steps": FieldValue.increment(activityData['numSteps']),
    });

    // update user's streak
    await activityService.updateStreak(activityData['userId'], "create");

    await LocalDatabase.markAsSynced(activityData['id']);
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedActivities() async {
    final db = await database;
    return await db.query('activities', where: 'synced = 0');
  }

  // mark an activity as synced
  static Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update('activities', {'synced': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  // MINDFULNESS: MOOD ---------------------------------------------------------

  static Future<void> saveMood(String userId, String monthYear, String date,
      int selectedMood, int synced) async {
    final db = await database;

    // check if an entry exists for the given userId, monthYear, and date
    final List<Map<String, dynamic>> existingRecords = await db.query(
      'mood_records',
      where: 'userId = ? AND monthYear = ? AND date = ?',
      whereArgs: [userId, monthYear, date],
    );

    if (existingRecords.isNotEmpty) {
      // record exists, update sum, count, and average
      Map<String, dynamic> existingRecord = existingRecords.first;
      double prevSum = (existingRecord['sum'] as num).toDouble();
      int prevCount = (existingRecord['count'] as num).toInt();

      double newSum = prevSum + selectedMood;
      int newCount = prevCount + 1;
      double newAvg = newSum / newCount;

      await db.update(
        'mood_records',
        {
          'average': newAvg,
          'sum': newSum,
          'count': newCount,
          'synced': synced, // keep synced status
        },
        where: 'userId = ? AND monthYear = ? AND date = ?',
        whereArgs: [userId, monthYear, date],
      );
    } else {
      // no record exists, insert new entry
      await db.insert(
        'mood_records',
        {
          'userId': userId,
          'monthYear': monthYear,
          'date': date,
          'average': selectedMood,
          'sum': selectedMood,
          'count': 1,
          'synced': synced, // 1 = Synced, 0 = Not Synced
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<Map<DateTime, int>> getAllStoredMoodRecords(
      String userId) async {
    final db = await database;

    List<Map<String, dynamic>> records = await db
        .query('mood_records', where: 'userId = ?', whereArgs: [userId]);

    Map<DateTime, int> moodData = {};
    for (var record in records) {
      // extract year and month from "MM-YYYY"
      List<String> parts = record['monthYear'].split('-');
      int month = int.parse(parts[0]); // extract month
      int year = int.parse(parts[1]); // extract year

      DateTime moodDate = DateTime(year, month, int.parse(record['date']));
      moodData[moodDate] = (record['average'] as num).round();
    }
    return moodData;
  }

  static Future<Map<DateTime, int>> getCurrentMonthMoods(
      String userId, String monthYear) async {
    final db = await database;
    List<Map<String, dynamic>> records = await db.query(
      'mood_records',
      where: 'userId = ? AND monthYear = ?',
      whereArgs: [userId, monthYear],
    );

    Map<DateTime, int> moodData = {};
    for (var record in records) {
      // extract year and month from "MM-YYYY"
      List<String> parts = monthYear.split('-');
      int month = int.parse(parts[0]); // extract month
      int year = int.parse(parts[1]); // extract year

      DateTime moodDate = DateTime(year, month, int.parse(record['date']));
      moodData[moodDate] = (record['average'] as num).round();
    }

    return moodData;
  }

  static Future<double> getWeeklyAverageMood(
      String userId, DateTime startOfWeek, DateTime endOfWeek) async {
    final db = await database;

    List<Map<String, dynamic>> records = await db.query(
      'mood_records',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    List<double> weeklyMoods = [];

    for (var record in records) {
      // extract year and month
      List<String> parts = record['monthYear'].split('-');
      int month = int.parse(parts[0]);
      int year = int.parse(parts[1]);

      DateTime moodDate = DateTime(year, month, int.parse(record['date']));

      // filter only moods that fall within the current week
      if (moodDate
              .isAfter(startOfWeek.subtract(const Duration(milliseconds: 1))) &&
          moodDate.isBefore(endOfWeek.add(const Duration(milliseconds: 1)))) {
        weeklyMoods.add((record['average'] as num).toDouble());
      }
    }

    if (weeklyMoods.isEmpty) return 0.0;

    // calculate and return the weekly average mood (rounded to 1 decimal)
    double averageMood =
        weeklyMoods.reduce((a, b) => a + b) / weeklyMoods.length;
    return double.parse(averageMood.toStringAsFixed(1));
  }

  // sync mood record from firestore
  static Future<void> syncOnlineMoodRecords(String userId) async {
    if (!await isOnline()) return;

    try {
      // fetch from Firestore if online
      CollectionReference moodCollection = FirebaseFirestore.instance
          .collection('mindfulness')
          .doc(userId)
          .collection('mood_record');

      QuerySnapshot moodSnapshot = await moodCollection.get();

      for (QueryDocumentSnapshot doc in moodSnapshot.docs) {
        Map<String, dynamic> moods = doc.get('moods');
        moods.forEach((date, moodValue) {
          int roundedMood = (moodValue as num).round();
          // save to local storage
          saveMood(userId, doc.id, date, roundedMood.toInt(), 1);
        });
      }
    } catch (e) {
      throw Exception('Failed to fetch all mood records: ${e.toString()}');
    }
  }

  // sync local mood records to Firestore when online
  static Future<void> syncLocalMoodRecords() async {
    if (!await isOnline()) return;

    final db = await database;
    List<Map<String, dynamic>> unsyncedMoods =
        await db.query('mood_records', where: 'synced = 0');

    for (var mood in unsyncedMoods) {
      String userId = mood['userId'];
      String monthYear = mood['monthYear'];
      String date = mood['date'];

      DocumentReference moodDocRef = FirebaseFirestore.instance
          .collection('mindfulness')
          .doc(userId)
          .collection('mood_record')
          .doc(monthYear);

      await moodDocRef.set({
        'daily_mood': {
          'current_date': date,
          'sum': mood['sum'],
          'count': mood['count'],
          'average': mood['average'],
        },
        'moods': {
          date: mood['average'],
        },
      }, SetOptions(merge: true));

      // mark as synced after successful upload
      await db.update('mood_records', {'synced': 1},
          where: 'userId = ? AND monthYear = ? AND date = ?',
          whereArgs: [userId, monthYear, date]);
    }
  }

  // MINDFULNESS: JOURNAL NOTES ------------------------------------------------

  static Future<void> saveJournalEntry(String id, String userId, String content,
      List<String> images, DateTime timestamp) async {
    final db = await database;

    // check if the journal entry already exists
    final existing = await db.query(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (existing.isNotEmpty) {
      return; // avoid duplicate insertion
    }

    await db.insert(
      'journal_entries',
      {
        'id': id,
        'userId': userId,
        'content': content,
        'images': images.join('-*-'),
        'timestamp': timestamp.toIso8601String(),
        'synced': 0, // Mark as unsynced
      },
    );
  }

  static Future<void> syncJournalEntries() async {
    if (!await LocalDatabase.isOnline()) return;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // cloudinary instance
    final cloudinary = Cloudinary.full(
      apiKey: '483599581764523',
      apiSecret: 'vVuK6Dnhi0rr-Qg_wFFjSKcRoAo',
      cloudName: 'de8e3mj0x',
    );

    List<Map<String, dynamic>> unsyncedEntries = await getUnsyncedJournals();

    for (var journal in unsyncedEntries) {
      String userId = journal['userId'];
      String content = journal['content'];
      String? updatedAt = journal['updatedAt'];
      List<String> localImagePaths = journal['images'];
      DateTime originalTimestamp =
          DateTime.parse(journal['timestamp']); // use saved timestamp

      List<String> uploadedImageUrls = [];
      for (String localPath in localImagePaths) {
        File imageFile = File(localPath);
        if (!imageFile.existsSync()) continue;

        final response = await cloudinary.uploadResource(
          CloudinaryUploadResource(
            filePath: localPath,
            resourceType: CloudinaryResourceType.image,
            folder: 'journal_entries/$userId',
            publicId: basenameWithoutExtension(localPath),
          ),
        );

        if (response.isSuccessful) {
          uploadedImageUrls.add(response.secureUrl!);
        }
      }

      // save journal entry to Firestore
      await firestore
          .collection("mindfulness")
          .doc(userId)
          .collection("journal_entries")
          .doc(journal["id"])
          .set({
        "timestamp": Timestamp.fromDate(originalTimestamp),
        "images": uploadedImageUrls,
        "content": content,
        "updatedAt": updatedAt
      });

      // mark as synced
      await LocalDatabase.markJournalAsSynced(journal['id']);
    }
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedJournals() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'journal_entries',
      where: 'synced = 0',
    );

    return results.map((entry) {
      return {
        'id': entry['id'],
        'userId': entry['userId'],
        'content': entry['content'],
        'images':
            (entry['images'] as String).split('-*-'), // convert string to list
        'updatedAt': entry['updatedAt'],
        'timestamp': entry['timestamp'],
      };
    }).toList();
  }

  static Future<void> markJournalAsSynced(String id) async {
    final db = await database;
    await db.update(
      'journal_entries',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<bool> needsJournalSync(String userId) async {
    if (!await isOnline()) return false; // No need to sync if offline

    final db = await database;

    // Get local journal count
    List<Map<String, dynamic>> localResult = await db.rawQuery(
      "SELECT COUNT(*) as count FROM journal_entries WHERE userId = ?",
      [userId],
    );
    int localCount = localResult.first["count"] as int? ?? 0;

    try {
      // get online journal count
      DocumentReference userRef =
          FirebaseFirestore.instance.collection("mindfulness").doc(userId);
      CollectionReference journalEntriesRef =
          userRef.collection("journal_entries");

      AggregateQuerySnapshot query = await journalEntriesRef.count().get();
      int onlineCount = query.count ?? 0;

      // if Firestore has more entries than local, syncing is needed
      return onlineCount > localCount;
    } catch (e) {
      return false; // assume no sync needed if Firestore fetch fails
    }
  }

  static Future<void> syncMissingJournalEntries(String userId) async {
    final db = await LocalDatabase.database;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // fetch all locally stored entry IDs
    List<Map<String, dynamic>> localEntries = await db.query(
      "journal_entries",
      columns: ["id"],
      where: "userId = ?",
      whereArgs: [userId],
    );

    Set<String> localEntryIds =
        localEntries.map((entry) => entry["id"].toString()).toSet();

    // fetch all Firestore journal entries
    QuerySnapshot firestoreEntries = await firestore
        .collection("mindfulness")
        .doc(userId)
        .collection("journal_entries")
        .get();

    List<Map<String, dynamic>> missingEntries = [];

    for (var doc in firestoreEntries.docs) {
      if (!localEntryIds.contains(doc.id)) {
        Map<String, dynamic> entryData = doc.data() as Map<String, dynamic>;
        List<String> cloudinaryUrls =
            List<String>.from(entryData["images"] ?? []);

        List<String> localPaths = await downloadImagesIfNeeded(cloudinaryUrls);

        missingEntries.add({
          "id": doc.id,
          "userId": userId,
          "timestamp":
              (entryData["timestamp"] as Timestamp).toDate().toIso8601String(),
          "content": entryData["content"] ?? "",
          "images": localPaths.join('-*-'), // save as local paths
          "updatedAt": entryData["updatedAt"],
          'synced': 1, // mark as synced
        });
      }
    }

    for (var entry in missingEntries) {
      await db.insert("journal_entries", entry);
    }
  }

  static Future<void> syncDeletedEntries() async {
    if (!await isOnline()) return;

    final db = await database;
    List<Map<String, dynamic>> deletedEntries = await db.query(
      'journal_entries',
      where: "deleted = 1",
    );

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    for (var entry in deletedEntries) {
      String entryId = entry["id"];
      String userId = entry["userId"];

      await firestore
          .collection("mindfulness")
          .doc(userId)
          .collection("journal_entries")
          .doc(entryId)
          .delete();

      // remove from local database after successful deletion
      await db.delete(
        'journal_entries',
        where: "id = ? AND userId = ?",
        whereArgs: [entryId, userId],
      );
    }
  }

  static Future<List<String>> downloadImagesIfNeeded(
      List<String> cloudinaryUrls) async {
    List<String> localPaths = [];

    for (String url in cloudinaryUrls) {
      String filename = url.split("/").last;
      String localPath = await getLocalImagePath(filename);

      if (await File(localPath).exists()) {
        localPaths.add(localPath); // Image already saved
      } else {
        try {
          localPaths.add(await downloadImage(url, localPath));
        } catch (e) {
          throw Exception("Failed to download image: $url - $e");
        }
      }
    }

    return localPaths;
  }

  static Future<String> downloadImage(String imageUrl, String savePath) async {
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(Uri.parse(imageUrl));
    HttpClientResponse response = await request.close();

    File file = File(savePath);
    IOSink sink = file.openWrite();
    await response.pipe(sink);
    await sink.close();

    return savePath; // Return saved file path
  }

  static Future<String> getLocalImagePath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/journal_images/$filename";
  }

  static Future<void> saveUserCreatedAt(
      String userId, DateTime createdAt) async {
    final db = await database;

    await db.insert(
      'users',
      {
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // update if exists
    );
  }

  static Future<void> syncUserCreatedAt(String userId) async {
    final db = await database;

    // check if createdAt is already stored locally
    List<Map<String, dynamic>> localResult = await db.query(
      'users',
      columns: ['createdAt'],
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (localResult.isEmpty || localResult.first['createdAt'] == null) {
      // fetch from firestore if not found in local database
      DateTime? createdAt = await getUserCreatedAtOnline(userId);

      if (createdAt != null) {
        await saveUserCreatedAt(userId, createdAt);
      }
    }
  }

  static Future<DateTime?> getUserCreatedAtOnline(String userId) async {
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
        }
      }
    } catch (e) {
      throw Exception('Failed to fetch logs: ${e.toString()}');
    }
    return null;
  }

  // MINDFULNESS: GRATITUDE LOGS -----------------------------------------------

  // save gratitude log to local storage
  static Future<void> saveGratitudeLog(Map<String, dynamic> logData) async {
    final db = await database;
    await db.insert('gratitude_logs', logData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // get all unsynced logs
  static Future<List<Map<String, dynamic>>> getUnsyncedLogs() async {
    final db = await database;
    return await db.query('gratitude_logs', where: 'synced = 0');
  }

  // sync all unsynced logs to Firestore
  static Future<void> syncGratitudeLogs() async {
    if (!await isOnline()) return;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> unsyncedLogs = await getUnsyncedLogs();

    for (var log in unsyncedLogs) {
      await firestore
          .collection("mindfulness")
          .doc(log["userId"])
          .collection("gratitude_logs")
          .add({
        "timestamp": DateTime.parse(log["timestamp"]),
        "content": log["content"],
      });

      // mark log as synced after uploading
      await markLogAsSynced(log["id"]);
    }
  }

  // mark log as synced
  static Future<void> markLogAsSynced(int id) async {
    final db = await database;
    await db.update('gratitude_logs', {"synced": 1},
        where: "id = ?", whereArgs: [id]);
  }

  static Future<bool> needsLogSync(String userId) async {
    if (!await isOnline()) return false; // No need to sync if offline

    final db = await database;

    // get local log count
    List<Map<String, dynamic>> localResult = await db.rawQuery(
      "SELECT COUNT(*) as count FROM gratitude_logs WHERE userId = ?",
      [userId],
    );
    int localCount = localResult.first["count"] as int? ?? 0;

    try {
      // get firestore log count
      DocumentReference userRef =
          FirebaseFirestore.instance.collection("mindfulness").doc(userId);
      CollectionReference logsRef = userRef.collection("gratitude_logs");

      AggregateQuerySnapshot query = await logsRef.count().get();
      int onlineCount = query.count ?? 0;

      // if Firestore has more logs than local, syncing is needed
      return onlineCount > localCount;
    } catch (e) {
      return false; // no sync needed if firestore fetch fails
    }
  }

  static Future<void> syncMissingLogs(String userId) async {
    final db = await LocalDatabase.database;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch all locally stored log IDs
    List<Map<String, dynamic>> localLogs = await db.query(
      "gratitude_logs",
      columns: ["id"],
      where: "userId = ?",
      whereArgs: [userId],
    );

    Set<String> localLogIds =
        localLogs.map((log) => log["id"].toString()).toSet();

    // Fetch all Firestore logs
    QuerySnapshot firestoreLogs = await firestore
        .collection("mindfulness")
        .doc(userId)
        .collection("gratitude_logs")
        .get();

    List<Map<String, dynamic>> missingLogs = [];

    for (var doc in firestoreLogs.docs) {
      if (!localLogIds.contains(doc.id)) {
        Map<String, dynamic> logData = doc.data() as Map<String, dynamic>;

        missingLogs.add({
          "id": doc.id,
          "userId": userId,
          "timestamp":
              (logData["timestamp"] as Timestamp).toDate().toIso8601String(),
          "content": logData["content"] ?? "",
          "synced": 1, // Mark as synced
        });
      }
    }

    for (var log in missingLogs) {
      await db.insert("gratitude_logs", log);
    }
  }

  static Future<void> syncDeletedLogs() async {
    if (!await isOnline()) return;

    final db = await database;

    // get all logs marked as deleted
    List<Map<String, dynamic>> deletedLogs = await db.query(
      'gratitude_logs',
      where: "deleted = 1",
    );

    for (var log in deletedLogs) {
      String logId = log["id"];
      String userId = log["userId"];

      await FirebaseFirestore.instance
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
  }
}
