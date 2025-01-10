import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/MessageUser.dart';

class UserDetailsModal {
  static void show(BuildContext context, Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        colorFilter: ColorFilter.mode(
                          const Color(0xFFADD8E6).withOpacity(0.5),
                          BlendMode.overlay,
                        ),
                        image: AssetImage('${user["userimage"]}'),
                        fit: BoxFit.contain,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user["fullname"],
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xFF4D4D4D),
                            ),
                          ),
                        ),
                        Text(
                          user["username"],
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color(0xFF656263),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // MessageUserModal(
                  //     userId: user["userid"], userName: user["username"]),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      IconButton(
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.email_outlined,
                          color: Color(0xFF55AC9F),
                          size: 26,
                        ),
                        onPressed: () {
                          MessageUserModal(user["userid"], user["username"])
                              .show(context);
                        },
                      ),
                      Transform.translate(
                        offset: const Offset(0, -8),
                        child: Text(
                          'Message Me!',
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                              color: Color(0xFF656263),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 26),
              _buildSectionTitle("Most Recent Activity"),
              _buildActivityRow(
                "Total Steps",
                "${user["steps"]}",
                "Total Distance",
                user["distance"],
                "Mood Rating",
                "${user["mood"]}",
              ),
              // const Divider(thickness: 0.7, height: 60),
              const SizedBox(height: 30),
              _buildSectionTitle("This Week's Progress"),
              _buildActivityRow(
                "Total Steps",
                "${user["weeklySteps"]}",
                "Total Distance",
                user["weeklyDistance"],
                "Mood Rating",
                "${user["weeklyMood"]}",
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF4BA093),
            ),
          ),
        ));
  }

  static Widget _buildActivityRow(
    String label1,
    String value1,
    String label2,
    String value2,
    String label3,
    String value3,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildActivityColumn(label1, value1),
        buildActivityColumn(label2, value2),
        buildActivityColumn(label3, value3),
      ],
    );
  }

  static Widget buildActivityColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Color(0xFF4D4D4D),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: Color(0xFF4D4D4D),
            ),
          ),
        ),
      ],
    );
  }
}
