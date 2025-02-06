import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/UserProvider.dart';

class FindCompanionsPage extends StatefulWidget {
  const FindCompanionsPage({super.key});

  @override
  _FindCompanionsPageState createState() => _FindCompanionsPageState();
}

class _FindCompanionsPageState extends State<FindCompanionsPage> {
  UserDetailsProvider userProvider = UserDetailsProvider();

  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> searchedUsers = [];
  bool isConnectionFailed = false;
  bool addedNewFriend = false;
  bool isLoading = false;

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
    final userId = FirebaseAuth.instance.currentUser!.uid;

    setState(() {
      isLoading = true;
    });

    try {
      // get total user count
      int totalUsers = await userProvider.getUsersCount() ?? 0;
      int fetchedCount = 0;

      // fetch the first 5 users before the loop
      List<Map<String, dynamic>> initialUsers =
          await userProvider.fetchUsers(userId, null);

      if (initialUsers.isNotEmpty) {
        fetchedCount += initialUsers.length;
        setState(() {
          users.addAll(initialUsers);
        });
      }

      // continue fetching remaining users (not including the current user)
      while (fetchedCount < totalUsers - 1) {
        List<Map<String, dynamic>> fetchedUsers =
            await userProvider.fetchUsers(userId, users.last["userId"]);

        if (fetchedUsers.isNotEmpty) {
          fetchedCount += fetchedUsers.length;

          setState(() {
            users.addAll(fetchedUsers);
          });
          print("fetchedCount: $fetchedCount totalUsers: $totalUsers");

          // when user searches, searchUsers function is called to render the loaded searched users
          if (searchController.text.trim().isNotEmpty) {
            searchUsers(searchController.text);
          }
        }

        if (fetchedCount == totalUsers - 1) {
          setState(() {
            isLoading = false;
          });
          break;
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isConnectionFailed = true;
      });
    }
  }

  void searchUsers(String query) {
    setState(() {
      searchedUsers = users
          .where((user) =>
              user["username"].toLowerCase().contains(query.toLowerCase()) ||
              user["name"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void addFriend(int index, String friendId) async {
    setState(() {
      if (searchController.text.trim().isEmpty) {
        users[index]["status"] = "loading";
      } else {
        searchedUsers[index]["status"] = "loading";
      }
    });

    final userId = FirebaseAuth.instance.currentUser!.uid;

    String result =
        await Provider.of<UserDetailsProvider>(context, listen: false)
            .sendFriendRequest(userId, friendId);

    if (result == "success") {
      setState(() {
        if (searchController.text.trim().isEmpty) {
          users[index]["status"] = "request_sent";
        } else {
          searchedUsers[index]["status"] = "request_sent";
        }
      });
    } else {
      showBottomSnackBar(context, result);
    }
  }

  void cancelFriendRequest(int index, String friendId) async {
    setState(() {
      if (searchController.text.trim().isEmpty) {
        users[index]["status"] = "loading";
      } else {
        searchedUsers[index]["status"] = "loading";
      }
    });

    final userId = FirebaseAuth.instance.currentUser!.uid;

    String result =
        await Provider.of<UserDetailsProvider>(context, listen: false)
            .cancelFriendRequest(userId, friendId);
    if (result == "success") {
      setState(() {
        if (searchController.text.trim().isEmpty) {
          users[index]["status"] = "add";
        } else {
          searchedUsers[index]["status"] = "add";
        }
      });
    } else {
      showBottomSnackBar(context, result);
    }
  }

  void acceptFriend(int index, String friendId) async {
    setState(() {
      if (searchController.text.trim().isEmpty) {
        users[index]["status"] = "loading";
      } else {
        searchedUsers[index]["status"] = "loading";
      }
    });

    final userId = FirebaseAuth.instance.currentUser!.uid;

    String result =
        await Provider.of<UserDetailsProvider>(context, listen: false)
            .acceptFriendRequest(userId, friendId);
    if (result == "success") {
      setState(() {
        addedNewFriend = true;

        if (searchController.text.trim().isEmpty) {
          users[index]["status"] = "friend";
        } else {
          searchedUsers[index]["status"] = "friend";
        }
      });
    } else {
      showBottomSnackBar(context, result);
    }
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
              // to call initialize friends when there are changes
              if (addedNewFriend) {
                Navigator.pop(context, "newFriendAdded");
              } else {
                Navigator.pop(context);
              }
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
              onChanged: searchUsers,
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
            isConnectionFailed
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/error.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          color: const Color(0xFF999999),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Connection Failed",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color(0xFF999999),
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Flexible(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      itemCount: searchController.text.trim().isEmpty
                          ? users.length + (isLoading ? 1 : 0)
                          : searchedUsers.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        int usersLength;
                        List<Map<String, dynamic>> filteredUsers;
                        if (searchController.text.trim().isEmpty) {
                          usersLength = users.length;
                          filteredUsers = users;
                        } else {
                          usersLength = searchedUsers.length;
                          filteredUsers = searchedUsers;
                        }

                        if (isLoading && index == usersLength) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF36B9A5),
                              strokeWidth: 5,
                            ),
                          );
                        }

                        final user = filteredUsers[index];

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 0.0),
                          leading: Consumer<UserDetailsProvider>(
                            builder: (context, userDetailsProvider, child) {
                              String imageUrl = user['profileImage'];

                              return Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: imageUrl != "no_image"
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Container(
                                              padding: const EdgeInsets.all(12),
                                              color: Colors.grey[50],
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.grey[300],
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/images/user.jpg',
                                              fit: BoxFit.cover,
                                              color: const Color(0xFFADD8E6)
                                                  .withOpacity(0.5),
                                              colorBlendMode: BlendMode.overlay,
                                            );
                                          },
                                        )
                                      : Image.asset(
                                          'assets/images/user.jpg',
                                          fit: BoxFit.cover,
                                          color: const Color(0xFFADD8E6)
                                              .withOpacity(0.5),
                                          colorBlendMode: BlendMode.overlay,
                                        ),
                                ),
                              );
                            },
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
                          trailing: user["status"] == "loading"
                              ? Container(
                                  width: 22,
                                  height: 22,
                                  margin: const EdgeInsets.only(right: 2),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.grey[300],
                                  ),
                                )
                              : user["status"] == "friend"
                                  ? Image.asset(
                                      'assets/icons/connected.png',
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.contain,
                                    )
                                  : user["status"] == "request_sent"
                                      ? GestureDetector(
                                          onTap: () => cancelFriendRequest(
                                              index, user['userId']),
                                          child: Image.asset(
                                            'assets/icons/request_sent.png',
                                            width: 25,
                                            height: 25,
                                            color: const Color(0xFF73D2C3),
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                      : user["status"] == "pending_request"
                                          ? GestureDetector(
                                              onTap: () => acceptFriend(
                                                  index, user['userId']),
                                              child: Image.asset(
                                                'assets/icons/pending_request.png',
                                                width: 25,
                                                height: 25,
                                                color: const Color(0xFF73D2C3),
                                                fit: BoxFit.contain,
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: () => addFriend(
                                                  index, user['userId']),
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
