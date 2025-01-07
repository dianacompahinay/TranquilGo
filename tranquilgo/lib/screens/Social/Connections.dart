import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConnectionsPage extends StatelessWidget {
  const ConnectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6, top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 0.2,
                        blurRadius: 2,
                        offset: const Offset(0, 1.2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // user image
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            colorFilter: ColorFilter.mode(
                              const Color(0xFFADD8E6).withOpacity(0.5),
                              BlendMode.overlay,
                            ),
                            image: const AssetImage('assets/images/user.jpg'),
                            fit: BoxFit.contain,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      // username
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Username${index + 1}',
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                color: Color(0xFF656263),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // status
                      Row(
                        children: [
                          index % 2 == 0
                              ? const Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: Color(0xFFA8EFD3),
                                )
                              : const Icon(
                                  Icons.circle_outlined,
                                  size: 12,
                                  color: Color(0xFFB5B5B5),
                                ),
                          const SizedBox(width: 5),
                          Text(
                            index % 2 == 0 ? "Active" : "Offline",
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                color: Color(0xFF656263),
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 22),
                      const Icon(
                        Icons.forward_to_inbox_rounded,
                        size: 18,
                        color: Color(0xFF88C0B7),
                      ),
                    ],
                  ),
                );
              },
            ),
            // search user
            Align(
              alignment: const Alignment(1.05, 0.95),
              child: SizedBox(
                width: 55,
                height: 55,
                child: FloatingActionButton(
                  onPressed: () =>
                      {Navigator.pushNamed(context, '/searchusers')},
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.person_search_outlined,
                    color: Color(0xFF55AC9F),
                    size: 30,
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
