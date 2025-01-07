import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class JournalNotes extends StatefulWidget {
  const JournalNotes({super.key});

  @override
  _JournalNotesState createState() => _JournalNotesState();
}

class _JournalNotesState extends State<JournalNotes> {
  // list of journal entries with DateTime
  List<Map<String, dynamic>> journalEntries = [
    {
      'date': DateTime(2024, 8, 12),
      'images': <String>[
        'assets/images/scenery1.jpg',
        'assets/images/scenery2.jpg'
      ],
      'content':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus lacinia erat vel ex interdum, nec facilisis enim volutpat. Integer feugiat massa ut sollicitudin auctor. Donec tincidunt volutpat nulla, vitae gravida orci efficitur ac. Vestibulum ullamcorper tortor vitae justo cursus, ac rutrum erat pretium. Cras sed ante id risus gravida vulputate. Sed id risus nec nisl luctus aliquet. Nullam tristique magna nec lectus mollis, eget faucibus felis posuere. Morbi eget velit sed urna lacinia volutpat. Integer luctus eu lorem vel faucibus. Ut gravida dui sit amet orci tempor, sit amet viverra risus euismod.',
    },
    {
      'date': DateTime(2024, 8, 11),
      'images': <String>[],
      'content':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus lacinia erat vel ex interdum, nec facilisis enim volutpat. Integer feugiat massa ut sollicitudin auctor. Donec tincidunt volutpat nulla, vitae gravida orci efficitur ac. Vestibulum ullamcorper tortor vitae justo cursus, ac rutrum erat pretium. Cras sed ante id risus gravida vulputate. Sed id risus nec nisl luctus aliquet. Nullam tristique magna nec lectus mollis, eget faucibus felis posuere. Morbi eget velit sed urna lacinia volutpat. Integer luctus eu lorem vel faucibus. Ut gravida dui sit amet orci tempor, sit amet viverra risus euismod.',
    },
    {
      'date': DateTime(2024, 8, 9),
      'images': <String>['assets/images/scenery3.jpg'],
      'content':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus lacinia erat vel ex interdum, nec facilisis enim volutpat. Integer feugiat massa ut sollicitudin auctor. Donec tincidunt volutpat nulla, vitae gravida orci efficitur ac. Vestibulum ullamcorper tortor vitae justo cursus, ac rutrum erat pretium. Cras sed ante id risus gravida vulputate. Sed id risus nec nisl luctus aliquet. Nullam tristique magna nec lectus mollis, eget faucibus felis posuere. Morbi eget velit sed urna lacinia volutpat. Integer luctus eu lorem vel faucibus. Ut gravida dui sit amet orci tempor, sit amet viverra risus euismod.',
    },
    {
      'date': DateTime(2024, 9, 20),
      'images': <String>[],
      'content':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus lacinia erat vel ex interdum, nec facilisis enim volutpat. Integer feugiat massa ut sollicitudin auctor.',
    },
    {
      'date': DateTime(2025, 1, 1),
      'images': <String>[
        'assets/images/scenery1.jpg',
        'assets/images/scenery2.jpg'
      ],
      'content':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus lacinia erat vel ex interdum, nec facilisis enim volutpat. Integer feugiat massa ut sollicitudin auctor. Donec tincidunt volutpat nulla, vitae gravida orci efficitur ac. Vestibulum ullamcorper tortor vitae justo cursus, ac rutrum erat pretium. Cras sed ante id risus gravida vulputate. Sed id risus nec nisl luctus aliquet. Nullam tristique magna nec lectus mollis, eget faucibus felis posuere. Morbi eget velit sed urna lacinia volutpat. Integer luctus eu lorem vel faucibus. Ut gravida dui sit amet orci tempor, sit amet viverra risus euismod.',
    },
    {
      'date': DateTime(2025, 1, 3),
      'images': <String>['assets/images/scenery3.jpg'],
      'content':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus lacinia erat vel ex interdum, nec facilisis enim volutpat. Integer feugiat massa ut sollicitudin auctor. Donec tincidunt volutpat nulla, vitae gravida orci efficitur ac. Vestibulum ullamcorper tortor vitae justo cursus, ac rutrum erat pretium. Cras sed ante id risus gravida vulputate. Sed id risus nec nisl luctus aliquet. Nullam tristique magna nec lectus mollis, eget faucibus felis posuere. Morbi eget velit sed urna lacinia volutpat. Integer luctus eu lorem vel faucibus. Ut gravida dui sit amet orci tempor, sit amet viverra risus euismod.',
    },
    {
      'date': DateTime(2025, 1, 6),
      'images': <String>[],
      'content':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus lacinia erat vel ex interdum, nec facilisis enim volutpat. Integer feugiat massa ut sollicitudin auctor.',
    },
  ];

