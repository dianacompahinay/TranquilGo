import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/ProgressBar.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/providers/ActivityProvider.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  String currentTab = 'Weekly';
  DateTime startDate = DateTime.now();

  bool isConnectionFailed = false;
  bool isConnectionFailedGraph = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      startDate = getMondayOfCurrentWeek();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activityProvider =
          Provider.of<ActivityProvider>(context, listen: false);
      try {
        activityProvider.setGraphView(currentTab, startDate);
        activityProvider.listenToActivityStatsChanges(userId);
      } catch (e) {
        setState(() {
          isConnectionFailed = true;
        });
      }
    });
  }

  void fetchData() async {
    final activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);

    try {
      await activityProvider.fetchStepsByDateRange(
          userId, currentTab, startDate);
    } catch (e) {
      setState(() {
        isConnectionFailedGraph = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    List<String> xLabels = getXLabels();
    List<int> data = activityProvider.stepsPerDateRange;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: activityProvider.isStatsLoading
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF36B9A5),
                      strokeWidth: 5,
                    ),
                  ))
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
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // weekly goal section
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF73D2C3),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 2,
                                offset: const Offset(0, 1.2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/icons/sidebar_goals.png',
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                    color: const Color(0xFFFFFFFF),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "This week's daily goal",
                                    style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    // today's number of steps
                                    NumberFormat.decimalPattern()
                                        .format(activityProvider.goalSteps),
                                    style: GoogleFonts.manrope(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFFFFFFF),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Transform.translate(
                                    offset: const Offset(0, -2),
                                    child: Text(
                                      // today's number of steps
                                      ' steps',
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 2),

                        // weekly step increase
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            formatTargetChange(activityProvider.targetChange),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF797979),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // today stats section
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today, ${DateFormat('MMM d').format(DateTime.now())}',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF595959),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // circular progress
                                ProgressBar(
                                    progress: activityProvider
                                        .todayActivitySummary["progress"]),

                                // total steps, distance, and duration of the current day
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    todayStatsDetails(
                                        'Total Steps',
                                        NumberFormat.decimalPattern().format(
                                            activityProvider
                                                    .todayActivitySummary[
                                                "totalSteps"])),
                                    todayStatsDetails('Total Distance',
                                        '${(activityProvider.todayActivitySummary["totalDistance"] / 1000).toStringAsFixed(3)} km'),
                                    todayStatsDetails(
                                        'Total Duration',
                                        formatTimeDuration(activityProvider
                                                .todayActivitySummary[
                                            "totalDuration"])),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trend Insights',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF595959),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // tab for weekly, monthly, and yearly
                            Container(
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:
                                    ['Weekly', 'Monthly', 'Yearly'].map((tab) {
                                  final bool isSelected = currentTab == tab;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(
                                          () {
                                            currentTab = tab;
                                            startDate = tab == 'Weekly'
                                                ? getMondayOfCurrentWeek()
                                                : tab == 'Monthly'
                                                    ? DateTime(
                                                        DateTime.now().year,
                                                        DateTime.now().month,
                                                        1)
                                                    : DateTime(
                                                        DateTime.now().year,
                                                        1,
                                                        1);
                                            activityProvider.setGraphView(
                                                currentTab, startDate);
                                            fetchData();
                                          },
                                        );
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 7),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF59D1BE)
                                              : const Color(0xFFFCFCFC),
                                          borderRadius: isSelected
                                              ? const BorderRadius.all(
                                                  Radius.circular(5))
                                              : BorderRadius.horizontal(
                                                  left: tab == 'Weekly'
                                                      ? const Radius.circular(5)
                                                      : Radius.zero,
                                                  right: tab == 'Yearly'
                                                      ? const Radius.circular(5)
                                                      : Radius.zero,
                                                ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isSelected
                                                  ? Colors.black12
                                                  : Colors.transparent,
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          tab,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF717171),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // bar graph
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 2,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 16, bottom: 0),
                            child: Column(
                              children: [
                                // bar graph title
                                Center(
                                  child: Text(
                                    'Total Steps',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF595959),
                                    ),
                                  ),
                                ),

                                // date range controls
                                Transform.translate(
                                  offset: const Offset(0, -8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back_ios,
                                            size: 16),
                                        onPressed: () => updateDateRange(false),
                                      ),
                                      Text(
                                        getDateRangeLabel(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF656565),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Color(0xFF797B86),
                                        ),
                                        onPressed: () => updateDateRange(true),
                                      ),
                                    ],
                                  ),
                                ),

                                activityProvider.isGraphLoading
                                    ? SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.25,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF36B9A5),
                                            strokeWidth: 5,
                                          ),
                                        ))
                                    : isConnectionFailedGraph
                                        ? SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.25,
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
                                                    color:
                                                        const Color(0xFF999999),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    "Connection Failed",
                                                    style: GoogleFonts.poppins(
                                                      textStyle:
                                                          const TextStyle(
                                                        color:
                                                            Color(0xFF999999),
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
                                        // allow horizontal scroll of the bar graph
                                        SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              width: data.length * 50.0,
                                              height: 200,
                                              child:
                                                  buildBarChart(data, xLabels),
                                            ),
                                          ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // stats card
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                buildStatCard(
                                  "assets/icons/footprint.png",
                                  "Total Steps",
                                  // "27,500",
                                  formatNumber(activityProvider
                                      .activityStats["totalSteps"]),
                                ),
                                buildStatCard(
                                  'assets/icons/distance.png',
                                  "Total Distance",
                                  // "100 km",
                                  "${activityProvider.activityStats["totalDistance"].toStringAsFixed(3)} km",
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                buildStatCard(
                                  "assets/icons/clock.png",
                                  "Total Duration",
                                  // "4h 11m",
                                  formatTimeDuration(activityProvider
                                      .activityStats["totalDuration"]),
                                ),
                                buildStatCard(
                                  "assets/icons/person.png",
                                  "Self Efficacy",
                                  // "High",
                                  activityProvider
                                      .activityStats["selfEfficacy"],
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget todayStatsDetails(label, value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF616161),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF616161),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  void updateDateRange(bool isNext) {
    final activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);

    setState(() {
      if (currentTab == 'Weekly') {
        startDate = isNext
            ? startDate.add(const Duration(days: 7))
            : startDate.subtract(const Duration(days: 7));
      } else if (currentTab == 'Monthly') {
        startDate = DateTime(
          startDate.year,
          startDate.month + (isNext ? 1 : -1),
          1,
        );
      } else if (currentTab == 'Yearly') {
        startDate = DateTime(startDate.year + (isNext ? 1 : -1), 1, 1);
      }

      activityProvider.setGraphView(currentTab, startDate);
      fetchData(); // call fetch function when range updates
    });
  }

  String getDateRangeLabel() {
    if (currentTab == 'Weekly') {
      final DateTime endDate = startDate.add(const Duration(days: 6));
      return '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}';
    } else if (currentTab == 'Monthly') {
      return DateFormat('MMMM yyyy').format(startDate);
    } else if (currentTab == 'Yearly') {
      return "Year ${DateFormat('yyyy').format(startDate)}";
    }
    return '';
  }

  List<String> getXLabels() {
    if (currentTab == 'Weekly') {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    } else if (currentTab == 'Monthly') {
      final int daysInMonth =
          DateTime(startDate.year, startDate.month + 1, 0).day;
      return List.generate(daysInMonth, (index) => '${index + 1}');
    } else if (currentTab == 'Yearly') {
      return [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
    }
    return [];
  }

  Widget buildBarChart(List<int> data, List<String> xLabels) {
    double maxValue = data.reduce((a, b) => a > b ? a : b).toDouble();
    return BarChart(
      BarChartData(
        maxY: maxValue + (maxValue * 0.1),
        alignment: BarChartAlignment.start,
        groupsSpace: 10,
        barGroups: List.generate(data.length, (index) {
          return BarChartGroupData(
            x: index,
            barsSpace: 10,
            barRods: [
              BarChartRodData(
                toY: data[index].toDouble(),
                width: 30,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF66CDBD).withOpacity(0.3),
                    const Color(0xFF66CDBD),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                  bottom: Radius.circular(0),
                ),
              ),
            ],
          );
        }),
        // customize tool tip design
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color(0xFF6C7591),
            tooltipRoundedRadius: 4,
            tooltipPadding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
            tooltipMargin: -10,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${data[groupIndex]}',
                const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        // labels
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, context) {
                return Text(
                  formatNumber(value.toInt()),
                  style: GoogleFonts.rubik(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9C9BA2),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, context) {
                return Text(
                  value.toInt() < xLabels.length ? xLabels[value.toInt()] : '',
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9C9BA2),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
              dashArray: [10, 10],
            );
          },
        ),
      ),
    );
  }

  Widget buildStatCard(String icon, String title, String value) {
    final activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 8, right: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              icon,
              width: title == "Total Duration" ? 22 : 27,
              height: title == "Total Duration" ? 22 : 27,
              fit: BoxFit.contain,
              color: const Color(0xFF55AC9F),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF656565),
                    ),
                  ),
                  Text(
                    !activityProvider.isGraphLoading ? value : "",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF656565),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime getMondayOfCurrentWeek() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday; // Monday = 1, Sunday = 7
    return now.subtract(Duration(days: currentWeekday - 1));
  }

  // format numbers with units
  String formatNumber(int number) {
    if (number >= 1000000) {
      // for millions
      return '${(number / 1000000).toStringAsFixed(1).replaceAll(RegExp(r"(\.0)"), '')}m';
    } else if (number >= 1000) {
      // for thousands
      double formattedNumber = number / 1000;
      // if the number has a decimal part, keep one decimal place
      return formattedNumber == formattedNumber.toInt()
          ? '${formattedNumber.toInt()}k'
          : '${formattedNumber.toStringAsFixed(1)}k';
    } else {
      return number.toString();
    }
  }

  String formatTargetChange(double targetChange) {
    double percentage = targetChange * 100;
    String changeType = percentage >= 0 ? "higher" : "lower";
    percentage = percentage.abs(); // absolute value

    if (percentage == 0) return "Same as previous week";

    // format based on whether it has decimals
    String formattedPercentage = percentage % 1 == 0
        ? percentage.toInt().toString() // whole number, means no decimals
        : percentage.toStringAsFixed(2); // display up to 2 decimal places

    return '$formattedPercentage% $changeType than previous week';
  }

  String formatTimeDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '0m';
    }
  }
}
