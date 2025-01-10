// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class ConnectionsPage extends StatefulWidget {
//   const ConnectionsPage({super.key});

//   @override
//   _ConnectionsPageState createState() => _ConnectionsPageState();
// }

// class _ConnectionsPageState extends State<ConnectionsPage> {
//   List<Map<String, dynamic>> users = [
//     {
//       "userimage": "assets/images/user.jpg",
//       "username": "john_doe",
//       "fullname": "John Doe",
//       "status": "offline"
//     },
//     {
//       "userimage": "assets/images/user.jpg",
//       "username": "jane_smith",
//       "fullname": "Jane Smith",
//       "status": "active",
//     },
//     {
//       "userimage": "assets/images/user.jpg",
//       "username": "alex_jones",
//       "fullname": "Alex Jones",
//       "status": "offline",
//     },
//     {
//       "userimage": "assets/images/user.jpg",
//       "username": "emily_clark",
//       "fullname": "Emily Clark",
//       "status": "offline",
//     },
//     {
//       "userimage": "assets/images/user.jpg",
//       "username": "michael_brown",
//       "fullname": "Michael Brown",
//       "status": "offline",
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         constraints: const BoxConstraints.expand(),
//         decoration: const BoxDecoration(color: Colors.white),
//         child: Stack(
//           children: [
//             ListView.builder(
//               itemCount: 5,
//               itemBuilder: (context, index) {
//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 6, top: 8),
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.3),
//                         spreadRadius: 0.2,
//                         blurRadius: 2,
//                         offset: const Offset(0, 1.2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // user image
//                       Container(
//                         height: 42,
//                         width: 42,
//                         decoration: BoxDecoration(
//                           image: DecorationImage(
//                             colorFilter: ColorFilter.mode(
//                               const Color(0xFFADD8E6).withOpacity(0.5),
//                               BlendMode.overlay,
//                             ),
//                             image: AssetImage('${users[index]["userimage"]}'),
//                             fit: BoxFit.contain,
//                           ),
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                       ),
//                       // username
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           child: Text(
//                             '${users[index]["username"]}',
//                             style: GoogleFonts.inter(
//                               textStyle: const TextStyle(
//                                 color: Color(0xFF656263),
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       // status
//                       Row(
//                         children: [
//                           users[index]["status"] == "active"
//                               ? const Icon(
//                                   Icons.circle,
//                                   size: 12,
//                                   color: Color(0xFFA8EFD3),
//                                 )
//                               : const Icon(
//                                   Icons.circle_outlined,
//                                   size: 12,
//                                   color: Color(0xFFB5B5B5),
//                                 ),
//                           const SizedBox(width: 5),
//                           Text(
//                             users[index]["status"] == "active"
//                                 ? "Active"
//                                 : "Offline",
//                             style: GoogleFonts.inter(
//                               textStyle: const TextStyle(
//                                 color: Color(0xFF656263),
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 11,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(width: 22),
//                       const Icon(
//                         Icons.forward_to_inbox_rounded,
//                         size: 18,
//                         color: Color(0xFF88C0B7),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//             // search user
//             Align(
//               alignment: const Alignment(1.05, 0.95),
//               child: SizedBox(
//                 width: 55,
//                 height: 55,
//                 child: FloatingActionButton(
//                   onPressed: () =>
//                       {Navigator.pushNamed(context, '/searchusers')},
//                   backgroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(50),
//                   ),
//                   child: const Icon(
//                     Icons.person_search_outlined,
//                     color: Color(0xFF55AC9F),
//                     size: 30,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/InviteUser.dart';
import 'package:my_app/components/UserDetailsModal.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key});

  @override
  _ConnectionsPageState createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  List<Map<String, dynamic>> users = [
    {
      "userid": "1",
      "userimage": "assets/images/user.jpg",
      "username": "jandoe",
      "fullname": "John Doe",
      "status": "offline",
      "steps": 2081,
      "distance": "1.5 km",
      "mood": 5.0,
      "weeklySteps": 10088,
      "weeklyDistance": "7.57 km",
      "weeklyMood": 4.5,
    },
    {
      "userid": "2",
      "userimage": "assets/images/user.jpg",
      "username": "jsmith",
      "fullname": "Jane Smith",
      "status": "active",
      "steps": 3000,
      "distance": "2.0 km",
      "mood": 4.8,
      "weeklySteps": 12000,
      "weeklyDistance": "8.0 km",
      "weeklyMood": 4.7,
    },
    {
      "userid": "3",
      "userimage": "assets/images/user.jpg",
      "username": "charliexx",
      "fullname": "Charlie Puth",
      "status": "offline",
      "steps": 2081,
      "distance": "1.5 km",
      "mood": 5.0,
      "weeklySteps": 10088,
      "weeklyDistance": "7.57 km",
      "weeklyMood": 4.5,
    },
    {
      "userid": "4",
      "userimage": "assets/images/user.jpg",
      "username": "swifties",
      "fullname": "Taylor Swift",
      "status": "offline",
      "steps": 3000,
      "distance": "2.0 km",
      "mood": 4.8,
      "weeklySteps": 12000,
      "weeklyDistance": "8.0 km",
      "weeklyMood": 4.7,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => UserDetailsModal.show(context, users[index]),
                  child: Container(
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
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              colorFilter: ColorFilter.mode(
                                const Color(0xFFADD8E6).withOpacity(0.5),
                                BlendMode.overlay,
                              ),
                              image: AssetImage('${users[index]["userimage"]}'),
                              fit: BoxFit.contain,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${users[index]["username"]}',
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
                        Row(
                          children: [
                            users[index]["status"] == "active"
                                ? const Icon(Icons.circle,
                                    size: 12, color: Color(0xFFA8EFD3))
                                : const Icon(Icons.circle_outlined,
                                    size: 12, color: Color(0xFFB5B5B5)),
                            const SizedBox(width: 5),
                            Text(
                              users[index]["status"] == "active"
                                  ? "Active"
                                  : "Offline",
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
                        InviteUser(
                            userId: '${users[index]["userid"]}',
                            userName: '${users[index]["username"]}')
                      ],
                    ),
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
