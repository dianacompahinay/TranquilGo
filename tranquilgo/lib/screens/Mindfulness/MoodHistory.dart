import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MoodTrackingHistory extends StatelessWidget {
  const MoodTrackingHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            // list of pie graphs
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 95, bottom: 40),
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Year 2024',
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            color: Color(0xFF4A4949),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 24.0,
                        runSpacing: 35.0,
                        children: List.generate(5, (index) {
                          final months = [
                            "March",
                            "April",
                            "June",
                            "July",
                            "August"
                          ];
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width - 80) / 2,
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 12, bottom: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9F9),
                                borderRadius: BorderRadius.circular(20),
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
                                    months[index],
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
                                        PieSeries<ChartData, String>(
                                          dataSource: [
                                            ChartData('Happy', 25,
                                                const Color(0xFF53F2CC)),
                                            ChartData('Calm', 20,
                                                const Color(0xFF67E1EA)),
                                            ChartData('Neutral', 30,
                                                const Color(0xFFC3D1D0)),
                                            ChartData('Sad', 15,
                                                const Color(0xFFCEBFE7)),
                                            ChartData('Stressed', 10,
                                                const Color(0xFFA5AFF1)),
                                          ],
                                          xValueMapper: (ChartData data, _) =>
                                              data.label,
                                          yValueMapper: (ChartData data, _) =>
                                              data.value,
                                          pointColorMapper:
                                              (ChartData data, _) => data.color,
                                          radius: '100%',
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),

                      // copy
                      const SizedBox(height: 45),
                      Text(
                        'Year 2023',
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            color: Color(0xFF4A4949),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 24.0,
                        runSpacing: 35.0,
                        children: List.generate(2, (index) {
                          final months = ["November", "December"];
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width - 80) / 2,
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 12, bottom: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9F9),
                                borderRadius: BorderRadius.circular(20),
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
                                    months[index],
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
                                        PieSeries<ChartData, String>(
                                          dataSource: [
                                            ChartData('Happy', 30,
                                                const Color(0xFF53F2CC)),
                                            ChartData('Calm', 25,
                                                const Color(0xFF67E1EA)),
                                            ChartData('Neutral', 10,
                                                const Color(0xFFC3D1D0)),
                                            ChartData('Sad', 5,
                                                const Color(0xFFCEBFE7)),
                                            ChartData('Stressed', 2,
                                                const Color(0xFFA5AFF1)),
                                          ],
                                          xValueMapper: (ChartData data, _) =>
                                              data.label,
                                          yValueMapper: (ChartData data, _) =>
                                              data.value,
                                          pointColorMapper:
                                              (ChartData data, _) => data.color,
                                          radius: '100%',
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // title
            Container(
              height: 110,
              padding: const EdgeInsets.only(top: 45),
              decoration: const BoxDecoration(color: Colors.white),
              child: Center(
                child: Text(
                  "Monthly Mood Tracking",
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      color: Color(0xFF110000),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            // back button
            Positioned(
              top: 60.0,
              left: 25.0,
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
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}
