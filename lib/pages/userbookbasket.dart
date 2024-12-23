import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minutes_summary/pages/booksummary.dart';
import 'package:minutes_summary/pages/librarylobby.dart';

class BookbucketListPage extends StatefulWidget {
  final String currentuseruid;
  final String libraryname;
  final String entrancecode;
  final String name;
  BookbucketListPage(
      {required this.currentuseruid,
      required this.libraryname,
      required this.entrancecode,
      required this.name});
  @override
  _BookbucketListPageState createState() => _BookbucketListPageState();
}

class _BookbucketListPageState extends State<BookbucketListPage> {
  Timer? _refreshTimer;
  List<Map<String, String>> issuedbookslist = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getthebooksofuser();
    print('----issuedbooklist-----> ${issuedbookslist}');
    _refreshTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          // Optionally fetch new data
          issuedbookslist;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _refresh() async {
    getthebooksofuser();
  }

  getthebooksofuser() async {
    issuedbookslist = [];
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuseruid)
        .collection('books')
        .doc('${widget.libraryname}${widget.entrancecode}')
        .get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> datatemp = snapshot.data() as Map<dynamic, dynamic>;
      List<Map<dynamic, dynamic>> bookslist = [];
      bookslist =
          List<Map<dynamic, dynamic>>.from(datatemp!['issuedbookslist']);
      for (int i = 0; i < bookslist.length; i++) {
        issuedbookslist.add({
          'bookname': bookslist[i]['bookname'],
          'returndate': '${bookslist[i]['returndate']}'
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Column(
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.04, top: screenHeight * 0.07),
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
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.23, top: screenHeight * 0.065),
              child: Text(
                "My Books Basket",
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Colors.black),
              ),
            ),
          ],
        ),
        issuedbookslist.length == 0
            ? Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.5),
                child: Center(
                  child: Text(
                    'No Book in the Basket!',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              )
            : Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0,
                      bottom: screenHeight * 0,
                      left: screenWidth * 0.03,
                      right: screenWidth * 0.03),
                  child: ListView.builder(
                    itemCount: issuedbookslist.length,
                    itemBuilder: (context, index) {
                      final book = issuedbookslist[index];
                      return Card(
                        color: Colors.grey[900],
                        elevation: 4,
                        margin: EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Icon(
                            Icons.book,
                            color: Colors.white70,
                            size: 32,
                          ),
                          title: Text(
                            issuedbookslist[index]['bookname'] ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            "Return Date: ${issuedbookslist[index]['returndate']}",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                          ),
                          onTap: () {
                            // Action on tap
                            showDialog(
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
                                          'Do you want to return the book?',
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
                                                    .green, // Green background
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15), // Curvy edges
                                                ),
                                              ),
                                              onPressed: () async {
                                                {
                                                  // delete the book from users->books->issuedbooklist...
                                                  DocumentSnapshot snapshot =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('users')
                                                          .doc(widget
                                                              .currentuseruid)
                                                          .collection('books')
                                                          .doc(
                                                              '${widget.libraryname}${widget.entrancecode}')
                                                          .get();
                                                  Map<dynamic, dynamic>
                                                      datatemp = snapshot.data()
                                                          as Map<dynamic,
                                                              dynamic>;
                                                  List<Map<dynamic, dynamic>>
                                                      bookslist = [];
                                                  bookslist = List<
                                                          Map<dynamic,
                                                              dynamic>>.from(
                                                      datatemp![
                                                          'issuedbookslist']);
                                                  bookslist.removeAt(index);

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(
                                                          widget.currentuseruid)
                                                      .collection('books')
                                                      .doc(
                                                          '${widget.libraryname}${widget.entrancecode}')
                                                      .set({
                                                    'issuedbookslist': bookslist
                                                  });
                                                }
                                                {
                                                  //(personal data)As book is returned so that Add null value to return date in users->rooms->booklist->returndate
                                                  List<Map<String, dynamic>>?
                                                      rlist = [];
                                                  Map<dynamic, dynamic> data;
                                                  // Add your action on submit here
                                                  DocumentSnapshot snapshot =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('users')
                                                          .doc(widget
                                                              .currentuseruid)
                                                          .collection('rooms')
                                                          .doc(widget
                                                              .currentuseruid)
                                                          .get();

                                                  data = snapshot.data()
                                                      as Map<dynamic, dynamic>;
                                                  var roomsData =
                                                      data['roomlist'];
                                                  if (roomsData != null)
                                                    rlist = List<
                                                            Map<String,
                                                                dynamic>>.from(
                                                        roomsData);
                                                  for (int i = 0;
                                                      i < rlist.length;
                                                      i++) {
                                                    if (rlist[i]['room'] ==
                                                            widget
                                                                .libraryname &&
                                                        rlist[i]['code'] ==
                                                            widget
                                                                .entrancecode) {
                                                      var blist =
                                                          rlist[i]['booklist'];
                                                      for (int j = 0;
                                                          j < blist.length;
                                                          j++) {
                                                        if (blist[j]['name'] ==
                                                                issuedbookslist[
                                                                        index][
                                                                    'bookname'] &&
                                                            blist[j][
                                                                    'returndate'] ==
                                                                issuedbookslist[
                                                                        index][
                                                                    'returndate'] &&
                                                            blist[j]['uid'] ==
                                                                issuedbookslist[
                                                                        index]
                                                                    ['uid']) {
                                                          blist[j][
                                                                  'returndate'] =
                                                              null;
                                                          blist[j][
                                                                  'issuebyuid'] =
                                                              null;
                                                          rlist[i]['booklist'] =
                                                              blist;

                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .doc(widget
                                                                  .currentuseruid)
                                                              .collection(
                                                                  'rooms')
                                                              .doc(widget
                                                                  .currentuseruid)
                                                              .set({
                                                            'roomlist': rlist
                                                          });
                                                          break;
                                                        }
                                                      }
                                                      break;
                                                    }
                                                  }
                                                }
                                                {
                                                  //(generaldata) add null value in returndata general->all_users_rooms->rooms->returndate=null
                                                  DocumentSnapshot snapshot =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('general')
                                                          .doc(
                                                              'all_users_rooms')
                                                          .collection('rooms')
                                                          .doc(
                                                              '${widget.libraryname}${widget.entrancecode}')
                                                          .get();

                                                  var datageneral = snapshot
                                                          .data()
                                                      as Map<dynamic, dynamic>;
                                                  var bgenlist =
                                                      datageneral['roomdata']
                                                          ['booklist'];
                                                  for (int i = 0;
                                                      i < bgenlist.length;
                                                      i++) {
                                                    if (bgenlist[i]['name'] ==
                                                            issuedbookslist[
                                                                    index]
                                                                ['bookname'] &&
                                                        bgenlist[i][
                                                                'returndate'] ==
                                                            issuedbookslist[
                                                                    index][
                                                                'returndate'] &&
                                                        bgenlist[i]['uid'] ==
                                                            issuedbookslist[
                                                                index]['uid']) {
                                                      bgenlist[i]
                                                          ['returndate'] = null;
                                                      bgenlist[i]
                                                          ['issuebyuid'] = null;
                                                      datageneral['roomdata']
                                                              ['booklist'] =
                                                          bgenlist;

                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('general')
                                                          .doc(
                                                              'all_users_rooms')
                                                          .collection('rooms')
                                                          .doc(
                                                              '${widget.libraryname}${widget.entrancecode}')
                                                          .set({
                                                        'roomdata': datageneral[
                                                            'roomdata']
                                                      });
                                                      break;
                                                    }
                                                  }
                                                }

                                                //making history variable
                                                Map<dynamic, dynamic>
                                                    historydata =
                                                    Map<dynamic, dynamic>();

                                                historydata['issuedname'] =
                                                    widget.name;
                                                historydata['bookname'] =
                                                    book['bookname'];
                                                historydata['returnon'] =
                                                    DateFormat('dd-MM-yyyy')
                                                        .format(DateTime.now());

                                                {
                                                  String library_admin_uid;
                                                  //get the admin uid first
                                                  DocumentSnapshot snapshottmp =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('general')
                                                          .doc(
                                                              'all_users_rooms')
                                                          .collection('rooms')
                                                          .doc(
                                                              '${widget.libraryname}${widget.entrancecode}')
                                                          .get();
                                                  var data7 = snapshottmp.data()
                                                      as Map<dynamic, dynamic>;
                                                  library_admin_uid =
                                                      data7['roomdata']
                                                          ['admin'];
                                                  {
                                                    //add history of issued book in general

                                                    Map<dynamic, dynamic> data;
                                                    // Add your action on submit here
                                                    DocumentSnapshot snapshot =
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(
                                                                library_admin_uid)
                                                            .collection(
                                                                'history')
                                                            .doc(
                                                                '${widget.libraryname}${widget.entrancecode}')
                                                            .get();

                                                    if (snapshot.exists) {
                                                      var data = snapshot.data()
                                                          as Map<dynamic,
                                                              dynamic>;
                                                      List<
                                                              Map<dynamic,
                                                                  dynamic>>
                                                          historytemp = List<
                                                              Map<dynamic,
                                                                  dynamic>>.from(data[
                                                              'historylist']);

                                                      historytemp
                                                          .add(historydata);
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('users')
                                                          .doc(
                                                              library_admin_uid)
                                                          .collection('history')
                                                          .doc(
                                                              '${widget.libraryname}${widget.entrancecode}')
                                                          .set({
                                                        'historylist':
                                                            historytemp
                                                      });
                                                    } else {
                                                      List<
                                                              Map<dynamic,
                                                                  dynamic>>
                                                          historytemp = [];

                                                      historytemp
                                                          .add(historydata);
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('users')
                                                          .doc(
                                                              library_admin_uid)
                                                          .collection('history')
                                                          .doc(
                                                              '${widget.libraryname}${widget.entrancecode}')
                                                          .set({
                                                        'historylist':
                                                            historytemp
                                                      });
                                                    }
                                                  }
                                                }

                                                Navigator.pop(context);
                                                String bookname =
                                                    issuedbookslist[index]
                                                        ['bookname'] as String;
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            SummaryPage(
                                                                bookname:
                                                                    bookname)));

                                                print('Book returned!');
                                                setState(() {
                                                  issuedbookslist
                                                      .removeAt(index);
                                                });
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
                        ),
                      );
                    },
                  ),
                ),
              ),
      ],
    ));
  }
}
