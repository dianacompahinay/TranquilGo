import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/providers/UserProvider.dart';

class FindCompanionsPage extends StatefulWidget {
  const FindCompanionsPage({super.key});

  @override
  _FindCompanionsPageState createState() => _FindCompanionsPageState();
}

class _FindCompanionsPageState extends State<FindCompanionsPage> {
  UserDetailsProvider userList = UserDetailsProvider();

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
  //     {"username": "john_doe", "name": "John Doe", "status": "friend"},
  //     {"username": "jane_smith", "name": "Jane Smith", "status": "add"},
  //     {"username": "alex_jones", "name": "Alex Jones", "status": "friend"},
  //     {"username": "emily_clark", "name": "Emily Clark", "status": "add"},
  //     {
  //       "username": "michael_brown",
  //       "name": "Michael Brown",
  //       "status": "friend"
  //     },
  //     {"username": "sarah_lee", "name": "Sarah Lee", "status": "add"},
  //     {"username": "david_wright", "name": "David Wright", "status": "friend"},
  //     {"username": "linda_hall", "name": "Linda Hall", "status": "add"},
  //   ];
  //   filteredUsers = List.from(users);
  // }

  Future<void> initializeUsers() async {
    try {
      List<Map<String, dynamic>> fetchedUsers = await userList.fetchUsers();
      setState(() {
        users = fetchedUsers;
        filteredUsers = List.from(users);
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
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
              user["name"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 50,
        leading: Container(
          margin: const EdgeInsets.only(left: 10),
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
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
        title: Text(
          "Find Companions",
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              color: Color(0xFF110000),
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 5),
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

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

            userList.isLoading
                ? const SizedBox()
                : Text(
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
              child: userList.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF36B9A5),
                        strokeWidth: 5,
                      ),
                    )
                  : ListView.builder(
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
                                image:
                                    const AssetImage('assets/images/user.jpg'),
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
                            user["name"],
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Color(0xFF656263),
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          trailing: user["status"] == "friend"
                              ? Image.asset(
                                  'assets/icons/connected.png',
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.contain,
                                )
                              : user["status"] == "request_sent"
                                  ? Image.asset(
                                      'assets/icons/request_sent.png',
                                      width: 25,
                                      height: 25,
                                      color: const Color(0xFF73D2C3),
                                      fit: BoxFit.contain,
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
      ),
    );
  }
}
