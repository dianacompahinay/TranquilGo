import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InviteUser extends StatefulWidget {
  final String userId;
  final String userName;

  const InviteUser({Key? key, required this.userId, required this.userName})
      : super(key: key);

  @override
  State<InviteUser> createState() => _InviteUserState();
}

class _InviteUserState extends State<InviteUser> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // for error messages
  String? dateError;
  String? timeError;
  String? locationError;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // show dialog when tapped
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext dialogContext, Function setDialogState) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  content: SizedBox(
                    width: 400,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Row(
                            // modal title
                            children: [
                              const Icon(
                                Icons.directions_walk_rounded,
                                size: 22,
                                color: Color(0xFF41B8A7),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Invite to walk',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: Color(0xFF323232),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            margin: const EdgeInsets.only(left: 5),
                            child: Text(
                              // user to sent
                              'To: ${widget.userName}',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: Color(0xFF555555),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                // date input field
                                child: dateTimeInputField(
                                    'Date',
                                    dateController,
                                    'yyyy-mm-dd',
                                    () => selectDate(
                                        dialogContext, setDialogState),
                                    dateError),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                // time input field
                                child: dateTimeInputField(
                                    'Time',
                                    timeController,
                                    '--:--:--',
                                    () => selectTime(
                                        dialogContext, setDialogState),
                                    timeError),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // location input field
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: Color(0xFF555555),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              TextField(
                                controller: locationController,
                                onChanged: (value) {
                                  // remove error text when the user types
                                  setDialogState(() {
                                    locationError = value.isEmpty
                                        ? 'Location is required'
                                        : null;
                                  });
                                },
                                decoration: InputDecoration(
                                  errorText: locationError,
                                  hintText: 'Meeting place',
                                  hintStyle: GoogleFonts.inter(
                                    textStyle: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF919191),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF8E8E8E),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
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
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFC14040),
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // optional message input field
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Message',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: Color(0xFF555555),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              TextField(
                                maxLines: 3,
                                controller: messageController,
                                decoration: InputDecoration(
                                  hintText: '(Optional)',
                                  hintStyle: GoogleFonts.inter(
                                    textStyle: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF919191),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(10),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF8E8E8E),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF55AC9F),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  resetFields(); // clear fields and errors
                                  Navigator.of(dialogContext)
                                      .pop(); // close modal
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  minimumSize: const Size(120, 34),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: const BorderSide(
                                      color: Color(0xFFB1B1B1),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Discard',
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
                                onPressed: () =>
                                    validateAndSend(setDialogState),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF55AC9F),
                                  minimumSize: const Size(120, 34),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Text(
                                  'Send',
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
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ).then((_) => resetFields()); // reset fields when dialog closes
      },
      child: const SizedBox(
        width: 30,
        height: 22,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              child: Icon(
                Icons.directions_walk_rounded,
                size: 22,
                color: Color(0xFF41B8A7),
              ),
            ),
            Positioned(
              right: 0,
              child: Icon(
                Icons.add,
                size: 14,
                color: Color(0xFF41B8A7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // show validation text when required input fields are empty
  void validateAndSend(Function setDialogState) {
    setDialogState(() {
      dateError = dateController.text.isEmpty ? 'Date is required' : null;
      timeError = timeController.text.isEmpty ? 'Time is required' : null;
      locationError =
          locationController.text.isEmpty ? 'Location is required' : null;
    });

    if (dateError == null && timeError == null && locationError == null) {
      // handle successful submission
      Navigator.of(context).pop();
    }
  }

  // clear input fields
  void resetFields() {
    dateController.clear();
    timeController.clear();
    locationController.clear();
    messageController.clear();
    dateError = null;
    timeError = null;
    locationError = null;
  }

  Widget dateTimeInputField(String label, TextEditingController controller,
      String hintText, Function onTap, String? error) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: () => onTap(), // trigger the date picker immediately
          child: AbsorbPointer(
            // prevents the textfield from receiving input
            child: TextField(
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                errorText: error,
                hintText: hintText,
                hintStyle: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF919191),
                  ),
                ),
                contentPadding: const EdgeInsets.only(left: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(
                    color: Color(0xFF8E8E8E),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
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
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFC14040),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<void> selectDate(BuildContext context, Function setDialogState) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendar,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            dialogBackgroundColor: Colors.white,
            primaryColor: const Color(0xFF55AC9F),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF55AC9F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            // color for the action buttons (Cancel/OK)
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF55AC9F),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setDialogState(() {
        dateController.text = "${picked.year}-${picked.month}-${picked.day}";
        dateError = null; // clear date error after selection
      });
    }
  }

  Future<void> selectTime(BuildContext context, Function setDialogState) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            // color for cancel and ok actioon button
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF55AC9F),
              ),
            ),
            // style customization
            dialogBackgroundColor: Colors.white,
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextStyle: const TextStyle(
                color: Color(0xFF4C4B4B),
                fontSize: 24,
              ),
              hourMinuteColor: const Color(0xFFFFFFFF),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                  color: Color(0xFFB1B1B1),
                  width: 1,
                ),
              ),
              dayPeriodTextStyle: const TextStyle(
                color: Color(0xFF4C4B4B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              dayPeriodColor: const Color(0xFF73D2C3),
              dialHandColor: const Color(0xFF55AC9F),
              dialBackgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              inputDecorationTheme: InputDecorationTheme(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFB1B1B1),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFF55AC9F),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setDialogState(() {
        timeController.text = picked.format(context);
        timeError = null;
      });
    }
  }
}
