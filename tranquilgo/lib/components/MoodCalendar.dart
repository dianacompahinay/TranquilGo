import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/providers/MindfulnessProvider.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  MindfulnessProvider mindfulnessProvider = MindfulnessProvider();
  Map<DateTime, int> moodData = {};

  bool isConnectionFailed = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadMoods();
  }

  void loadMoods() async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<DateTime, int> moods =
          await mindfulnessProvider.fetchAllMoodRecords(userId);

      setState(() {
        moodData = moods;
      });
    } catch (e) {
      setState(() {
        isConnectionFailed = true;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 2, bottom: 22),
        child: isLoading
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.421,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF36B9A5),
                    strokeWidth: 5,
                  ),
                ),
              )
            : isConnectionFailed
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.421,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // calendar widget
                      TableCalendar(
                        firstDay: DateTime.utc(2025, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: DateTime.now(),
                        calendarStyle: const CalendarStyle(
                          isTodayHighlighted: false,
                        ),
                        headerStyle: HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                          decoration: const BoxDecoration(color: Colors.white),
                          titleTextStyle: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2A2A2A),
                            ),
                          ),
                          headerMargin: EdgeInsets.zero,
                        ),
                        // week days title style
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                  fontSize: 11, color: Color(0xFF797B86)),
                              fontWeight: FontWeight.w600),
                          weekendStyle: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                  fontSize: 11, color: Color(0xFF797B86)),
                              fontWeight: FontWeight.w600),
                        ),
                        daysOfWeekHeight: 28,
                        rowHeight: 42,
                        calendarBuilders: CalendarBuilders(
                          // display the mood in
                          defaultBuilder: (context, day, focusedDay) {
                            final normalizedDay =
                                DateTime(day.year, day.month, day.day);
                            if (moodData.keys.any(
                                (date) => isSameDate(date, normalizedDay))) {
                              final mood = moodData.entries
                                  .firstWhere(
                                    (entry) =>
                                        isSameDate(entry.key, normalizedDay),
                                    orElse: () => MapEntry(DateTime(2000), 3),
                                  )
                                  .value;
                              return Container(
                                margin: const EdgeInsets.only(
                                    left: 9, right: 9, top: 8, bottom: 8),
                                decoration: BoxDecoration(
                                  // color based on the mood data
                                  color: getMoodColor(mood),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: const TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              );
                            }
                            return null; // returns null if no mood data for the day
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: buildMoodLegend(), // legend items
                      ),
                    ],
                  ),
      ),
    );
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    // normalize DateTime to remove the time component (set time to 00:00:00)
    final normalizedDate1 = DateTime(date1.year, date1.month, date1.day);
    final normalizedDate2 = DateTime(date2.year, date2.month, date2.day);
    return normalizedDate1.isAtSameMomentAs(normalizedDate2);
  }

  List<Widget> buildMoodLegend() {
    final moodColors = {
      'Stressed': const Color(0xFFA5AFF1),
      'Sad': const Color(0xFFCEBFE7),
      'Neutral': const Color(0xFFC3D1D0),
      'Calm': const Color(0xFF67E1EA),
      'Happy': const Color(0xFF53F2CC),
    };

    return moodColors.entries
        .map((entry) => Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  // color representing the mood
                  decoration: BoxDecoration(
                    color: entry.value,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 4),
                // mood name
                Text(
                  entry.key,
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      color: Color(0xFF3F3F3F),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ))
        .toList();
  }

  Color getMoodColor(int mood) {
    switch (mood) {
      case 5:
        return const Color(0xFF53F2CC);
      case 4:
        return const Color(0xFF67E1EA);
      case 3:
        return const Color(0xFFC3D1D0);
      case 2:
        return const Color(0xFFCEBFE7);
      case 1:
        return const Color(0xFFA5AFF1);
      default:
        return const Color(0xFFFFFFFF); // default color
    }
  }
}
