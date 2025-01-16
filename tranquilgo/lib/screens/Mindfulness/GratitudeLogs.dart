import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GratitudeLogs extends StatelessWidget {
  static const List<Map<String, String>> logs = [
    {'date': '', 'content': ''}, // filler
    {
      'date': 'Aug 12, 2024',
      'content':
          'Appreciating the beauty of nature and the peacefulness it brings'
    },
    {
      'date': 'Aug 9, 2024',
      'content': 'Thankful for the fresh air and the time to clear my mind.'
    },
    {
      'date': 'Aug 8, 2024',
      'content':
          'Grateful for my health and the things I often take for granted.'
    },
    {
      'date': 'Aug 5, 2024',
      'content':
          'Thankful for the opportunities to grow and become a better version of myself.'
    },
    {
      'date': 'July 30, 2024',
      'content': 'Thankful for the little moments of joy that brighten my day.'
    },
    {
      'date': 'July 25, 2024',
      'content':
          'Grateful for the time spent away from screens and in the present moment.'
    },
    {
      'date': 'July 22, 2024',
      'content':
          'Appreciating the beauty of nature and the peacefulness it brings.'
    },
    {
      'date': 'July 19, 2024',
      'content':
          'Grateful for the support of friends and family during tough times.'
    },
  ];

  const GratitudeLogs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFFFAFAFA),
                leading: Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
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
                  [
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Gratitude Logs',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: Color(0xFF606060),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          MasonryGridView.count(
                            padding: const EdgeInsets.only(top: 10),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16.0,
                            crossAxisSpacing: 16.0,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: logs.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 2, vertical: 2),
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(7),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.6),
                                        spreadRadius: 0,
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Positivity',
                                      style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF696969),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          titlePadding:
                                              const EdgeInsets.fromLTRB(
                                                  20, 10, 10, 8),
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  20, 0, 26, 26),
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                logs[index]['date']!,
                                                style: GoogleFonts.poppins(
                                                  textStyle: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.close,
                                                    color: Colors.grey),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                          content: SizedBox(
                                            height: 170,
                                            child: SingleChildScrollView(
                                              child: Text(
                                                logs[index]['content']!,
                                                style: GoogleFonts.poppins(
                                                  textStyle: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: buildLogCard(logs[index]),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: SizedBox(
              height: 38,
              child: FloatingActionButton.extended(
                onPressed: () => {Navigator.pushNamed(context, '/addlog')},
                label: Text(
                  'Add log',
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
    );
  }

  Widget buildLogCard(Map<String, String> log) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(14.0),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            log['date']!,
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              log['content']!,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
