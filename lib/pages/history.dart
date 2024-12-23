import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minutes_summary/pages/librarylobby.dart';

class History extends StatefulWidget {
  String libraryname, entrancecode, currentuseruid, name;
  History(
      {super.key,
      required this.libraryname,
      required this.entrancecode,
      required this.currentuseruid,
      required this.name});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  // Sample static list of data
  List<dynamic> historyData = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getthehistory();
    _refreshTimer = Timer.periodic(Duration(milliseconds: 250), (timer) {
      setState(() {
        // Optionally fetch new data
        getthehistory();
        timer.cancel();
      });
    });
  }

  Future<void> getthehistory() async {
    String library_admin_uid;
    //get the admin uid first
    DocumentSnapshot snapshottmp = await FirebaseFirestore.instance
        .collection('general')
        .doc('all_users_rooms')
        .collection('rooms')
        .doc('${widget.libraryname}${widget.entrancecode}')
        .get();
    var data7 = snapshottmp.data() as Map<dynamic, dynamic>;
    library_admin_uid = data7['roomdata']['admin'];

    // Add your action on submit here
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(library_admin_uid)
        .collection('history')
        .doc('${widget.libraryname}${widget.entrancecode}')
        .get();

    if (snapshot.exists) {
      var data = snapshot.data() as Map<dynamic, dynamic>;
      historyData = data['historylist'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black, // Black background

      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.04, top: screenHeight * 0.065),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LibraryLobby(
                                currentuseruid: widget.currentuseruid,
                                libraryname: widget.libraryname,
                                entrancecode: widget.entrancecode,
                                name: widget.name)));
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.23, top: screenHeight * 0.065),
                child: Text(
                  "Library Hitory",
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: historyData.length,
              itemBuilder: (context, index) {
                var len = historyData.length;
                var item = historyData[len - index - 1];
                return Card(
                  color: Colors.white, // White Tile
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4, // Shadow for a lifted effect
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.black, // Black circle
                      child: const Icon(
                        Icons.library_books,
                        color: Colors.white, // White icon
                      ),
                    ),
                    title: Text(
                      item['bookname'] ?? 'Unknown Library',
                      style: const TextStyle(
                        color: Colors.black, // Black text
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          "Issued By: ${item['issuedname'] ?? 'N/A'}",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Return On: ${item['returnon'] ?? 'N/A'}",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black54,
                      size: 16,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
