import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FirstGoal extends StatefulWidget {
  const FirstGoal({super.key});

  @override
  // ignore: library_private_types_in_public_api
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 170, bottom: 100),
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
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              backgroundColor: Colors.white,
                              title: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    left: 45.0, right: 45.0, top: 10.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: numberController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        hintText: 'Enter a number',
                                        hintStyle: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF919191),
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal: 18.0,
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
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                Container(
                                  // color: Colors.white,
                                  padding: const EdgeInsets.all(2.0),
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
                                          minimumSize: const Size(120, 38),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              side: const BorderSide(
                                                color: Color(0xFFB1B1B1),
                                                width: 1,
                                              )),
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
                                          final input = numberController.text;
                                          if (input.isNotEmpty &&
                                              int.tryParse(input) != null &&
                                              int.parse(input) >= 1000) {
                                            setState(() {
                                              inputSteps =
                                                  '$input steps'; // save the input
                                              options[options.length - 1] =
                                                  inputSteps; // update the last option
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'You entered: $input steps'),
                                              ),
                                            );
                                            Navigator.of(context)
                                                .pop(); // close the dialog
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please enter a valid number.'),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF55AC9F),
                                          minimumSize: const Size(120, 38),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
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
                      } else {
                        final selectedOption = options[index];
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You selected: $selectedOption'),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 7),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          // color: const Color(0xFF888888),
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
            // white overlay to prevent text overlap
            Container(
              height: 210,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),
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
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(25.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/getstarted');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF55AC9F),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
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
            ),
          ],
        ),
      ),
    );
  }
}
