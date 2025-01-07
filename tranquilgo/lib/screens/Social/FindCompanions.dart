import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FindCompanionsPage extends StatefulWidget {
  const FindCompanionsPage({super.key});

  @override
  _FindCompanionsPageState createState() => _FindCompanionsPageState();
}

class _FindCompanionsPageState extends State<FindCompanionsPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    initializeUsers();
  }

  // void initializeUsers() {
  //   users = [
  //     {"username": "john_doe", "fullname": "John Doe", "isFriend": true},
  //     {"username": "jane_smith", "fullname": "Jane Smith", "isFriend": false},
  //     {"username": "alex_jones", "fullname": "Alex Jones", "isFriend": true},
  //     {"username": "emily_clark", "fullname": "Emily Clark", "isFriend": false},
  //     {
  //       "username": "michael_brown",
  //       "fullname": "Michael Brown",
  //       "isFriend": true
  //     },
  //     {"username": "sarah_lee", "fullname": "Sarah Lee", "isFriend": false},
  //     {
  //       "username": "david_wright",
  //       "fullname": "David Wright",
  //       "isFriend": true
  //     },
  //     {"username": "linda_hall", "fullname": "Linda Hall", "isFriend": false},
  //   ];
  //   filteredUsers = List.from(users);
  // }
  void initializeUsers() {
    users = [
      {"username": "john_doe", "fullname": "John Doe", "status": "friend"},
      {"username": "jane_smith", "fullname": "Jane Smith", "status": "add"},
      {"username": "alex_jones", "fullname": "Alex Jones", "status": "friend"},
      {"username": "emily_clark", "fullname": "Emily Clark", "status": "add"},
      {
        "username": "michael_brown",
        "fullname": "Michael Brown",
        "status": "friend"
      },
      {"username": "sarah_lee", "fullname": "Sarah Lee", "status": "add"},
      {
        "username": "david_wright",
        "fullname": "David Wright",
        "status": "friend"
      },
      {"username": "linda_hall", "fullname": "Linda Hall", "status": "add"},
    ];
    filteredUsers = List.from(users);
  }

  void addFriend(int index) {
    setState(() {
      filteredUsers[index]["status"] = "request_sent";
      final userIndex = users.indexWhere(
          (user) => user["username"] == filteredUsers[index]["username"]);
      if (userIndex != -1) {
        users[userIndex]["status"] = "request_sent";
      }
    });
  }

  void filterUsers(String query) {
    setState(() {
      filteredUsers = users
          .where((user) =>
              user["username"].toLowerCase().contains(query.toLowerCase()) ||
              user["fullname"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // void addFriend(int index) {
  //   setState(() {
  //     filteredUsers[index]["isFriend"] = true;
  //     final userIndex = users.indexWhere(
  //         (user) => user["username"] == filteredUsers[index]["username"]);
  //     if (userIndex != -1) {
  //       users[userIndex]["isFriend"] = true;
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 5),
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title
                Container(
                  height: 94,
                  padding: const EdgeInsets.only(left: 5, right: 5, top: 55),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Center(
                    child: Text(
                      "Find Companions",
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Color(0xFF110000),
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // search bar
                TextField(
                  controller: searchController,
                  // filters the users by the characters in the search bar
                  onChanged: filterUsers,
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF919191),
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF919191),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 2.0,
                      horizontal: 18.0,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFC0C0C0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF55AC9F),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Search Result',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      color: Color(0xFF696969),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),

                // list of users
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 0.0), // Reduced vertical padding
                        leading: Container(
                          height: 40,
                          width: 40,
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
                        title: Text(
                          user["username"],
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color(0xFF525252),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        subtitle: Text(
                          user["fullname"],
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color(0xFF656263),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        trailing: user["status"] == "friend"
                            ? GestureDetector(
                                onTap: () {},
                                child: Image.asset(
                                  'assets/icons/connected.png',
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : user["status"] == "request_sent"
                                ? GestureDetector(
                                    onTap: () {},
                                    child: Image.asset(
                                      'assets/icons/request_sent.png',
                                      width: 25,
                                      height: 25,
                                      color: const Color(0xFF73D2C3),
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () => addFriend(index),
                                    child: Image.asset(
                                      'assets/icons/add_user.png',
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // back button
            Positioned(
              top: 52,
              left: 0,
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
