import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  // map to store moods associated with specific dates
  Map<DateTime, String> moodData = {
    DateTime(2025, 1, 1): 'Happy',
    DateTime(2025, 1, 2): 'Calm',
    DateTime(2025, 1, 3): 'Calm',
    DateTime(2025, 1, 4): 'Stressed',
    DateTime(2025, 1, 5): 'Sad',
    DateTime(2025, 1, 6): 'Happy',
    DateTime(2025, 1, 7): 'Neutral',
    DateTime(2025, 1, 8): 'Stressed',
    DateTime(2025, 1, 9): 'Sad',
    DateTime(2025, 1, 10): 'Calm',
    DateTime(2025, 1, 11): 'Happy',
    DateTime(2025, 1, 12): 'Sad',
    DateTime(2025, 1, 31): 'Happy',
    DateTime(2024, 12, 31): 'Happy',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 2, bottom: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // calendar widget
            TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
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
                    textStyle:
                        const TextStyle(fontSize: 11, color: Color(0xFF797B86)),
                    fontWeight: FontWeight.w600),
                weekendStyle: GoogleFonts.inter(
                    textStyle:
                        const TextStyle(fontSize: 11, color: Color(0xFF797B86)),
                    fontWeight: FontWeight.w600),
              ),
              daysOfWeekHeight: 28,
              rowHeight: 42,
              calendarBuilders: CalendarBuilders(
                // display the mood in
                defaultBuilder: (context, day, focusedDay) {
                  final normalizedDay = DateTime(
                      day.year, day.month, day.day); // Strip the time part
                  if (moodData.keys
                      .any((date) => isSameDate(date, normalizedDay))) {
                    final mood = moodData.entries
                        .firstWhere(
                          (entry) => isSameDate(entry.key, normalizedDay),
                          orElse: () => MapEntry(DateTime(2000), 'Neutral'),
                        )
                        .value;
                    return Container(
                      margin: const EdgeInsets.only(
                          left: 9, right: 9, top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        // color based on the mood data
                        color: _getMoodColor(mood),
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
              children: _buildMoodLegend(), // legend items
            ),
          ],
        ),
      ),
    );
  }

  // normalize DateTime to remove the time component (set time to 00:00:00)
  bool isSameDate(DateTime date1, DateTime date2) {
    // normalize both dates to remove time component
    final normalizedDate1 = DateTime(date1.year, date1.month, date1.day);
    final normalizedDate2 = DateTime(date2.year, date2.month, date2.day);
    return normalizedDate1.isAtSameMomentAs(normalizedDate2);
  }

  List<Widget> _buildMoodLegend() {
    final moodColors = {
      'Happy': const Color(0xFF53F2CC),
      'Calm': const Color(0xFF67E1EA),
      'Neutral': const Color(0xFFC3D1D0),
      'Sad': const Color(0xFFCEBFE7),
      'Stressed': const Color(0xFFA5AFF1),
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

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Happy':
        return const Color(0xFF53F2CC);
      case 'Calm':
        return const Color(0xFF67E1EA);
      case 'Neutral':
        return const Color(0xFFC3D1D0);
      case 'Sad':
        return const Color(0xFFCEBFE7);
      case 'Stressed':
        return const Color(0xFFA5AFF1);
      default:
        return const Color(0xFFFFFFFF); // default color
    }
  }
}
