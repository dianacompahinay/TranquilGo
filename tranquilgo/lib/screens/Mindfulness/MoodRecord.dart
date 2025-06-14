import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/MoodCalendar.dart';
import '../../components/MoodGraph.dart';

class MoodRecord extends StatefulWidget {
  const MoodRecord({super.key});

  @override
  _MoodRecordState createState() => _MoodRecordState();
}

class _MoodRecordState extends State<MoodRecord> {
  int currentIndex = 0; // track which tab is selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
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
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Transform.translate(
                offset: const Offset(0, -4),
                child: Text(
                  'Mood Tracking',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      color: Color(0xFF606060),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // tab row for graph and calendar option
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      // height: 30,
                      width: 120,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            currentIndex = 0; // select graph tab
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: currentIndex == 0
                                ? const Color(0xFF59D1BE)
                                : const Color(0xFFFAFAFA),
                            borderRadius: currentIndex == 0
                                ? BorderRadius.circular(5)
                                : const BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    bottomLeft: Radius.circular(5),
                                  ),
                            boxShadow: [
                              currentIndex == 0
                                  ? const BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 2,
                                      offset: Offset(1, 2),
                                    )
                                  : const BoxShadow(
                                      color: Colors.white,
                                    ),
                            ],
                          ),
                          child: Text(
                            'Graph',
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                color: currentIndex == 0
                                    ? Colors.white
                                    : const Color(0xFF717171),
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5),
                        bottomRight: Radius.circular(5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 120,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            currentIndex = 1; // select calendar tab
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: currentIndex == 1
                                ? const Color(0xFF59D1BE)
                                : const Color(0xFFFAFAFA),
                            borderRadius: currentIndex == 1
                                ? BorderRadius.circular(5)
                                : const BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    bottomRight: Radius.circular(5),
                                  ),
                            boxShadow: [
                              currentIndex == 1
                                  ? const BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 2,
                                      offset: Offset(1, 2),
                                    )
                                  : const BoxShadow(
                                      color: Colors.white,
                                    ),
                            ],
                          ),
                          child: Text(
                            'Calendar',
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                color: currentIndex == 1
                                    ? Colors.white
                                    : const Color(0xFF717171),
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // content Area
              SizedBox(
                child: currentIndex == 0
                    ? const GraphView() // display Graph
                    : const CalendarView(), // display Calendar
              ),
            ],
          ),
        ),
      ),
    );
  }
}
