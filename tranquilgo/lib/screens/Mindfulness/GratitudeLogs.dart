import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/providers/MindfulnessProvider.dart';

class GratitudeLogs extends StatefulWidget {
  const GratitudeLogs({super.key});

  @override
  _GratitudeLogsState createState() => _GratitudeLogsState();
}

class _GratitudeLogsState extends State<GratitudeLogs> {
  MindfulnessProvider mindfulnessProvider = MindfulnessProvider();
  List<Map<String, dynamic>> logs = [];
  bool fetchLoading = false;
  bool deleteLoading = false;
  bool isConnectionFailed = false;
  bool deleteMode = false;

  @override
  void initState() {
    super.initState();
    initializeLogs();
  }

  Future<void> initializeLogs() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    setState(() {
      fetchLoading = true;
      logs = [];
    });

    try {
      int totalLogs = await mindfulnessProvider.getUserLogsCount(userId) ?? 0;
      int fetchedCount = 0;

      // fetch the first batch of logs
      List<Map<String, dynamic>> initialLogs =
          await mindfulnessProvider.fetchLogs(userId, null);

      if (initialLogs.isNotEmpty) {
        fetchedCount += initialLogs.length;
        setState(() {
          logs = [
            // {'logId': '', 'date': '', 'content': ''},
            ...initialLogs
          ];
        });
      }

      if (fetchedCount == totalLogs) {
        setState(() {
          fetchLoading = false;
        });
      }

      // continue fetching remaining logs in batches
      while (fetchedCount < totalLogs) {
        List<Map<String, dynamic>> fetchedLogs =
            await mindfulnessProvider.fetchLogs(userId, logs.last["logId"]);

        if (fetchedLogs.isNotEmpty) {
          fetchedCount += fetchedLogs.length;
          setState(() {
            logs.addAll(fetchedLogs);
          });
        }

        if (fetchedCount == totalLogs) {
          setState(() {
            fetchLoading = false;
          });
          break;
        }
      }
    } catch (e) {
      setState(() {
        fetchLoading = false;
        isConnectionFailed = true;
      });
    }
  }

  void deleteLog(BuildContext context, String logId, int index) async {
    setState(() {
      deleteLoading = true;
    });

    final userId = FirebaseAuth.instance.currentUser!.uid;

    String result = await mindfulnessProvider.deleteLog(userId, logId);

    if (result == "success") {
      setState(() {
        logs.removeAt(index);
      });
      showBottomSnackBar(context, "Log has been deleted successfully.");
    } else {
      showBottomSnackBar(context, result);
    }

    setState(() {
      deleteLoading = false;
    });

    Navigator.of(context).pop(); // close dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFFFFFFFF),
                toolbarHeight: 60,
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
                      decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -4),
                            child: Center(
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
                          ),
                          isConnectionFailed
                              ? SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
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
                              : logs.isEmpty && !fetchLoading
                                  ? SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.75,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                  : MasonryGridView.count(
                                      padding: const EdgeInsets.only(top: 10),
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 16.0,
                                      crossAxisSpacing: 16.0,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: logs.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        // if (index == 0) {
                                        //   return Container(
                                        //     margin: const EdgeInsets.symmetric(
                                        //         horizontal: 2, vertical: 2),
                                        //     height: 70,
                                        //     decoration: BoxDecoration(
                                        //       color: Colors.white,
                                        //       borderRadius:
                                        //           BorderRadius.circular(7),
                                        //       boxShadow: [
                                        //         BoxShadow(
                                        //           color: Colors.grey
                                        //               .withOpacity(0.6),
                                        //           spreadRadius: 0,
                                        //           blurRadius: 2,
                                        //           offset: const Offset(0, 1),
                                        //         ),
                                        //       ],
                                        //     ),
                                        //     child: Center(
                                        //       child: Text(
                                        //         'Positivity',
                                        //         style: GoogleFonts.poppins(
                                        //           textStyle: const TextStyle(
                                        //             fontSize: 20,
                                        //             fontWeight: FontWeight.bold,
                                        //             color: Color(0xFF696969),
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   );
                                        // } else {
                                        return GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  titlePadding:
                                                      const EdgeInsets.fromLTRB(
                                                          20, 10, 10, 8),
                                                  contentPadding:
                                                      const EdgeInsets.fromLTRB(
                                                          20, 0, 26, 26),
                                                  title: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        logs[index]['date']!,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          textStyle:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.close,
                                                            color: Colors.grey),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  content: SizedBox(
                                                    height: 170,
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Text(
                                                        logs[index]['content']!,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          textStyle:
                                                              const TextStyle(
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
                                          child:
                                              buildLogCard(logs[index], index),
                                        );
                                      }
                                      // },
                                      ),
                          fetchLoading
                              ? SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF36B9A5),
                                      strokeWidth: 5,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // add log
          Positioned(
            bottom: 15,
            right: 15,
            child: SizedBox(
              height: 38,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  String? result =
                      await Navigator.pushNamed(context, '/addlog');

                  if (result != null && result.isNotEmpty) {
                    initializeLogs();
                  }
                },
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

          // delete logs
          Positioned(
            bottom: 15,
            left: 16,
            child: SizedBox(
              child: GestureDetector(
                onTap: () => {
                  setState(() {
                    deleteMode = !deleteMode;
                  })
                },
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.delete_forever,
                    color: deleteMode
                        ? const Color(0xFFE45151)
                        : const Color(0xFF8F8F8F),
                    size: 25,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLogCard(Map<String, dynamic> log, int index) {
    return Stack(
      children: [
        Container(
          height: 160,
          width: double.infinity,
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
        ),
        deleteMode
            ? Positioned(
                top: 5,
                right: 0,
                child: IconButton(
                  // handle delete
                  onPressed: () => confirmationToDelete(
                      context, log['logId']!, log['date']!, index),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFF8F8F8F),
                    size: 22,
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  void confirmationToDelete(
      BuildContext context, String logId, String date, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
          content: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Are you sure you want to permanently delete the log from $date?",
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  color: Color(0xFF464646),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            deleteLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF36B9A5),
                      strokeWidth: 5,
                    ),
                  )
                : Container(
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // close dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: const Size(120, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: const BorderSide(
                                color: Color(0xFFB1B1B1),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Color(0xFF4C4B4B),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            deleteLog(context, logId, index);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF55AC9F),
                            minimumSize: const Size(120, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            'Confirm',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        );
      },
    );
  }

  void showBottomSnackBar(BuildContext context, String text) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 20,
        left: 16,
        right: 16,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF2BB1C0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              text,
              style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
