import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/ProgressBar.dart';
import 'package:intl/intl.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int weeklyDailyGoal = 10000;
  int todaySteps = 7500;
  double todayDistance = 5.7;
  String todayDuration = '1h 9m';
  double progress = 0.75;

  String currentTab = 'Weekly';
  DateTime startDate = DateTime(2025, 1, 6);

  // dummy data
  final List<int> weeklyData = [15000, 12000, 9000, 10000, 13000, 11000, 8000];
  final List<int> monthlyData =
      List.generate(31, (index) => 8000 + index * 100);
  final List<int> yearlyData =
      List.generate(12, (index) => 30000 + index * 2000);

  @override
  Widget build(BuildContext context) {
    final List<String> xLabels = getXLabels();
    final List<int> data = getData();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // weekly goal section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFCFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFF9F9F9),
                    width: 1,
                  ),
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
                          color: const Color(0xFF616161),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "This week's daily goal",
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF797979),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          // today's number of steps
                          NumberFormat.decimalPattern().format(weeklyDailyGoal),
                          style: GoogleFonts.manrope(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF666666),
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
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF8C8C8C),
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
                  '5% higher than previous week',
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
                      ProgressBar(progress: progress),

                      // total steps, distance, and duration of the current day
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          todayStatsDetails('Total Steps',
                              NumberFormat.decimalPattern().format(todaySteps)),
                          todayStatsDetails(
                              'Total Distance', '$todayDistance km'),
                          todayStatsDetails('Total Duration', todayDuration),
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
                      borderRadius: BorderRadius.all(Radius.circular(5)),
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
                      children: ['Weekly', 'Monthly', 'Yearly'].map((tab) {
                        final bool isSelected = currentTab == tab;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                currentTab = tab;
                                startDate = tab == 'Weekly'
                                    ? DateTime(2025, 1, 6)
                                    : DateTime(2025, 1, 1);
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF59D1BE)
                                    : const Color(0xFFFCFCFC),
                                borderRadius: isSelected
                                    ? const BorderRadius.all(Radius.circular(5))
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
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, size: 16),
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

                      // allow horizontal scroll of the bar graph
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          padding: const EdgeInsets.only(top: 5),
                          width: data.length * 50.0,
                          height: 200,
                          child: buildBarChart(data, xLabels),
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
                        "27,500",
                      ),
                      buildStatCard(
                        'assets/icons/distance.png',
                        "Total Distance",
                        "100 km",
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
                        "4h 11m",
                      ),
                      buildStatCard(
                        "assets/icons/person.png",
                        "Self Efficacy",
                        "High",
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

  List<int> getData() {
    if (currentTab == 'Weekly') {
      return weeklyData;
    } else if (currentTab == 'Monthly') {
      return monthlyData;
    } else if (currentTab == 'Yearly') {
      return yearlyData;
    }
    return [];
  }

  Widget buildStatsColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 16)),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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
                    value,
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
}
