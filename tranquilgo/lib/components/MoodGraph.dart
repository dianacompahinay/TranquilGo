import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/providers/MindfulnessProvider.dart';

class GraphView extends StatefulWidget {
  const GraphView({super.key});

  @override
  _GraphViewState createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  MindfulnessProvider mindfulnessProvider = MindfulnessProvider();
  List<ChartData> chartData = [];
  TooltipBehavior? tooltipBehavior;

  DateTime now = DateTime.now();

  bool isConnectionFailed = false;
  bool isLoading = false;
  bool isEmpty = false;

  @override
  void initState() {
    super.initState();
    tooltipBehavior = TooltipBehavior(enable: true);
    loadMoods();
  }

  void loadMoods() async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<DateTime, int> moodData = await mindfulnessProvider
          .fetchPerMonthMoodRecords(userId, now.month, now.year);

      if (moodData.isEmpty) {
        setState(() {
          isEmpty = true;
        });
      }

      Map<int, int> moodCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      // count moods for the current month
      moodData.forEach((date, moodValue) {
        moodCounts[moodValue] = (moodCounts[moodValue] ?? 0) + 1;
      });

      setState(() {
        chartData = [
          ChartData('Happy', moodCounts[5]!, const Color(0xFF53F2CC)),
          ChartData('Calm', moodCounts[4]!, const Color(0xFF67E1EA)),
          ChartData('Neutral', moodCounts[3]!, const Color(0xFFC3D1D0)),
          ChartData('Sad', moodCounts[2]!, const Color(0xFFCEBFE7)),
          ChartData('Stressed', moodCounts[1]!, const Color(0xFFA5AFF1)),
        ];
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
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
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
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('MMMM yyyy').format(now),
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Color(0xFF696969),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 250,
                        child: Row(
                          children: [
                            isEmpty
                                ? Expanded(
                                    child: Container(
                                      width: 190,
                                      height: 190,
                                      // padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                :
                                // pie chart
                                Expanded(
                                    child: SfCircularChart(
                                      tooltipBehavior: tooltipBehavior,
                                      series: <CircularSeries>[
                                        DoughnutSeries<ChartData, String>(
                                          dataSource: chartData,
                                          xValueMapper: (ChartData data, _) =>
                                              data.label,
                                          yValueMapper: (ChartData data, _) =>
                                              data.value,
                                          pointColorMapper:
                                              (ChartData data, _) => data.color,
                                          radius: '88%',
                                          innerRadius: '55%',
                                          enableTooltip: true,
                                          explode: true,
                                          selectionBehavior:
                                              SelectionBehavior(enable: true),
                                        )
                                      ],
                                    ),
                                  ),
                            // legend
                            Transform.translate(
                              offset: const Offset(0, -28),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildLegendItem(
                                      'Happy', const Color(0xFF53F2CC)),
                                  buildLegendItem(
                                      'Calm', const Color(0xFF67E1EA)),
                                  buildLegendItem(
                                      'Neutral', const Color(0xFFC3D1D0)),
                                  buildLegendItem(
                                      'Sad', const Color(0xFFCEBFE7)),
                                  buildLegendItem(
                                      'Stressed', const Color(0xFFA5AFF1)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/moodhistory');
                          },
                          child: const Text(
                            'View history',
                            style: TextStyle(color: Colors.teal),
                          ),
                        ),
                      )
                    ],
                  ),
      ),
    );
  }

  // for legend items
  Widget buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
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
