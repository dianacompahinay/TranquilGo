import 'package:flutter/material.dart';

class Mindfulness extends StatefulWidget {
  const Mindfulness({super.key});

  @override
  State<Mindfulness> createState() => _MindfulnessState();
}

class _MindfulnessState extends State<Mindfulness> {
  Widget buildMenuItem({
    required String title,
    required String iconPath,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => {Navigator.pushNamed(context, route)},
      child: Container(
        padding:
            const EdgeInsets.only(left: 25, right: 25, top: 13, bottom: 13),
        margin: const EdgeInsets.only(top: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 15, color: Color(0xFF606060)),
            ),
          ],
        ),
      ),
    );
  }

  // main build method
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 138,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                    const Color(0xFFADD8E6).withOpacity(0.25),
                    BlendMode.overlay,
                  ),
                  image: const AssetImage('assets/images/mindfulness.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 8),
            buildMenuItem(
              title: "Mood Record",
              iconPath: "assets/icons/mood.png",
              route: "/moodrecord",
            ),
            buildMenuItem(
              title: "Journal Notes",
              iconPath: "assets/icons/logs_filled.png",
              route: "/journalnotes",
            ),
            buildMenuItem(
              title: "Gratitude Logs",
              iconPath: "assets/icons/notes_filled.png",
              route: "/gratitudelogs",
            ),
          ],
        ),
      ),
    );
  }
}
