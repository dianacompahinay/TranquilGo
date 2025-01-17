import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FirstGoal extends StatefulWidget {
  const FirstGoal({super.key});

  @override
  _FirstGoalState createState() => _FirstGoalState();
}

class _FirstGoalState extends State<FirstGoal> {
  int selectedIndex = -1; // initialize with -1 (no selection)
  String inputSteps = ''; // store the input steps for the last option

  List<String> options = [
    '2000 steps: 20-30 mins',
    '3000 steps: 30-45 mins',
    '4000 steps: 45-60 mins',
    '6000 steps: 60-90 mins',
    '8000 steps: 80-120 mins',
    '10000 steps: 100-150 mins (recommended)',
    'Set own number of steps',
  ];

  @override
  Widget build(BuildContext context) {
    final TextEditingController numberController = TextEditingController();
    String? inputError;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set your daily walking goal for this week. Start with a duration that feels comfortable for you.',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'It\'s okay to start small. Consistency is key to building a new habit.',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),

            // Options List
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index; // update selected index
                      });
                      if (index == options.length - 1) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (BuildContext dialogContext,
                                  Function setDialogState) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Colors.white,
                                  title: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Set own number of steps',
                                          style: GoogleFonts.poppins(
                                            textStyle: const TextStyle(
                                              color: Color(0xFF555555),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Min of 1000',
                                          style: GoogleFonts.poppins(
                                            textStyle: const TextStyle(
                                              color: Color(0xFF979797),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        const Divider(
                                          color: Color(0xFFC3C3C3),
                                          thickness: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  content: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 45, right: 45, top: 10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: numberController,
                                          onChanged: (value) {
                                            setDialogState(() {
                                              inputError = value.isEmpty &&
                                                      int.tryParse(value) ==
                                                          null &&
                                                      int.parse(value) < 1000
                                                  ? 'Invalid input, min of 1000'
                                                  : null;
                                            });
                                          },
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.start,
                                          decoration: InputDecoration(
                                            errorText: inputError,
                                            alignLabelWithHint: true,
                                            hintText: 'Enter a number',
                                            hintStyle: GoogleFonts.inter(
                                              textStyle: const TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF919191),
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: 12,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF8E8E8E),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF55AC9F),
                                                width: 2.0,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFC14040),
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFC14040),
                                                width: 2.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              numberController.clear();
                                              Navigator.of(context)
                                                  .pop(); // close dialog
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              minimumSize: const Size(60, 38),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
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
                                              final input =
                                                  numberController.text;
                                              if (input.isNotEmpty &&
                                                  int.tryParse(input) != null &&
                                                  int.parse(input) >= 1000) {
                                                setState(() {
                                                  inputSteps =
                                                      '$input steps'; // save the input
                                                  options[options.length - 1] =
                                                      inputSteps; // update the last option
                                                });

                                                Navigator.of(context)
                                                    .pop(); // close the dialog
                                              } else {
                                                setDialogState(() {
                                                  inputError =
                                                      'Invalid input, min of 1000';
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF55AC9F),
                                              minimumSize: const Size(60, 38),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            child: Text(
                                              'Submit',
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
                          },
                        );
                      }
                      // else {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(
                      //       content: Text('You selected: ${options[index]}'),
                      //     ),
                      //   );
                      // }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 7),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: selectedIndex == index
                              ? const Color(0xFF55AC9F)
                              : const Color(0xFF888888),
                          width: selectedIndex == index ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        options[index],
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: selectedIndex == index
                                ? const Color(0xFF55AC9F)
                                : const Color(0xFF4E4E4E),
                            fontSize: 14,
                            fontWeight: selectedIndex == index
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // continue Button
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: ElevatedButton(
                onPressed: () {
                  // not allow to continue if there's no selection or input at the last selection is empty
                  if (selectedIndex == -1 ||
                      (selectedIndex == options.length - 1 &&
                          inputSteps.isEmpty)) {
                    // show an alert to indicate the error
                    showTopSnackBar(context);
                  } else {
                    // proceed to the next screen
                    Navigator.pushNamed(context, '/getstarted');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF55AC9F),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showTopSnackBar(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 8,
        right: 8,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF2BB1C0),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              "Please select an option or enter a valid input.",
              style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    // insert and auto remove the snackbar after 3 seconds
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
