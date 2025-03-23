import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:my_app/local_db.dart';
import 'package:my_app/providers/MindfulnessProvider.dart';
import 'package:provider/provider.dart';

class JournalEntries extends StatefulWidget {
  const JournalEntries({super.key});

  @override
  _JournalEntriesState createState() => _JournalEntriesState();
}

class _JournalEntriesState extends State<JournalEntries> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> journalEntries = [];

  bool isAscending = false;
  Map<int, bool> expandedTexts = {}; // for see more and show less
  DateTime selectedMonth = DateTime.now();
  DateTime startingMonthTab = DateTime.now();

  bool fetchLoading = true;
  bool syncing = false;
  bool loadingMonthTab = true;
  bool isConnectionFailed = false;

  @override
  void initState() {
    super.initState();
    initializeJournal();
  }

  void initializeJournal() async {
    final mindfulnessProvider =
        Provider.of<MindfulnessProvider>(context, listen: false);
    await mindfulnessProvider.checkAndRequestPermissions();

    setState(() {
      loadingMonthTab = true;
    });
    if (await LocalDatabase.needsJournalSync(userId)) {
      setState(() {
        syncing = true;
      });

      if (await LocalDatabase.isOnline()) {
        await LocalDatabase.syncMissingJournalEntries(userId);
      }
    }

    setState(() {
      syncing = false;
      loadingMonthTab = false;
    });
    getStartingMonthTab();
  }

  Future<void> getStartingMonthTab() async {
    final mindfulnessProvider =
        Provider.of<MindfulnessProvider>(context, listen: false);
    setState(() {
      loadingMonthTab = true;
    });
    try {
      DateTime? fetchMonth = await mindfulnessProvider.getUserCreatedAt(userId);
      if (fetchMonth != null) {
        setState(() {
          startingMonthTab = fetchMonth;
        });
        initializeEntries();
      }
    } catch (e) {
      setState(() {
        isConnectionFailed = true;
      });
    }
    setState(() {
      loadingMonthTab = false;
    });
  }

  Future<void> initializeEntries() async {
    final mindfulnessProvider =
        Provider.of<MindfulnessProvider>(context, listen: false);
    setState(() {
      fetchLoading = true;
      journalEntries = [];
    });

    try {
      journalEntries =
          await mindfulnessProvider.fetchEntries(userId, selectedMonth);
    } catch (e) {
      setState(() {
        isConnectionFailed = true;
      });
    } finally {
      setState(() {
        fetchLoading = false;
      });
    }
  }

  void sortEntries() {
    setState(() {
      journalEntries.sort((a, b) => isAscending
          ? a['timestamp'].compareTo(b['timestamp'])
          : b['timestamp'].compareTo(a['timestamp']));
    });
  }

  void showImageModal(File imageFile) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Builder(
              builder: (context) {
                if (imageFile.existsSync()) {
                  return Image.file(
                    imageFile, // load from local file
                    fit: BoxFit.cover,
                  );
                } else {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        // file is missing
                        Icons.broken_image,
                        color: Colors.grey[600],
                        size: 50,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                toolbarHeight: 60,
                leading: Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: SizedBox(
                      width: 30,
                      height: 30,
                      child: Image.asset(
                        'assets/images/back-arrow.png',
                        fit: BoxFit.contain,
                        color: const Color(0xFF6C6C6C),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                title: Text(
                  "Mindfulness",
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      color: Color(0xFF110000),
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                ),
                elevation: 0,
                centerTitle: true,
                automaticallyImplyLeading: false,
                floating: false,
                pinned: false,
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                // subtitle
                                Transform.translate(
                                  offset: const Offset(0, -4),
                                  child: Text(
                                    "Reflection Notes",
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        color: Color(0xFF606060),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // month selection tabs
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: loadingMonthTab
                                  ? [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 34, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: Colors.grey[300],
                                          ),
                                        ),
                                      ),
                                    ]
                                  : generateMonthTabs(DateTime.now(),
                                      startingMonthTab, selectedMonth),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // journal entries header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/icons/sidebar_logs.png',
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.contain,
                                    color: const Color(0xFF494949),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Journal Entries',
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF494949),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.sort,
                                    color: Color(0xFF606060)),
                                onSelected: (value) {
                                  setState(() {
                                    isAscending = value == 'Ascending';
                                  });
                                  sortEntries();
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem<String>(
                                    value: 'Descending',
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 10),
                                      child: const Text(
                                        'Sort by Latest',
                                        style:
                                            TextStyle(color: Color(0xFF606060)),
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'Ascending',
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 10),
                                      child: const Text(
                                        'Sort by Oldest',
                                        style:
                                            TextStyle(color: Color(0xFF606060)),
                                      ),
                                    ),
                                  ),
                                ],
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ],
                          ),
                          syncing
                              ? SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.sync_alt_rounded,
                                          color: Color(0xFF999999),
                                          size: 30,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Syncing Entries",
                                          style: GoogleFonts.poppins(
                                            textStyle: const TextStyle(
                                              color: Color(0xFF999999),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                            ),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : isConnectionFailed
                                  ? SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/icons/error.png',
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.contain,
                                              color: const Color(0xFF999999),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Connection Failed",
                                              style: GoogleFonts.poppins(
                                                textStyle: const TextStyle(
                                                  color: Color(0xFF999999),
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : journalEntries.isEmpty &&
                                          !fetchLoading &&
                                          !loadingMonthTab
                                      ? SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.5,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/icons/rainy.png',
                                                  width: 32,
                                                  height: 32,
                                                  fit: BoxFit.contain,
                                                  color:
                                                      const Color(0xFF999999),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "It's empty here...",
                                                  style: GoogleFonts.poppins(
                                                    textStyle: const TextStyle(
                                                      color: Color(0xFF999999),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      :
                                      // load journal entries
                                      Column(
                                          children: [
                                            ...journalEntries
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              int i = entry.key;
                                              var data = entry.value;

                                              return journalEntry(
                                                index: i,
                                                entryId: data['entryId'],
                                                date: data['date'],
                                                images: data['images'],
                                                content: data['content'],
                                                updatedAt: data['updatedAt'],
                                              );
                                            }).toList(),
                                            fetchLoading
                                                ? SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.15,
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color:
                                                            Color(0xFF36B9A5),
                                                        strokeWidth: 5,
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            const SizedBox(height: 45),
                                          ],
                                        ),
                          const SizedBox(height: 45),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // add entry button
          Positioned(
            bottom: 10,
            right: 10,
            child: SizedBox(
              height: 38,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  String? result =
                      await Navigator.pushNamed(context, '/addentry');
                  if (result != null && result.isNotEmpty) {
                    initializeEntries();
                  }
                },
                label: Text(
                  'Add entry',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      color: Color(0xFF585757),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.add,
                  color: Color(0xFF585757),
                  size: 20,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // create month tabs
  Widget monthTab(String label, DateTime monthDate, {bool isActive = false}) {
    return GestureDetector(
      onTap:
          // to prevent rendering of entries from another month while fetching
          fetchLoading
              ? null
              : () {
                  setState(() {
                    selectedMonth = monthDate;
                  });
                  initializeEntries();
                },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF73D2C3) : const Color(0xFFD6F5F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF6DCABB),
              fontSize: 12.5,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // generate month tabs dynamically
  List<Widget> generateMonthTabs(
      DateTime startMonth, DateTime endMonth, DateTime selectedMonth) {
    // ensure startMonth is after or equal to endMonth
    if (startMonth.isBefore(endMonth)) {
      final temp = startMonth;
      startMonth = endMonth;
      endMonth = temp;
    }

    List<Widget> tabs = [];
    DateTime currentMonth = startMonth;

    //  start from the current month to the oldest month
    while (currentMonth.isAfter(endMonth) ||
        currentMonth.isAtSameMomentAs(endMonth)) {
      // abbreviated month names (e.g. Jan 2025)
      String monthName = DateFormat('MMM yyyy').format(currentMonth);
      tabs.add(
        monthTab(
          monthName,
          currentMonth,
          isActive: selectedMonth.month == currentMonth.month &&
              selectedMonth.year == currentMonth.year,
        ),
      );
      // decrement the month
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    }

    return tabs;
  }

  // create journal entries
  Widget journalEntry({
    required int index,
    required String entryId,
    required String date,
    required List<String> images,
    required String content,
    required String? updatedAt,
  }) {
    final mindfulnessProvider =
        Provider.of<MindfulnessProvider>(context, listen: false);
    final isExpanded = expandedTexts[index] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF646464),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xFF767676),
                size: 22,
              ),
              onSelected: (value) async {
                if (value == 'View') {
                  String? result = await Navigator.pushNamed(
                    context,
                    '/viewentry',
                    arguments: {
                      'entryId': entryId,
                      'date': date,
                      'images': images,
                      'content': content,
                      'updatedAt': updatedAt
                    },
                  );
                  if (result != null && result.isNotEmpty) {
                    initializeEntries();
                  }
                } else if (value == 'Delete') {
                  String result =
                      await mindfulnessProvider.deleteEntry(userId, entryId);
                  if (result != "success") {
                    showBottomSnackBar(context, result);
                  } else {
                    setState(() {
                      journalEntries
                          .removeWhere((entry) => entry['entryId'] == entryId);
                    });
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'View',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Text(
                      'View',
                      style: TextStyle(color: Color(0xFF606060)),
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Delete',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Color(0xFF606060)),
                    ),
                  ),
                ),
              ],
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
        Transform.translate(
          offset: const Offset(0, -10),
          child: const Divider(thickness: 1),
        ),
        if (images.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: images.map<Widget>((imagePath) {
                return GestureDetector(
                  onTap: () => showImageModal(File(imagePath)),
                  child: Container(
                    margin: const EdgeInsets.only(left: 2, right: 8),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Builder(
                        builder: (context) {
                          File imageFile = File(imagePath);

                          if (imageFile.existsSync()) {
                            return Image.file(
                              imageFile, // load from local file
                              fit: BoxFit.cover,
                            );
                          } else {
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(
                                  // file is missing
                                  Icons.broken_image,
                                  color: Colors.grey[600],
                                  size: 50,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        if (images.isNotEmpty) const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            setState(() {
              expandedTexts[index] = !isExpanded;
            });
          },
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              children: [
                TextSpan(
                  text: isExpanded
                      ? content
                      : content.length > 150
                          ? '${content.substring(0, 150)}...'
                          : content,
                ),
                if (content.length > 150)
                  TextSpan(
                    text: isExpanded ? ' Show less' : ' See more',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  void showBottomSnackBar(BuildContext context, String text) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 20,
        left: 16,
        right: 16,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF2BB1C0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              text,
              style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
