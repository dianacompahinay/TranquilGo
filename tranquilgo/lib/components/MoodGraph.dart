import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraphView extends StatefulWidget {
  const GraphView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GraphViewState createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            Text(
              'August 2024',
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
                  // pie chart
                  Expanded(
                    child: SfCircularChart(
                      series: <CircularSeries>[
                        PieSeries<ChartData, String>(
                          dataSource: [
                            ChartData('Happy', 25, const Color(0xFF53F2CC)),
                            ChartData('Calm', 20, const Color(0xFF67E1EA)),
                            ChartData('Neutral', 30, const Color(0xFFC3D1D0)),
                            ChartData('Sad', 15, const Color(0xFFCEBFE7)),
                            ChartData('Stressed', 10, const Color(0xFFA5AFF1)),
                          ],
                          xValueMapper: (ChartData data, _) => data.label,
                          yValueMapper: (ChartData data, _) => data.value,
                          pointColorMapper: (ChartData data, _) => data.color,
                          radius: '88%',
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
                        _buildLegendItem('Happy', const Color(0xFF53F2CC)),
                        _buildLegendItem('Calm', const Color(0xFF67E1EA)),
                        _buildLegendItem('Neutral', const Color(0xFFC3D1D0)),
                        _buildLegendItem('Sad', const Color(0xFFCEBFE7)),
                        _buildLegendItem('Stressed', const Color(0xFFA5AFF1)),
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
  Widget _buildLegendItem(String label, Color color) {
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
  final double value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}
