import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:minutes_summary/pages/barcodescanner.dart';
import 'package:minutes_summary/pages/bookdetails.dart';
import 'package:minutes_summary/pages/librarylobby.dart';
import 'package:minutes_summary/pages/loginpage.dart';

final storage = FlutterSecureStorage();
String? value;

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Future<DocumentSnapshot> docSnapshotFuture;
  Map<String, dynamic> dataTEMP = Map<String, dynamic>();
  TextEditingController roomcontroller = TextEditingController();
  TextEditingController roomcodecontroller = TextEditingController();
  User? currentUser = FirebaseAuth.instance.currentUser;
  var name;
  Timer? _refreshTimer;

  late List<Map<String, dynamic>> mainroomlist = [];

  // Function to show the confirmation dialog
  Future<void> _showConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Curvy edges
          ),
          elevation: 16,
          backgroundColor: Colors.black, // Black background
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Do you want to leave the Room?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black, // Black text
                        backgroundColor: Colors.white, // White background
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15), // Curvy edges
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close dialog on "No"
                      },
                      child: const Text('No'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // White text
                        backgroundColor: Colors.red, // Red background
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15), // Curvy edges
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close dialog on "Yes"
                        print('User clicked Yes!');
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    Firebase.initializeApp();
    _refreshTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      _refresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> updatevariables() async {
    setState(() {
      mainroomlist;
      name;
    });
  }

  /* Future<void> _refresh() async {
    // Simulate a network call or data refresh
    await Future.delayed(Duration(seconds: 2));
    updatevariables();
    Map<dynamic, dynamic> data1;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .collection('rooms')
        .doc(currentUser?.uid)
        .get() as DocumentSnapshot<Object?>;
    data1 = snapshot.data() as Map<dynamic, dynamic>;
    if (snapshot.exists) {
      var roomsData = data1['roomlist'];
      if (data1 != null && roomsData != null) {
        mainroomlist = List<Map<String, dynamic>>.from(roomsData);
        print('----mainroomlist--- $mainroomlist');
        print('----mainroomlist--- $mainroomlist');
        print('----mainroomlist--- $mainroomlist');
        print('----mainroomlist--- $mainroomlist');
      }
    }
  } */

  Future<void> _refresh() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .collection('rooms')
          .doc(currentUser?.uid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        if (data != null && data['roomlist'] != null) {
          setState(() {
            mainroomlist = List<Map<String, dynamic>>.from(data['roomlist']);
          });
        }
      }
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

