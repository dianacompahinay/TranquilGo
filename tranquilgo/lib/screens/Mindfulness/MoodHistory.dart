import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/providers/MindfulnessProvider.dart';

class MoodTrackingHistory extends StatefulWidget {
  const MoodTrackingHistory({super.key});

  @override
  _MoodTrackingHistoryState createState() => _MoodTrackingHistoryState();
}

class _MoodTrackingHistoryState extends State<MoodTrackingHistory> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  Map<String, List<ChartData>> monthlyMoodData = {};

  bool isConnectionFailed = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadMoodData();
  }

  Future<void> loadMoodData() async {
    final mindfulnessProvider =
        Provider.of<MindfulnessProvider>(context, listen: false);

    setState(() {
      isLoading = true;
    });

    try {
      var fetchedMoodData =
          await mindfulnessProvider.fetchAllMoodRecords(userId);
      Map<String, List<ChartData>> tempData = processMoodData(fetchedMoodData);

      setState(() {
        monthlyMoodData = tempData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isConnectionFailed = true;
      });
    }
  }

  Map<String, List<ChartData>> processMoodData(Map<DateTime, int> moodData) {
    Map<String, Map<int, int>> groupedMoods = {};

    moodData.forEach((date, moodValue) {
      String monthYear = DateFormat('MM-yyyy').format(date);

      if (!groupedMoods.containsKey(monthYear)) {
        groupedMoods[monthYear] = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      }

      groupedMoods[monthYear]![moodValue] =
          (groupedMoods[monthYear]![moodValue] ?? 0) + 1;
    });

    // convert counts to ChartData list
    Map<String, List<ChartData>> chartDataMap = {};
    groupedMoods.forEach((monthYear, moodCounts) {
      chartDataMap[monthYear] = [
        ChartData('Happy', moodCounts[5]!, const Color(0xFF53F2CC)),
        ChartData('Calm', moodCounts[4]!, const Color(0xFF67E1EA)),
        ChartData('Neutral', moodCounts[3]!, const Color(0xFFC3D1D0)),
        ChartData('Sad', moodCounts[2]!, const Color(0xFFCEBFE7)),
        ChartData('Stressed', moodCounts[1]!, const Color(0xFFA5AFF1)),
      ];
    });

    return chartDataMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isLoading || isConnectionFailed || monthlyMoodData.isEmpty
          ? AppBar(
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
            )
          : null,
      body: isLoading
          ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF36B9A5),
                  strokeWidth: 5,
                ),
              ),
            )
          : isConnectionFailed
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
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
              : !isLoading && monthlyMoodData.isEmpty
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: Center(
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
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.transparent,
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
                            (() {
                              // group months by year
                              Map<int, List<MapEntry<String, List<ChartData>>>>
                                  groupedByYear = {};
                              for (var entry in monthlyMoodData.entries) {
                                int year = int.parse(
                                    entry.key.split('-')[1]); // Extract year
                                groupedByYear
                                    .putIfAbsent(year, () => [])
                                    .add(entry);
                              }

                              // build widgets for each year
                              return groupedByYear.entries.map((yearEntry) {
                                int year = yearEntry.key;
                                List<MapEntry<String, List<ChartData>>>
                                    monthsData = yearEntry.value;

                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 5, bottom: 40),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Year $year',
                                        style: GoogleFonts.inter(
                                          textStyle: const TextStyle(
                                            color: Color(0xFF4A4949),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // per month
                                      Wrap(
                                        spacing: 24.0,
                                        runSpacing: 35.0,
                                        children: List.generate(
                                          monthsData.length,
                                          (index) {
                                            String monthYear =
                                                monthsData[index].key;
                                            List<String> parts =
                                                monthYear.split('-');
                                            int month = int.parse(parts[0]);
                                            List<ChartData> chartData =
                                                monthsData[index].value;

                                            return SizedBox(
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      80) /
                                                  2,
                                              child: buildMonthChart(
                                                  year, month, chartData),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList();
                            })(),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget buildMonthChart(int year, int month, List<ChartData> chartData) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 12, bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFC),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            DateFormat('MMMM').format(DateTime(year, month)),
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                color: Color(0xFF5E6C6A),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: 145,
            child: SfCircularChart(
              series: <CircularSeries>[
                DoughnutSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.label,
                  yValueMapper: (ChartData data, _) => data.value,
                  pointColorMapper: (ChartData data, _) => data.color,
                  radius: '100%',
                  innerRadius: '55%',
                  enableTooltip: true,
                  explode: true,
                  selectionBehavior: SelectionBehavior(enable: true),
                  animationDuration: 0,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String label;
  final int value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}
