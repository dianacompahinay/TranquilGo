import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/providers/UserProvider.dart';
import 'package:provider/provider.dart';

class ChangePassword extends StatefulWidget {
  final String email;

  const ChangePassword({Key? key, required this.email}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool isLoading = false;
  bool isButtonClicked = false;

  // text controllers
  TextEditingController currentPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController retypePassController = TextEditingController();

  // visibility
  bool isCurrentPassVisible = false;
  bool isNewPassVisible = false;
  bool isRetypePassVisible = false;

  // for error messages
  String? currentPassError;
  String? newPassError;
  String? retypePassError;

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> changePassword(
      String email, String oldPassword, String newPassword) async {
    final authProvider =
        Provider.of<UserDetailsProvider>(context, listen: false);

    String result =
        await authProvider.updatePassword(email, oldPassword, newPassword);

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showChangePasswordDialog(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 42),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        side: const BorderSide(
          color: Color(0xFF8E8E8E),
          width: 1,
        ),
      ),
      child: DefaultTextStyle(
        style: GoogleFonts.inter(
          textStyle: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: const Text('Change Password'),
      ),
    );
  }

  void showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext dialogContext, Function setDialogState) {
            void validateCurrentPass(String value) {
              setDialogState(() {
                if (value.isEmpty) {
                  currentPassError = 'This is required';
                } else {
                  currentPassError = null;
                }
              });
            }

            void validateNewPass(String value) {
              setDialogState(() {
                if (value.isEmpty) {
                  newPassError = 'This is required';
                } else if (value.contains(' ')) {
                  newPassError = 'New password must not contain spaces';
                } else if (value.length < 6) {
                  newPassError = 'Password must be at least 6 characters';
                } else {
                  newPassError = null;
                }
              });
            }

            void validateRetypePass(String value) {
              setDialogState(() {
                if (value.isEmpty) {
                  retypePassError = 'This is required';
                } else if (value != newPassController.text) {
                  retypePassError = 'New Password do not match';
                } else {
                  retypePassError = null;
                }
              });
            }

            void handleChangePass() async {
              setDialogState(() {
                isButtonClicked = true;
              });

              validateCurrentPass(currentPassController.text);
              validateNewPass(newPassController.text);
              validateRetypePass(retypePassController.text);

              if (currentPassError == null &&
                  newPassError == null &&
                  retypePassError == null) {
                setDialogState(() {
                  isLoading = true;
                });

                // handle it here
                // if old password is entered incorrectly update the error text of currentPassError\

                String result = await changePassword(widget.email,
                    currentPassController.text, newPassController.text);

                if (result == 'success') {
                  showBottomSnackBar(context, 'Password changed successfully.');
                  Navigator.pop(context);
                } else if (result == 'incorrect_old_password') {
                  currentPassError = 'Incorrect old password';
                } else if (result == 'update_failed') {
                  showBottomSnackBar(context,
                      'Failed to update the password. Please try again later.');
                  Navigator.pop(context);
                } else {
                  showBottomSnackBar(context, 'An unknown error occurred.');
                  Navigator.pop(context);
                }

                setDialogState(() {
                  isLoading = false;
                  isCurrentPassVisible = false;
                  isNewPassVisible = false;
                  isRetypePassVisible = false;
                });
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              content: SizedBox(
                width: 400,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            'Change Password',
                            style: GoogleFonts.manrope(
                              textStyle: const TextStyle(
                                color: Color(0xFF4D4D4D),
                                fontSize: 16.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          buildTextField(
                            "Current password",
                            currentPassController,
                            currentPassError,
                            isCurrentPassVisible,
                            validateCurrentPass,
                            visibilityIcon(
                              isCurrentPassVisible,
                              () {
                                setDialogState(() {
                                  isCurrentPassVisible = !isCurrentPassVisible;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          buildTextField(
                            "New password",
                            newPassController,
                            newPassError,
                            isNewPassVisible,
                            validateNewPass,
                            visibilityIcon(
                              isNewPassVisible,
                              () {
                                setDialogState(() {
                                  isNewPassVisible = !isNewPassVisible;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          buildTextField(
                            "Retype password",
                            retypePassController,
                            retypePassError,
                            isRetypePassVisible,
                            validateRetypePass,
                            visibilityIcon(
                              isRetypePassVisible,
                              () {
                                setDialogState(() {
                                  isRetypePassVisible = !isRetypePassVisible;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    handleChangePass();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF55AC9F),
                              minimumSize: const Size(double.infinity, 38),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 4,
                                    ),
                                  )
                                : Text(
                                    'Save',
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    // close button
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(
                          Icons.close,
                          size: 22,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // Reset the state when the dialog is dismissed by any means
      resetState();
    });
  }

  void resetState() {
    // dispose text controllers when widget is removed
    currentPassController.clear();
    newPassController.clear();
    retypePassController.clear();
    currentPassError = null;
    newPassError = null;
    retypePassError = null;
    isButtonClicked = false;
  }

  Widget buildTextField(
    String labelText,
    TextEditingController controller,
    String? errorText,
    bool hide,
    Function(String) validator,
    Widget toggleButton,
  ) {
    return TextField(
      controller: controller,
      onChanged: (value) {
        validator(value);
      },
      obscureText: !hide,
      decoration: InputDecoration(
        errorText: isButtonClicked ? errorText : null,
        label: Text(
          labelText,
          style: GoogleFonts.inter(
            textStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: errorText != null && isButtonClicked
                  ? const Color(0xFFC14040)
                  : const Color(0xFF656263),
            ),
          ),
        ),
        suffixIcon: toggleButton,
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
    );
  }

  IconButton visibilityIcon(bool isVisible, VoidCallback onPressed) {
    return IconButton(
      iconSize: 18,
      icon: Icon(
        isVisible ? Icons.visibility : Icons.visibility_off,
        color: const Color(0xFFBFBFBF),
      ),
      onPressed: onPressed,
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
