import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:minutes_summary/database/databasefun.dart';
import 'package:minutes_summary/pages/barcodescanner.dart';
import 'package:minutes_summary/pages/bookdetails.dart';
import 'package:intl/intl.dart';
import 'package:minutes_summary/pages/history.dart';
import 'package:minutes_summary/pages/userbookbasket.dart';
import 'package:provider/provider.dart';

final storage = FlutterSecureStorage();

class LibraryLobby extends StatefulWidget {
  const LibraryLobby(
      {super.key,
      required this.currentuseruid,
      required this.libraryname,
      required this.entrancecode,
      required this.name});
  final String currentuseruid, libraryname, entrancecode, name;

  @override
  State<LibraryLobby> createState() => _LibraryLobbyState();
}

class _LibraryLobbyState extends State<LibraryLobby> {
  Map<String, dynamic> roomingeneral = Map();
  final String apiKey = 'AIzaSyDgXM4zQTg2fyXSZRuZTdu8URwwOevH-Gg';

  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _books = []; // List to store book details
  List<dynamic> _filteredBooks = []; // Filtered books based on search
  // List<Map<dynamic, dynamic>> generalroomlist = [];
  Timer? _refreshTimer;
  RoomService roomfetch = RoomService();
  DateTime? _selectedReturnDate;
  @override
  void initState() {
    super.initState();

    _filteredBooks = _books; // Initially showing all books
    getbooklist();

    _refreshTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          // Optionally fetch new data
          //  _books = List<Map<String, dynamic>>.from(roomingeneral['booklist']);
          get_booksvar();
          // _filteredBooks = _books;
        });
      } else {
        timer.cancel();
      }
    });

    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          // Optionally fetch new data
          try {
            _books = List<Map<String, dynamic>>.from(roomingeneral['booklist']);
            _filteredBooks = _books;
          } on Exception catch (e) {
            // TODO
          }
          timer.cancel();
          // _filteredBooks = _books;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void showbookdetailsdialog(BuildContext context, double screenWidth,
      double screenHeight, int index, Map<String, dynamic> book) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          backgroundColor: Colors.grey[900], // Modern dark background

          content: Column(
            mainAxisSize: MainAxisSize.min, // Keep the dialog size minimal
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align text to the left
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        book['name'] != null
                            ? (book['name']!.length > 20
                                ? book['name']!.substring(0, 20) +
                                    '...' // Truncate to 50 characters
                                : book['name']!)
                            : 'Unknown Title',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow
                            .ellipsis, // Ensures overflow dots are added
                        style: TextStyle(
                          color: Colors.white, // Highlight the book title
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  widget.currentuseruid == roomingeneral['admin']
                      ? GestureDetector(
                          onTap: () {
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
                                          'Do you want to Delete this book?',
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
                                                var issueuidofbook;

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
                                                var rlist = [];
                                                var data = snapshot.data()
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
                                                          widget.libraryname &&
                                                      rlist[i]['code'] ==
                                                          widget.entrancecode) {
                                                    var blist =
                                                        rlist[i]['booklist'];
                                                    for (int i = 0;
                                                        i < blist.length;
                                                        i++) {
                                                      if (blist[i]['name'] ==
                                                              _filteredBooks[
                                                                      index]
                                                                  ['name'] &&
                                                          blist[i]['author'] ==
                                                              _filteredBooks[
                                                                      index]
                                                                  ['author'] &&
                                                          blist[i][
                                                                  'description'] ==
                                                              _filteredBooks[
                                                                      index][
                                                                  'description'] &&
                                                          blist[i]['genre'] ==
                                                              _filteredBooks[
                                                                      index]
                                                                  ['genre']) {
                                                        blist.removeAt(i);
                                                        for (int i = 0;
                                                            i < blist.length;
                                                            i++) {
                                                          print(
                                                              '()---${blist[i]['name']}---');
                                                        }
                                                        break;
                                                      }
                                                    }
                                                    rlist[i]['booklist'] =
                                                        blist;
                                                    print(
                                                        '====blist==> ${blist}');
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(widget
                                                            .currentuseruid)
                                                        .collection('rooms')
                                                        .doc(widget
                                                            .currentuseruid)
                                                        .set({
                                                      'roomlist': rlist
                                                    });
                                                    //delete from general
                                                    {
                                                      DocumentSnapshot
                                                          snapshot =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'general')
                                                              .doc(
                                                                  'all_users_rooms')
                                                              .collection(
                                                                  'rooms')
                                                              .doc(
                                                                  '${widget.libraryname}${widget.entrancecode}')
                                                              .get();

                                                      var datageneral =
                                                          snapshot.data()
                                                              as Map<dynamic,
                                                                  dynamic>;

                                                      var templist =
                                                          datageneral[
                                                                  'roomdata']
                                                              ['booklist'];
                                                      for (int i = 0;
                                                          i < templist.length;
                                                          i++) {
                                                        if (templist[i]['name'] ==
                                                                _filteredBooks[
                                                                        index]
                                                                    ['name'] &&
                                                            templist[i]['author'] ==
                                                                _filteredBooks[
                                                                        index][
                                                                    'author'] &&
                                                            templist[i][
                                                                    'description'] ==
                                                                _filteredBooks[
                                                                        index][
                                                                    'description'] &&
                                                            templist[i]
                                                                    ['genre'] ==
                                                                _filteredBooks[
                                                                        index]
                                                                    ['genre']) {
                                                          if (templist[i][
                                                                  'issuebyuid'] !=
                                                              null) {
                                                            //added issued uid of book from which we also have to delete issue book data from user
                                                            issueuidofbook =
                                                                templist[i][
                                                                    'issuebyuid'];
                                                          }
                                                          templist.removeAt(i);
                                                          break;
                                                        }
                                                      }

                                                      print(
                                                          '------datageneral[roomdata]----> ${datageneral['roomdata']['booklist']}');
                                                      datageneral['roomdata']
                                                              ['booklist'] =
                                                          templist;

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
                                                    }
                                                  }
                                                }

                                                {
                                                  // also delete data who has issued book users->books->...->issuebooklist->delete book
                                                  if (issueuidofbook != null) {
                                                    DocumentSnapshot snapshot =
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(issueuidofbook)
                                                            .collection('books')
                                                            .doc(
                                                                '${widget.libraryname}${widget.entrancecode}')
                                                            .get();
                                                    if (snapshot.exists) {
                                                      print(
                                                          '---->get the snapshot>>>00');
                                                      Map<dynamic, dynamic>
                                                          datatemp =
                                                          snapshot.data()
                                                              as Map<dynamic,
                                                                  dynamic>;
                                                      List<
                                                              Map<dynamic,
                                                                  dynamic>>
                                                          bookslist = [];
                                                      bookslist = List<
                                                              Map<dynamic,
                                                                  dynamic>>.from(
                                                          datatemp![
                                                              'issuedbookslist']);
                                                      print(
                                                          '---->get the filteredbook>> ${_filteredBooks[index]}  curent: $index');

                                                      for (int i = 0;
                                                          i < bookslist.length;
                                                          i++) {
                                                        if (bookslist[i][
                                                                    'bookname'] ==
                                                                _filteredBooks[
                                                                        index]
                                                                    ['name'] &&
                                                            bookslist[i][
                                                                    'returndate'] ==
                                                                _filteredBooks[
                                                                        index][
                                                                    'returndate'] &&
                                                            bookslist[i]
                                                                    ['uid'] ==
                                                                _filteredBooks[
                                                                        index][
                                                                    'issuebyuid']) {
                                                          bookslist.removeAt(i);
                                                          print(
                                                              '---->after delete booklist>> $bookslist');

                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .doc(
                                                                  issueuidofbook)
                                                              .collection(
                                                                  'books')
                                                              .doc(
                                                                  '${widget.libraryname}${widget.entrancecode}')
                                                              .set({
                                                            'issuedbookslist':
                                                                bookslist
                                                          });

                                                          break;
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                                for (int i = 0;
                                                    i < _books.length;
                                                    i++) {
                                                  if (_filteredBooks[index]
                                                              ['name'] ==
                                                          _books[i]['name'] &&
                                                      _filteredBooks[index]
                                                              ['author'] ==
                                                          _books[i]['author'] &&
                                                      _filteredBooks[index]
                                                              ['description'] ==
                                                          _books[i]
                                                              ['description'] &&
                                                      _filteredBooks[index]
                                                              ['genre'] ==
                                                          _books[i]['genre']) {
                                                    _books.removeAt(i);
                                                    // _filteredBooks.removeAt(index);
                                                    _filteredBooks = _books;
                                                    break;
                                                  }
                                                }
                                                getbooklist();
                                                _filterBooks();
                                                Navigator.pop(context);

                                                Navigator.pop(context);
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
                          child: Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                        )
                      : Container()
                ],
              ),
              Divider(
                color: Colors.grey[700], // Subtle divider
                thickness: 1,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.person_4, // Icon for author
                      color: Colors.orangeAccent),
                  SizedBox(width: 3),
                  Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    'Author:',
                    style: TextStyle(
                      color: Colors.orangeAccent, // Accent for author label
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.02),
                      child: Text(
                        book['author']!,
                        style: TextStyle(
                          color: Colors.grey[300], // Softer white for body text
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.library_books, // Icon for genre
                    color: Colors.orangeAccent,
                  ),
                  SizedBox(width: 8), // Space between icon and text
                  Text(
                    'Genre:',
                    style: TextStyle(
                      color: Colors.orangeAccent, // Accent for genre label
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.02),
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        book['genre']!,
                        style: TextStyle(
                          color: Colors.grey[300], // Softer white for body text
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _filteredBooks[index]['issuebyuid'] == null
                  ? Container()
                  : Column(
                      children: [
                        SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month, // Icon for genre
                                  color: Colors.orangeAccent,
                                ),
                                SizedBox(
                                    width: 8), // Space between icon and text
                                Text(
                                  'Return Date :',
                                  style: TextStyle(
                                    color: Colors
                                        .orangeAccent, // Accent for genre label
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: screenWidth * 0.02),
                                  child: Text(
                                    book['returndate']!,
                                    style: TextStyle(
                                      color: Colors.grey[
                                          300], // Softer white for body text
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
              _filteredBooks[index]['issuebyuid'] == null
                  ? Container()
                  : Column(
                      children: [
                        SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.book, // Icon for genre
                                  color: Colors.orangeAccent,
                                ),
                                SizedBox(
                                    width: 8), // Space between icon and text
                                Text(
                                  'Issued By:',
                                  style: TextStyle(
                                    color: Colors
                                        .orangeAccent, // Accent for genre label
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: screenWidth * 0.02),
                                  child: Text(
                                    book['issuedname'] ?? '*Refresh the Page*',
                                    style: TextStyle(
                                      color: Colors.grey[
                                          300], // Softer white for body text
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
            ],
          ),

          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      screenWidth * 0.02, 0, screenWidth * 0.02, 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 1, 167, 15), // Modern button color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Rounded button
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.2,
                          vertical: screenHeight * 0.002),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BookDetailsPage(
                                    book: book,
                                  )));
                    },
                    child: Text(
                      'Full Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _filteredBooks[index]['issuebyuid'] == null
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(
                            screenWidth * 0.02, 0, screenWidth * 0.02, 0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                                255, 8, 144, 223), // Modern button color
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // Rounded button
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.2,
                                vertical: screenHeight * 0.002),
                          ),
                          onPressed: () {
                            _showIssueBookDialog(index);
                          },
                          child: Text(
                            'Issue Book',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> getbooklist() async {
    try {
      //fetching the librarry or room from function which is in databasefun.dart file
      roomingeneral = await roomfetch.fetchgeneralRoomList(
          widget.libraryname, widget.entrancecode) as Map<String, dynamic>;
      setState(() {
        _books = roomingeneral['booklist'];
        _filteredBooks = _books;
        print('-------->_books >> $_books');
      });
      // print('-----_books---$_books');
    } catch (e) {
      print("Error fetching room list: $e");
    }
  }

  Future<List<dynamic>> get_booksvar() async {
    // Simulate a delay or data fetching
    // await Future.delayed(const Duration(seconds: 1));
    return _books;
  }

  /* Future<List<Map<String, dynamic>>> fetchdata() async {
    /*  roomingeneral = await roomfetch.fetchgeneralRoomList(
        widget.libraryname, widget.entrancecode) as Map<String, dynamic>;

    _books = List<Map<String, dynamic>>.from(roomingeneral['booklist']);

    _filterBooks(); */

    //   print('----------FETCHING THE DATA -----------');
    // _filteredBooks = _books;
    return _filteredBooks;
  } */

  Future<void> _showIssueBookDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF5F5F5), // Whitish background
          title: Text(
            'Issue Book',
            style:
                TextStyle(color: Color(0xFF333333)), // Slightly dark grey title
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Select a return date:',
                  style:
                      TextStyle(color: Color(0xFF666666)), // Medium grey text
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(Duration(days: 14)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 60)),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Color(0xFF0072C6), // Blue primary color
                              onPrimary: Colors.white,
                              surface: Color(0xFFF5F5F5), // Whitish surface
                              onSurface:
                                  Color(0xFF333333), // Slightly dark grey text
                            ),
                            dialogBackgroundColor:
                                Color(0xFFF5F5F5), // Whitish dialog background
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (selectedDate != null) {
                      _selectedReturnDate = selectedDate;
                      List<Map<String, dynamic>>? rlist = [];
                      Map<dynamic, dynamic> data;
                      // Add your action on submit here
                      DocumentSnapshot snapshot = await FirebaseFirestore
                          .instance
                          .collection('users')
                          .doc(widget.currentuseruid)
                          .collection('rooms')
                          .doc(widget.currentuseruid)
                          .get();

                      data = snapshot.data() as Map<dynamic, dynamic>;

                      //  print('----roomlist data ---> $data');

                      var roomsData = data['roomlist'];
                      if (roomsData != null)
                        rlist = List<Map<String, dynamic>>.from(roomsData);
                      for (int i = 0; i < rlist.length; i++) {
                        if (rlist[i]['room'] == widget.libraryname &&
                            rlist[i]['code'] == widget.entrancecode) {
                          var blist = rlist[i]['booklist'];
                          blist[index]['issuebyuid'] = widget.currentuseruid;
                          blist[index]['returndate'] =
                              '${_selectedReturnDate!.day}/${_selectedReturnDate!.month}/${_selectedReturnDate!.year}';
                          rlist[i]['booklist'] = blist;

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.currentuseruid)
                              .collection('rooms')
                              .doc(widget.currentuseruid)
                              .set({'roomlist': rlist});

                          //update in general room
                          {
                            DocumentSnapshot snapshot = await FirebaseFirestore
                                .instance
                                .collection('general')
                                .doc('all_users_rooms')
                                .collection('rooms')
                                .doc(
                                    '${widget.libraryname}${widget.entrancecode}')
                                .get();

                            var datageneral =
                                snapshot.data() as Map<dynamic, dynamic>;

                            datageneral['roomdata']['booklist'][index]
                                ['issuedname'] = widget.name;
                            datageneral['roomdata']['booklist'][index]
                                ['issuebyuid'] = widget.currentuseruid;

                            datageneral['roomdata']['booklist'][index]
                                    ['returndate'] =
                                '${_selectedReturnDate!.day}/${_selectedReturnDate!.month}/${_selectedReturnDate!.year}';
                            print(
                                '------datageneral[roomdata]----> ${datageneral['roomdata']['booklist'][index]}');

                            await FirebaseFirestore.instance
                                .collection('general')
                                .doc('all_users_rooms')
                                .collection('rooms')
                                .doc(
                                    '${widget.libraryname}${widget.entrancecode}')
                                .set({'roomdata': datageneral['roomdata']});
                          }
                          {
                            {
                              //add issued books in user database
                              DocumentSnapshot snapshot = await FirebaseFirestore
                                  .instance
                                  .collection('users')
                                  .doc(widget.currentuseruid)
                                  .collection('books')
                                  .doc(
                                      '${widget.libraryname}${widget.entrancecode}')
                                  .get();
                              if (snapshot.exists) {
                                Map<dynamic, dynamic> datatemp =
                                    snapshot.data() as Map<dynamic, dynamic>;
                                List<Map<dynamic, dynamic>> issuedbookslist =
                                    [];
                                issuedbookslist =
                                    List<Map<dynamic, dynamic>>.from(
                                        datatemp!['issuedbookslist']);
                                Map<dynamic, dynamic> tempdata =
                                    Map<dynamic, dynamic>();
                                tempdata['issuedname'] = widget.name;
                                tempdata['bookname'] =
                                    _filteredBooks[index]['name'];
                                tempdata['returndate'] =
                                    '${_selectedReturnDate!.day}/${_selectedReturnDate!.month}/${_selectedReturnDate!.year}';
                                tempdata['uid'] = widget.currentuseruid;
                                _selectedReturnDate = null;

                                issuedbookslist.add(tempdata);

                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.currentuseruid)
                                    .collection('books')
                                    .doc(
                                        '${widget.libraryname}${widget.entrancecode}')
                                    .set({'issuedbookslist': issuedbookslist});
                              } else {
                                List<Map<dynamic, dynamic>> issuedbookslist =
                                    [];
                                Map<dynamic, dynamic> tempdata =
                                    Map<dynamic, dynamic>();
                                tempdata['issuedname'] = widget.name;
                                tempdata['bookname'] =
                                    _filteredBooks[index]['name'];
                                tempdata['returndate'] =
                                    '${_selectedReturnDate!.day}/${_selectedReturnDate!.month}/${_selectedReturnDate!.year}';
                                tempdata['uid'] = widget.currentuseruid;

                                print('----datetime---- $_selectedReturnDate');
                                _selectedReturnDate = null;
                                issuedbookslist.add(tempdata);

                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.currentuseruid)
                                    .collection('books')
                                    .doc(
                                        '${widget.libraryname}${widget.entrancecode}')
                                    .set({'issuedbookslist': issuedbookslist});
                              }
                            }
                          }
                          break;
                        }
                      }
                    }

                    DocumentSnapshot snapshot = await FirebaseFirestore.instance
                        .collection('general')
                        .doc('all_users_rooms')
                        .collection('rooms')
                        .doc('${widget.libraryname}${widget.entrancecode}')
                        .get();

                    // Extract data from the snapshot
                    var datageneral = snapshot.data() as Map<dynamic, dynamic>;
                    //fetching the librarry or room from function which is in databasefun.dart file
                    roomingeneral = await roomfetch.fetchgeneralRoomList(
                            widget.libraryname, widget.entrancecode)
                        as Map<String, dynamic>;
                    print('--------roomingeneral----$roomingeneral');
                    _books.clear();
                    for (int i = 0; i < roomingeneral['booklist'].length; i++) {
                      _books.add({
                        'author': roomingeneral['booklist'][i]['author'],
                        'description': roomingeneral['booklist'][i]
                            ['description'],
                        'genre': roomingeneral['booklist'][i]['genre'],
                        'issuebyuid': roomingeneral['booklist'][i]
                            ['issuebyuid'],
                        'name': roomingeneral['booklist'][i]['name'],
                        'returndate': roomingeneral['booklist'][i]['returndate']
                      });
                    }
                    // _books = roomingeneral['booklist'];
                    print('---//////////////--_books---$_books');

                    final query = _searchController.text.toLowerCase();
                    setState(() {
                      _filteredBooks = _books
                          .where((book) =>
                              book['name']!.toLowerCase().contains(query))
                          .toList();
                    });

                    getbooklist();
                    getbooklist();
                    getbooklist();
                    _filterBooks();
                    _filterBooks();
                    _filterBooks();

                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: Color(0xFF666666)), // Medium grey icon
                      SizedBox(width: 8),
                      Text(
                        _selectedReturnDate != null
                            ? '${_selectedReturnDate!.day}/${_selectedReturnDate!.month}/${_selectedReturnDate!.year}'
                            : 'Select a date',
                        style: TextStyle(
                            color: Color(0xFF666666)), // Medium grey text
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style:
                    TextStyle(color: Color(0xFF0072C6)), // Blue cancel button
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            /*  ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0072C6), // Blue button
                foregroundColor: Colors.white,
              ),
              child: Text('Issue'),
              onPressed: () {
                if (_selectedReturnDate != null) {
                  // Perform book issue logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Book issued successfully! Return date: ${_selectedReturnDate!.month}/${_selectedReturnDate!.day}/${_selectedReturnDate!.year}'),
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  // Show an error if no return date is selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a return date')),
                  );
                }
              },
            ), */
          ],
        );
      },
    );
  }

  final _formKey = GlobalKey<FormState>();
  // Function to show the dialog box for adding a book with custom theme
  void _showAddBookDialog() {
    String bookName = '';
    String bookDescription = '';
    String bookauthor = '';
    String bookgenre = '';

    // final bookDetails = Provider.of<BookDetailsProvider>(context,listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight,
                ),
                child: Dialog(
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
                          // Title Text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Add Book',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BarcodeScannerPage(
                                                libraryname: widget.libraryname,
                                                entrancecode:
                                                    widget.entrancecode,
                                                name: widget.name,
                                                currentuseruid:
                                                    widget.currentuseruid,
                                              )));
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.barcode_reader,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 20),

                          // Form with validation
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Book Name Input
                                TextFormField(
                                  onChanged: (value) => bookName = value,
                                  decoration: InputDecoration(
                                    hintText: 'Book Name',
                                    hintStyle: TextStyle(color: Colors.white70),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[800],
                                  ),
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Book Name cannot be empty';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),

                                // Book Description Input
                                TextFormField(
                                  onChanged: (value) => bookDescription = value,
                                  decoration: InputDecoration(
                                    hintText: 'Book Description',
                                    hintStyle: TextStyle(color: Colors.white70),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[800],
                                  ),
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Book Description cannot be empty';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),

                                // Author Name and Genre Input
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        onChanged: (value) =>
                                            bookauthor = value,
                                        decoration: InputDecoration(
                                          hintText: 'Author',
                                          hintStyle:
                                              TextStyle(color: Colors.white70),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[800],
                                        ),
                                        style: TextStyle(color: Colors.white),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'can\'t be empty';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        onChanged: (value) => bookgenre = value,
                                        decoration: InputDecoration(
                                          hintText: 'Genre',
                                          hintStyle:
                                              TextStyle(color: Colors.white70),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[800],
                                        ),
                                        style: TextStyle(color: Colors.white),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'can\'t be empty';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),

                          // Buttons: Cancel and Add
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 121, 107, 247),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _books.add({
                                        'name': bookName,
                                        'description': bookDescription,
                                        'author': bookauthor,
                                        'genre': bookgenre
                                      });
                                      _filteredBooks = _books;
                                    });

                                    // Update Firestore
                                    roomingeneral['booklist'] = _books;
                                    await FirebaseFirestore.instance
                                        .collection('general')
                                        .doc('all_users_rooms')
                                        .collection('rooms')
                                        .doc(
                                            '${widget.libraryname}${widget.entrancecode}')
                                        .set({'roomdata': roomingeneral});

                                    DocumentSnapshot snapshot =
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(widget.currentuseruid)
                                            .collection('rooms')
                                            .doc(widget.currentuseruid)
                                            .get();

                                    Map<dynamic, dynamic> data = snapshot.data()
                                        as Map<dynamic, dynamic>;
                                    List<Map<String, dynamic>>? rlist = [];
                                    var roomsData = data['roomlist'];

                                    if (roomsData != null) {
                                      rlist = List<Map<String, dynamic>>.from(
                                          roomsData);
                                    }

                                    if (snapshot.exists) {
                                      for (int i = 0; i < rlist.length; i++) {
                                        if (rlist[i]['room'] ==
                                                widget.libraryname &&
                                            rlist[i]['code'] ==
                                                widget.entrancecode) {
                                          rlist[i]['booklist'] = _books;
                                        }
                                      }

                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.currentuseruid)
                                          .collection('rooms')
                                          .doc(widget.currentuseruid)
                                          .set({'roomlist': rlist});
                                    }
                                    Navigator.of(context).pop();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Please fill all fields correctly.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: Text('Add'),
                              ),
                            ],
                          ),
                        ],
                      )),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Function to filter the books based on search input
  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = _books
          .where((book) =>
              book['name']!.toLowerCase().contains(query) ||
              book['author']!.toLowerCase().contains(query) ||
              book['genre']!.toLowerCase().contains(query))
          .toList();
    });
  }

  final Stream<List<String>> _dataStream = (() {
    // Mocking a stream that emits a list of items every 5 seconds
    final controller = StreamController<List<String>>();
    Timer.periodic(Duration(seconds: 5), (timer) {
      // controller.add();
    });
    return controller.stream;
  })();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        actions: [
          widget.currentuseruid == roomingeneral['admin']
              ? Padding(
                  padding: EdgeInsets.fromLTRB(
                      screenWidth * 0.1, 0, screenWidth * 0.0, 0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => History(
                                    name: widget.name,
                                    currentuseruid: widget.currentuseruid,
                                    libraryname: widget.libraryname,
                                    entrancecode: widget.entrancecode,
                                  )));
                    },
                    child: Icon(
                      Icons.assignment_ind,
                      size: screenHeight * 0.035,
                    ),
                  ),
                )
              : Container(),
          Padding(
            padding: EdgeInsets.fromLTRB(
                screenWidth * 0.04, 0, screenWidth * 0.08, 0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BookbucketListPage(
                            currentuseruid: '${widget.currentuseruid}',
                            libraryname: widget.libraryname,
                            entrancecode: widget.entrancecode,
                            name: widget.name)));
              },
              child: Icon(
                Icons.book_rounded,
                size: screenHeight * 0.035,
              ),
            ),
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0, // Flat app bar
        title: Text(
          '${widget.libraryname} ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Map<dynamic, dynamic>>>(
          future: null, // _dataStream,
          builder: (context, snapshot) {
            return RefreshIndicator(
              onRefresh: getbooklist,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors
                            .grey[400], // Darker gray for better visibility
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            _filterBooks(), // Filter books as the user types
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(color: Colors.black54),
                          prefixIcon: Icon(Icons.search, color: Colors.black54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Grid View
                    _filteredBooks.length == 0
                        ? Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding:
                                    EdgeInsets.only(top: screenHeight * 0.37),
                                child: Center(
                                  child: Text('No Books Added'),
                                ),
                              ),
                            ),
                          )
                        : Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 17,
                                mainAxisSpacing: 13,
                                childAspectRatio: 150 / 200,
                              ),
                              itemCount: _filteredBooks.length,
                              itemBuilder: (context, index) {
                                final book = _filteredBooks[index];

                                return book['thumbnail'] != null &&
                                        book['thumbnail'].isNotEmpty &&
                                        book['thumbnail'] !=
                                            'https://via.placeholder.com/150'
                                    ? Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              showbookdetailsdialog(
                                                  context,
                                                  screenWidth,
                                                  screenHeight,
                                                  index,
                                                  book);
                                            },
                                            child: Container(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.network(
                                                  book['thumbnail'],
                                                  height: 150,
                                                  width: 100,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          ),
                                          _filteredBooks[index]['issuebyuid'] ==
                                                  null
                                              ? Container()
                                              : Stack(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              screenWidth *
                                                                  0.12,
                                                              screenHeight *
                                                                  0.0,
                                                              0,
                                                              0),
                                                      child: Container(
                                                        width:
                                                            screenWidth * 0.19,
                                                        height:
                                                            screenWidth * 0.07,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.green
                                                                  .withOpacity(
                                                                      1), // Bottom color
                                                              Colors.green
                                                                  .withOpacity(
                                                                      1), // Top transparent color
                                                            ],
                                                            begin: Alignment
                                                                .bottomCenter,
                                                            end: Alignment
                                                                .topCenter,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                screenWidth *
                                                                    0.145,
                                                                screenHeight *
                                                                    0.002,
                                                                0,
                                                                0),
                                                        child: Text(
                                                          'Issued',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )),
                                                  ],
                                                ),
                                        ],
                                      )
                                    : Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              // Show a dialog with book description on tap

                                              showbookdetailsdialog(
                                                  context,
                                                  screenWidth,
                                                  screenHeight,
                                                  index,
                                                  book);
                                            },
                                            child: Container(
                                              height: screenHeight * 0.6,
                                              width: screenWidth * 0.25,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[
                                                    400], // Darker gray for visibility
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 5,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  book['name']!,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                          _filteredBooks[index]['issuebyuid'] ==
                                                  null
                                              ? Container()
                                              : Stack(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              screenWidth *
                                                                  0.12,
                                                              screenHeight *
                                                                  0.0,
                                                              0,
                                                              0),
                                                      child: Container(
                                                        width:
                                                            screenWidth * 0.19,
                                                        height:
                                                            screenWidth * 0.07,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.green
                                                                  .withOpacity(
                                                                      1), // Bottom color
                                                              Colors.green
                                                                  .withOpacity(
                                                                      0.1), // Top transparent color
                                                            ],
                                                            begin: Alignment
                                                                .bottomCenter,
                                                            end: Alignment
                                                                .topCenter,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                screenWidth *
                                                                    0.145,
                                                                screenHeight *
                                                                    0.002,
                                                                0,
                                                                0),
                                                        child: Text(
                                                          'Issued',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )),
                                                  ],
                                                ),
                                        ],
                                      );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: widget.currentuseruid == roomingeneral['admin']
          ? Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: FloatingActionButton(
                onPressed: _showAddBookDialog, // Show the add book dialog
                child: Icon(Icons.add, color: Colors.white),
                backgroundColor: Colors.black87,
              ),
            )
          : Container(),
    );
  }
}