  bool isAscending = true;
  Map<int, bool> expandedTexts = {}; // track expanded state
  DateTime? selectedMonth = DateTime.now();

  void sortEntries() {
    setState(() {
      journalEntries.sort((a, b) => isAscending
          ? a['date'].compareTo(b['date'])
          : b['date'].compareTo(a['date']));
    });
  }

  void showImageModal(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addNewEntry() {
    // setState(() {
    //   journalEntries.add({
    //     'date': DateTime.now(),
    //     'images': <String>[],
    //     'content': 'New journal entry content...',
    //   });
    // });
    Navigator.pushNamed(context, '/addentry');
  }

  // filter journal entries by selected month
  List<Map<String, dynamic>> get filteredEntries {
    if (selectedMonth == null) return journalEntries;

    return journalEntries.where((entry) {
      final entryDate = entry['date'];
      return entryDate.month == selectedMonth!.month &&
          entryDate.year == selectedMonth!.year;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 61),
                  Center(
                    child: Column(
                      children: [
                        // title
                        Text(
                          "Mindfulness",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color(0xFF110000),
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        // subtitle
                        Text(
                          "Reflection Notes",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color(0xFF606060),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
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
                      children: generateMonthTabs(
                          DateTime.now(), DateTime(2024, 8), selectedMonth),
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
                        icon: const Icon(Icons.sort, color: Color(0xFF606060)),
                        onSelected: (value) {
                          isAscending = value == 'Ascending';
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
                                style: TextStyle(color: Color(0xFF606060)),
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

                  // dynamically load journal entries
                  for (var i = 0; i < filteredEntries.length; i++)
                    journalEntry(
                      index: i,
                      date: filteredEntries[i]['date'],
                      images: filteredEntries[i]['images'],
                      content: filteredEntries[i]['content'],
                    ),
                  const SizedBox(height: 45),

                  if (filteredEntries.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/rainy.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                            color: const Color(0xFF999999),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "It's empty here...",
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
                ],
              ),
            ),

            // back button
            Positioned(
              top: 60,
              left: 0,
              child: Container(
                width: 42.0,
                height: 42.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F7F7),
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
            ),

            // add entry button
            Align(
              alignment: const Alignment(1.05, 0.95),
              child: SizedBox(
                height: 38,
                child: FloatingActionButton.extended(
                  onPressed: addNewEntry,
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
      ),
    );
  }

  // create month tabs
  Widget monthTab(String label, DateTime monthDate, {bool isActive = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMonth = monthDate;
        });
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
      DateTime startMonth, DateTime endMonth, DateTime? selectedMonth) {
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
          isActive: selectedMonth?.month == currentMonth.month &&
              selectedMonth?.year == currentMonth.year,
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
    required DateTime date,
    required List<String> images,
    required String content,
  }) {
    final dateFormatted = DateFormat('EEEE, dd MMMM yyyy').format(date);
    final isExpanded = expandedTexts[index] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateFormatted,
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
              // onSelected: (value) {
              //   isAscending = value == 'Ascending';
              //   sortEntries();
              // },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'Descending',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Text(
                      'View',
                      style: TextStyle(color: Color(0xFF606060)),
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Ascending',
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
                  onTap: () => showImageModal(imagePath),
                  child: Container(
                    margin: const EdgeInsets.only(left: 2, right: 8),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                          image: AssetImage(imagePath), fit: BoxFit.cover),
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
                      : '${content.substring(0, 150)}...', // truncated text
                ),
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
}
