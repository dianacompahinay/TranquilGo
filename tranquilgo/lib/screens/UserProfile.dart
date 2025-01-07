import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Auth/LandingPage.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  bool isEditable = false;

  @override
  Widget build(BuildContext context) {
    final TextEditingController username =
        TextEditingController(text: "username123");
    final TextEditingController email =
        TextEditingController(text: "username123@gmail.com");
    final TextEditingController password =
        TextEditingController(text: "********");

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 46, right: 46, top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title
                      Center(
                        child: Text(
                          "User Profile",
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                                color: Color(0xFF454444),
                                fontWeight: FontWeight.w700,
                                fontSize: 20),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // profile icon
                      Center(
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFACACAC),
                              width: 1,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 95,
                              color: Color(0xFF73C2C4),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // username
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          "Username",
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                                color: Color(0xFF616161),
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                          ),
                        ),
                      ),
                      TextField(
                        controller: username,
                        enabled: isEditable,
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: isEditable
                                ? const Color(0xFF000000)
                                : const Color(0xFF616161),
                          ),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter username',
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 18.0,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Color(0xFF919191),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Color(0xFF55AC9F),
                              width: 2.0,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFDBDBDB),
                            ),
                          ),
                        ),
                      ),

                      // email
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 5),
                        child: Text(
                          "Email",
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                                color: Color(0xFF616161),
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                          ),
                        ),
                      ),
                      TextField(
                        controller: email,
                        enabled: isEditable,
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: isEditable
                                ? const Color(0xFF000000)
                                : const Color(0xFF616161),
                          ),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter email',
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 18.0,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Color(0xFF919191),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Color(0xFF55AC9F),
                              width: 2.0,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFDBDBDB),
                            ),
                          ),
                        ),
                      ),

                      // password
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 5),
                        child: Text(
                          "Password",
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                                color: Color(0xFF616161),
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                          ),
                        ),
                      ),
                      TextField(
                        controller: password,
                        enabled: isEditable,
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: isEditable
                                ? const Color(0xFF000000)
                                : const Color(0xFF616161),
                          ),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter password',
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 18.0,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Color(0xFF919191),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Color(0xFF55AC9F),
                              width: 2.0,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFDBDBDB),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // edit profile button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isEditable = !isEditable;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF55AC9F),
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: DefaultTextStyle(
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Text(
                              isEditable ? 'Save Changes' : 'Edit Profile'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // log out button
                      Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LandingPage()),
                              (Route<dynamic> route) =>
                                  false, // removes all previous routes
                            );
                          },
                          child: DefaultTextStyle(
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                color: Color(0xFF494949),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: const Text('Log out'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // back button
            Positioned(
              top: 60,
              left: 20,
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