/* Future<Map<dynamic, dynamic>> fetchData() async {
  var value = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get()
  return value.docs.first.data();
} */
  void _showcreateRoomDialog(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference users = firestore.collection('users');
    late List<Map<String, dynamic>> generalroomlist = [];
    final GlobalKey<FormState> _fKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Curvy edges
          ),
          elevation: 16,
          backgroundColor: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Library Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15),
                Form(
                  key: _fKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: roomcontroller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Library Name',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Library Name cannot be empty';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: roomcodecontroller,
                        obscureText: true,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Entrance Code',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Entrance Code cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        if (_fKey.currentState!.validate()) {
                          List<Map<String, dynamic>>? rlist = [];
                          Map<dynamic, dynamic> data;

                          // Add your action on submit here
                          DocumentSnapshot snapshot = await users
                              .doc(currentUser?.uid)
                              .collection('rooms')
                              .doc(currentUser?.uid)
                              .get();

                          data = snapshot.data() as Map<dynamic, dynamic>;

                          var roomsData = data['roomlist'];
                          if (roomsData != null)
                            rlist = List<Map<String, dynamic>>.from(roomsData);

                          if (snapshot.exists) {
                            // Get the current list of rooms from Firestore if it exists

                            bool storeflag = true;
                            if (data != null && roomsData != null) {
                              for (int i = 0; i < roomsData.length; i++) {
                                if (roomsData[i]['room'] ==
                                        roomcontroller.text.trim() &&
                                    roomsData[i]['code'] ==
                                        roomcodecontroller.text.trim()) {
                                  storeflag = false;
                                  print('------>storeflag activated<<<<<<<<<');
                                }
                              }
                              if (storeflag) {
                                print('------>new data stored<<<<<<<<<');

                                if ((roomcontroller.text.trim().isNotEmpty &&
                                    roomcodecontroller.text
                                        .trim()
                                        .isNotEmpty)) {
                                  rlist.add({
                                    'room': roomcontroller.text.trim(),
                                    'code': roomcodecontroller.text.trim(),
                                    'admin': currentUser?.uid,
                                    'booklist': []
                                  });
                                }
                              }
                            }
                          }
                          // rlist.add();
                          // Add the new room to the list

                          await users
                              .doc(currentUser?.uid)
                              .collection('rooms')
                              .doc(currentUser?.uid)
                              .set({'roomlist': rlist});

                          {
                            //this new room will also be added into general--> all_users_rooms-->roomlist
                            late Map<String, dynamic> roomingeneral =
                                Map<String, dynamic>();
                            if (roomcodecontroller.text != null &&
                                roomcontroller.text != null) {
                              try {
                                roomingeneral['booklist'] = [];
                                roomingeneral['admin'] = currentUser?.uid;
                                roomingeneral['room'] =
                                    roomcontroller.text.trim();
                                roomingeneral['code'] =
                                    roomcodecontroller.text.trim();
                                await FirebaseFirestore.instance
                                    .collection('general')
                                    .doc('all_users_rooms')
                                    .collection('rooms')
                                    .doc(
                                        '${roomcontroller.text.trim()}${roomcodecontroller.text.trim()}')
                                    .set({'roomdata': roomingeneral});
                              } on Exception catch (e) {
                                // TODO
                              }
                            }

                            roomcodecontroller.clear();
                            roomcontroller.clear();
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showaddRoomDialog(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference users = firestore.collection('users');
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final GlobalKey<FormState> _fKey = GlobalKey<FormState>();
    final TextEditingController lNameController = TextEditingController();

    List<String> entrancecodelist = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Curvy edges
          ),
          elevation: 16,
          backgroundColor: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Library Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15),
                Form(
                  key: _fKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: roomcontroller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Library Name',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Library Name cannot be empty';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: roomcodecontroller,
                        obscureText: true,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Entrance Code',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Entrance Code cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 16,
                              backgroundColor: Colors.grey,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Library Name',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      TextFormField(
                                        controller: lNameController,
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          labelText: 'Library Name',
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          filled: true,
                                          fillColor: Colors.grey[800],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Library Name cannot be empty';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.black,
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                            ),
                                            onPressed: () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                Navigator.of(context).pop();

                                                {
                                                  // now we have to fetch all roomlist of admin and chechk for same room name there codes available or not and then we have to show.
                                                  DocumentSnapshot snapshot =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('users')
                                                          .doc(currentUser?.uid)
                                                          .collection('rooms')
                                                          .doc(currentUser?.uid)
                                                          .get();
                                                  if (snapshot.exists) {
                                                    Map<dynamic, dynamic> data;

                                                    data = snapshot.data()
                                                        as Map<dynamic,
                                                            dynamic>;

                                                    List<dynamic> rlist =
                                                        data['roomlist'];
                                                    for (int i = 0;
                                                        i < rlist.length;
                                                        i++) {
                                                      if (rlist[i]['room'] ==
                                                          '${lNameController.text.trim()}') {
                                                        entrancecodelist.add(
                                                            rlist[i]['code']);
                                                      }
                                                    }
                                                  }
                                                }

                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      elevation: 16,
                                                      backgroundColor:
                                                          Colors.grey,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              'Entrance Code List: \n $entrancecodelist',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Text(
                                                              '(::All codes with same library name::)',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 10,
                                                                  fontFamily:
                                                                      'fantasy',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                                lNameController.clear();
                                              }
                                            },
                                            child: Text('Search'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ));
                        },
                      );
                    },
                    child: Text(
                      'Forgot Code? (Admin Only)',
                      style: TextStyle(color: Colors.white),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        if (_fKey.currentState!.validate()) {
                          try {
                            Map<dynamic, dynamic> roomingeneral =
                                Map<dynamic, dynamic>();
                            DocumentSnapshot snapshot = await FirebaseFirestore
                                .instance
                                .collection('general')
                                .doc('all_users_rooms')
                                .collection('rooms')
                                .doc(
                                    '${roomcontroller.text.trim()}${roomcodecontroller.text.trim()}')
                                .get();

                            // var temp = snapshot.data() as Map<dynamic, dynamic>;
                            // roomingeneral = temp['roomdata'];
                            if (snapshot.exists && snapshot.data() != null) {
                              var temp =
                                  snapshot.data() as Map<dynamic, dynamic>;

                              roomingeneral = temp['roomdata'];
                              // Use `temp` safely here
                            } else {
                              print(
                                  '--addroom-- Document does not exist or data is null');
                            }

                            List<Map<String, dynamic>>? rlist = [];
                            Map<dynamic, dynamic> data;
                            DocumentSnapshot snapshot2 = await users
                                .doc(currentUser?.uid)
                                .collection('rooms')
                                .doc(currentUser?.uid)
                                .get();

                            if (snapshot2.exists) {
                              data = snapshot2.data() as Map<dynamic, dynamic>;
                              var roomsData = data['roomlist'];
                              print('roomsdata-----> $roomsData');
                              if (roomsData != null) {
                                rlist =
                                    List<Map<String, dynamic>>.from(roomsData);
                              }

                              if (rlist != null) {
                                bool storeflag = false;
                                print('outside stroreflag false ---->');
                                print(
                                    'room--> ${roomingeneral['room']} code--> ${roomingeneral['code']}');

                                if (roomingeneral['room'] ==
                                        roomcontroller.text.trim() &&
                                    roomingeneral['code'] ==
                                        roomcodecontroller.text.trim()) {
                                  storeflag = true;
                                  print('storeflag true ---->');
                                  for (int i = 0; i < roomsData.length; i++) {
                                    if (roomsData[i]['room'] ==
                                            roomcontroller.text &&
                                        roomsData[i]['code'] ==
                                            roomcodecontroller.text) {
                                      storeflag = false;
                                      print('stroreflag false ---->');
                                    }
                                  }
                                }
                                if (storeflag) {
                                  print('rlist added');
                                  rlist.add({
                                    'room': roomcontroller.text.trim(),
                                    'code': roomcodecontroller.text.trim(),
                                    'booklist': roomingeneral['booklist']
                                  });
                                  await users
                                      .doc(currentUser?.uid)
                                      .collection('rooms')
                                      .doc(currentUser?.uid)
                                      .set({'roomlist': rlist});
                                }
                              }
                            } else {
                              rlist.add({
                                'room': roomcontroller.text.trim(),
                                'code': roomcodecontroller.text.trim(),
                                'booklist': roomingeneral['booklist']
                              });
                              await users
                                  .doc(currentUser?.uid)
                                  .collection('rooms')
                                  .doc(currentUser?.uid)
                                  .set({'roomlist': rlist});
                            }
                          } on Exception catch (e) {
                            // TODO
                          }

                          roomcodecontroller.clear();
                          roomcontroller.clear();
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _initializeData() async {
    try {
      var value = await storage.read(key: 'uid');
      var docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(value)
          .collection('profile')
          .doc(value)
          .get();

      var docdata = docSnapshot.data() as Map<dynamic, dynamic>;
      name = docdata['name'];
      print('----NAME ------> $name');

      {
        Map<dynamic, dynamic> data;
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .collection('rooms')
            .doc(currentUser?.uid)
            .get();
        data = snapshot.data() as Map<dynamic, dynamic>;
        if (snapshot.exists) {
          var roomsData = data['roomlist'];
          if (data != null && roomsData != null) {
            mainroomlist = List<Map<String, dynamic>>.from(roomsData);
            print('----mainroomlist--- $mainroomlist');
            print('----mainroomlist--- $mainroomlist');
          }
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        //  data = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference users = firestore.collection('users');
    updatevariables();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Places items at extreme ends
              children: [
                // Left side: Greeting text or animation
                Padding(
                  padding: EdgeInsets.only(
                    left:
                        screenWidth * 0.03, // Left margin for proper alignment
                    top: screenHeight *
                        0.05, // Top margin for vertical alignment
                  ),
                  child: name != null
                      ? AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Hello $name!',
                              textStyle: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Colors.black45,
                              ),
                              speed: Duration(milliseconds: 200),
                            ),
                          ],
                          isRepeatingAnimation: false,
                        )
                      : SizedBox(), // Empty space when name is null
                ),

                // Right side: Logout icon
                Padding(
                  padding: EdgeInsets.only(
                    right:
                        screenWidth * 0.02, // Right margin for proper alignment
                    top: screenHeight *
                        0.05, // Top margin for vertical alignment
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      final FirebaseAuth _auth = FirebaseAuth.instance;
                      await _auth.signOut();
                      await storage.deleteAll(); // Clear UID from local storage

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Logged out successfully!')),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.exit_to_app,
                      color: Colors.black,
                      size: 30, // Adjust the size as needed
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(screenWidth * 0.02,
                  screenHeight * 0.02, screenWidth * 0.02, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .start, // Ensure even spacing between buttons
                children: [
                  Expanded(
                    // Wrap the first button in Expanded to share available space
                    child: ElevatedButton(
                      onPressed: () {
                        _showcreateRoomDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.black, // Button background color
                        shape: StadiumBorder(), // Rounded shape
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth *
                              0.03, // Reduced padding for better scaling
                          vertical: screenHeight * 0.02,
                        ),
                        textStyle: TextStyle(
                          fontSize: screenWidth *
                              0.045, // Dynamic font size based on screen width
                          fontWeight: FontWeight.bold, // Bold text style
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Center the button content
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.white,
                            size: screenWidth *
                                0.05, // Adjust icon size dynamically
                          ),
                          SizedBox(
                            width: screenWidth *
                                0.02, // Adjust spacing between icon and text
                          ),
                          Text(
                            'Create Library',
                            style: TextStyle(
                                color: Colors.white), // White text color
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width:
                        screenWidth * 0.03, // Reduced spacing between buttons
                  ),
                  Expanded(
                    // Wrap the second button in Expanded for shared space
                    child: ElevatedButton(
                      onPressed: () {
                        _showaddRoomDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.black, // Button background color
                        shape: StadiumBorder(), // Rounded shape
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth *
                              0.03, // Reduced padding for better scaling
                          vertical: screenHeight * 0.02,
                        ),
                        textStyle: TextStyle(
                          fontSize: screenWidth *
                              0.045, // Dynamic font size based on screen width
                          fontWeight: FontWeight.bold, // Bold text style
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Center the button content
                        children: [
                          Icon(
                            Icons.archive_rounded,
                            color: Colors.white,
                            size: screenWidth *
                                0.05, // Adjust icon size dynamically
                          ),
                          SizedBox(
                            width: screenWidth *
                                0.02, // Adjust spacing between icon and text
                          ),
                          Text(
                            'Add Library',
                            style: TextStyle(
                                color: Colors.white), // White text color
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(screenWidth * 0.01,
                  screenHeight * 0.02, screenWidth * 0.6, 0),
              child: Text(
                'My Libraries',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                    fontSize: screenWidth * 0.06),
              ),
            ),
            /*  ElevatedButton(
              onPressed: () {
                // Log out or handle sign-out logic here
                // Navigate to SignOutScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(30), // Make the button rounded
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: 30, vertical: 15), // Button padding
              ),
              child: null,
            ), */
            mainroomlist.length == 0
                ? Padding(
                    padding: EdgeInsets.fromLTRB(0, screenHeight * 0.3, 0, 0),
                    child: Center(
                      child: Text(
                        'No Library',
                        style: TextStyle(
                          fontSize: screenWidth *
                              0.04, // Set your desired font size here
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.01),
                      itemCount: mainroomlist.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: Key(mainroomlist[index]['room']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.01),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: screenWidth * 0.06),
                            child: Icon(
                              Icons.delete_sweep_outlined,
                              color: Colors.white,
                              size: screenWidth * 0.07,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        20), // Curvy edges
                                  ),
                                  elevation: 16,
                                  backgroundColor:
                                      Colors.black, // Black background
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Do you want to leave the Liabrary?',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor:
                                                    Colors.black, // Black text
                                                backgroundColor: Colors
                                                    .white, // White background
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15), // Curvy edges
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(
                                                    context); // Close dialog on "No"
                                              },
                                              child: const Text('No'),
                                            ),
                                            const SizedBox(width: 10),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor:
                                                    Colors.white, // White text
                                                backgroundColor: Colors
                                                    .red, // Red background
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15), // Curvy edges
                                                ),
                                              ),
                                              onPressed: () async {
                                                mainroomlist.removeAt(index);
                                                await users
                                                    .doc(currentUser?.uid)
                                                    .collection('rooms')
                                                    .doc(currentUser?.uid)
                                                    .set({
                                                  'roomlist': mainroomlist
                                                });

                                                Navigator.pop(
                                                    context); // Close dialog on "Yes"
                                                print('User clicked Yes!');
                                              },
                                              child: const Text('Yes'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            setState(() {
                              mainroomlist.removeAt(index);
                              // TODO: Add Firestore deletion logic
                            });
                          },
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to a new screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LibraryLobby(
                                    currentuseruid: '${currentUser?.uid}',
                                    libraryname:
                                        '${mainroomlist[index]['room']}',
                                    entrancecode:
                                        '${mainroomlist[index]['code']}',
                                    name: name,
                                  ), // Replace with your new screen widget
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.007,
                                horizontal: screenWidth * 0.02,
                              ),
                              padding: EdgeInsets.all(screenHeight * 0.01),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.grey[700]!,
                                    Colors.grey[600]!,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                  vertical: screenHeight * 0.02,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${mainroomlist[index]['room']}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.045,
                                          fontWeight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    currentUser?.uid ==
                                            mainroomlist[index]['admin']
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: screenWidth * 0.04),
                                            child: Container(
                                              child: Text(
                                                'Admin',
                                                style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color.fromARGB(
                                                        255, 175, 228, 154)),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
