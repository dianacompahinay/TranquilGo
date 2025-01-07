// import 'package:flutter/material.dart';

// class Mindfulness extends StatefulWidget {
//   const Mindfulness({super.key});

//   @override
//   State<Mindfulness> createState() => _MindfulnessState();
// }

// class _MindfulnessState extends State<Mindfulness> {
//   // track the currently displayed page
//   String currentPage = "menu";

//   Widget buildMenuItem({
//     required String title,
//     required String iconPath,
//     required String pageName,
//   }) {
//     return GestureDetector(
//       onTap: () => {
//         setState(() {
//           currentPage = pageName;
//         })
//       },
//       child: Container(
//         padding:
//             const EdgeInsets.only(left: 25, right: 25, top: 13, bottom: 13),
//         margin: const EdgeInsets.only(top: 14),
//         decoration: BoxDecoration(
//           color: const Color(0xFFE4EBEB),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 35,
//               height: 35,
//               padding: const EdgeInsets.all(5.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Image.asset(
//                 iconPath,
//                 fit: BoxFit.contain,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Text(
//               title,
//               style: const TextStyle(fontSize: 15, color: Color(0xFF606060)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // main build method
//   @override
//   Widget build(BuildContext context) {
//     Widget content;

//     // determine what to show based on currentPage variable
//     if (currentPage == "menu") {
//       content = Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             height: 112,
//             margin: const EdgeInsets.only(top: 20),
//             decoration: BoxDecoration(
//               image: const DecorationImage(
//                 image: AssetImage('assets/images/mindfulness.png'),
//                 fit: BoxFit.contain,
//               ),
//               borderRadius: BorderRadius.circular(14),
//             ),
//           ),
//           const SizedBox(height: 8),
//           buildMenuItem(
//             title: "Mood Record",
//             iconPath: "assets/icons/mood.png",
//             pageName: "moodRecord",
//           ),
//           buildMenuItem(
//             title: "Reflection Notes",
//             iconPath: "assets/icons/logs_filled.png",
//             pageName: "reflectionNotes",
//           ),
//           buildMenuItem(
//             title: "Gratitude Logs",
//             iconPath: "assets/icons/notes_filled.png",
//             pageName: "gratitudeLogs",
//           ),
//         ],
//       );
//     } else if (currentPage == "moodRecord") {
//       content = const MoodRecord();
//     } else if (currentPage == "gratitudeLogs") {
//       content = GratitudeLogs();
//     } else if (currentPage == "reflectionNotes") {
//       content = const ReflectionNotes();
//     } else {
//       content = const Center(
//         child: Text(
//           "Page Not Found",
//           style: TextStyle(fontSize: 18, color: Colors.red),
//         ),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.only(left: 20, right: 20),
//       constraints: const BoxConstraints.expand(),
//       decoration: const BoxDecoration(
//         color: Color(0xFFFFFFFF),
//       ),
//       child: content,
//     );
//   }
// }

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
          color: const Color(0xFFE4EBEB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              padding: const EdgeInsets.all(5.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 112,
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/mindfulness.png'),
                fit: BoxFit.contain,
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
    );
  }
}
