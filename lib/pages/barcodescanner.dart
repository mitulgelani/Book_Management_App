import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:minutes_summary/database/databasefun.dart';
import 'package:minutes_summary/pages/librarylobby.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final storage = FlutterSecureStorage();

class BarcodeScannerPage extends StatefulWidget {
  final String libraryname;
  final String entrancecode;
  final String currentuseruid;
  final String name;

  const BarcodeScannerPage({
    super.key,
    required this.currentuseruid,
    required this.libraryname,
    required this.entrancecode,
    required this.name,
  });

  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  String _barcodeScanResult = '';
  String _bookName = '';
  String _authorName = '';
  String _description = '';
  String _genre = '';
  String _thumbnailUrl = '';
  bool onetimeuseflag = true;

  final String apiKey =
      'AIzaSyDgXM4zQTg2fyXSZRuZTdu8URwwOevH-Gg'; // Replace with your API key

  @override
  void initState() {
    super.initState();
    onetimeuseflag = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Barcode Scanner
            Container(
              height: 400,
              width: double.infinity,
              child: MobileScanner(
                controller: MobileScannerController(
                  detectionSpeed: DetectionSpeed.normal,
                  facing: CameraFacing.back,
                ),
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;

                  setState(() {
                    _barcodeScanResult = barcodes.first.rawValue ?? 'No result';
                  });
                  if (onetimeuseflag) _fetchBookDetails(_barcodeScanResult);
                },
              ),
            ),

            // Display Scanned Result
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scanned Barcode: $_barcodeScanResult',
                    style: TextStyle(fontSize: 18),
                  ),
                  if (_thumbnailUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Image.network(
                        _thumbnailUrl,
                        height: 200,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (_bookName.isNotEmpty)
                    Text(
                      'Book Name: $_bookName',
                      style: TextStyle(fontSize: 16),
                    ),
                  if (_authorName.isNotEmpty)
                    Text(
                      'Author Name: $_authorName',
                      style: TextStyle(fontSize: 16),
                    ),
                  if (_description.isNotEmpty)
                    Text(
                      'Description: $_description',
                      style: TextStyle(fontSize: 16),
                    ),
                  if (_genre.isNotEmpty)
                    Text(
                      'Genre: $_genre',
                      style: TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fetchBookDetails(String barcode) async {
    if (onetimeuseflag) {
      onetimeuseflag = false;
      final url =
          'https://www.googleapis.com/books/v1/volumes?q=isbn:$barcode&key=$apiKey';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final dataj = json.decode(response.body);

          if (dataj['items'] != null && dataj['items'].isNotEmpty) {
            final book = dataj['items'][0]['volumeInfo'];

            setState(() {
              _bookName = book['title'] ?? 'Unknown';
              _authorName =
                  book['authors'] != null && book['authors'].isNotEmpty
                      ? book['authors'][0]
                      : 'Unknown';
              _description = book['description'] ?? 'No description available';
              _genre =
                  book['categories'] != null && book['categories'].isNotEmpty
                      ? book['categories'][0]
                      : 'Unknown';
              _thumbnailUrl = book['imageLinks']?['thumbnail'] ??
                  'https://via.placeholder.com/150';
            });

            //updatte the data on firbase storage
            List<dynamic> _books = [];
            Map<String, dynamic> roomingeneral = Map();
            {
              //get the booklist first
              try {
                RoomService roomfetch = RoomService();

                //fetching the librarry or room from function which is in databasefun.dart file
                roomingeneral = await roomfetch.fetchgeneralRoomList(
                        widget.libraryname, widget.entrancecode)
                    as Map<String, dynamic>;
                setState(() {
                  _books = roomingeneral['booklist'];
                });
                // print('-----_books---$_books');
              } catch (e) {
                print("Error fetching room list: $e");
              }
            }

            setState(() {
              _books.add({
                'name': _bookName,
                'description': _description,
                'author': _authorName,
                'genre': _genre,
                'thumbnail': _thumbnailUrl,
              });
            });

            // Update Firestore
            roomingeneral['booklist'] = _books;
            await FirebaseFirestore.instance
                .collection('general')
                .doc('all_users_rooms')
                .collection('rooms')
                .doc('${widget.libraryname}${widget.entrancecode}')
                .set({'roomdata': roomingeneral});

            DocumentSnapshot snapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(widget.currentuseruid)
                .collection('rooms')
                .doc(widget.currentuseruid)
                .get();

            Map<dynamic, dynamic> data =
                snapshot.data() as Map<dynamic, dynamic>;
            List<Map<String, dynamic>>? rlist = [];
            var roomsData = data['roomlist'];

            if (roomsData != null) {
              rlist = List<Map<String, dynamic>>.from(roomsData);
            }

            if (snapshot.exists) {
              for (int i = 0; i < rlist.length; i++) {
                if (rlist[i]['room'] == widget.libraryname &&
                    rlist[i]['code'] == widget.entrancecode) {
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

            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => LibraryLobby(
                          libraryname: widget.libraryname,
                          entrancecode: widget.entrancecode,
                          currentuseruid: widget.currentuseruid,
                          name: widget.name,
                        )));
            // Close the camera and pop the screen
          } else {
            debugPrint('No book found for this barcode');
          }
        } else {
          debugPrint('Failed to fetch book details from Google Books API');
        }
      } catch (e) {
        debugPrint('Error fetching book details: $e');
      }
    }
  }
}
/*   Future<void> _updateFirestore() async {
    try {
      // Fetch existing room data
      final roomRef = FirebaseFirestore.instance
          .collection('general')
          .doc('all_users_rooms')
          .collection('rooms')
          .doc('${widget.libraryname}${widget.entrancecode}');

      final roomSnap = await roomRef.get();
      Map<String, dynamic> roomData =
          roomSnap.exists ? roomSnap.data()! : {'booklist': []};

      // Update booklist
      List<dynamic> booklist = roomData['booklist'] ?? [];
      booklist.add({
        'name': _bookName,
        'description': _description,
        'author': _authorName,
        'genre': _genre,
        'thumbnail': _thumbnailUrl,
      });

      roomData['booklist'] = booklist;
      await roomRef.set(roomData);

      // Update user's room data
      final userRoomRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentuseruid)
          .collection('rooms')
          .doc(widget.currentuseruid);

      final userRoomSnap = await userRoomRef.get();
      List<dynamic> userRooms =
          userRoomSnap.exists ? userRoomSnap.data()!['roomlist'] ?? [] : [];

      for (var room in userRooms) {
        if (room['room'] == widget.libraryname &&
            room['code'] == widget.entrancecode) {
          room['booklist'] = booklist;
          break;
        }
      }

      await userRoomRef.set({'roomlist': userRooms});

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LibraryLobby(
            libraryname: widget.libraryname,
            entrancecode: widget.entrancecode,
            currentuseruid: widget.currentuseruid,
            name: widget.name,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error updating Firestore: $e');
    }
  }
}
 */
/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:minutes_summary/database/databasefun.dart';
import 'package:minutes_summary/pages/librarylobby.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final storage = FlutterSecureStorage();

class BarcodeScannerPage extends StatefulWidget {
  final String libraryname;
  final String entrancecode;
  final String currentuseruid;
  final String name;
  const BarcodeScannerPage(
      {super.key,
      required this.currentuseruid,
      required this.libraryname,
      required this.entrancecode,
      required this.name});
  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  String _barcodeScanResult = '';
  String _bookName = '';
  String _authorName = '';
  String _description = '';
  String _genre = '';
  bool onetimeuseflag = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onetimeuseflag = true;
  }

  final String apiKey =
      'AIzaSyDgXM4zQTg2fyXSZRuZTdu8URwwOevH-Gg'; // Replace with your API key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Barcode Scanner
            Container(
              height: 400,
              width: double.infinity,
              child: MobileScanner(
                controller: MobileScannerController(
                  detectionSpeed: DetectionSpeed.normal,
                  facing: CameraFacing.back,
                ),
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;

                  setState(() {
                    _barcodeScanResult = barcodes.first.rawValue ?? 'No result';
                  });
                  onetimeuseflag == true
                      ? _fetchBookDetails(_barcodeScanResult)
                      : '';
                },
              ),
            ),

            // Display Scanned Result
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scanned Barcode: $_barcodeScanResult',
                    style: TextStyle(fontSize: 18),
                  ),
                  if (_bookName.isNotEmpty)
                    Text(
                      'Book Name: $_bookName',
                      style: TextStyle(fontSize: 16),
                    ),
                  if (_authorName.isNotEmpty)
                    Text(
                      'Author Name: $_authorName',
                      style: TextStyle(fontSize: 16),
                    ),
                  if (_description.isNotEmpty)
                    Text(
                      'Description: $_description',
                      style: TextStyle(fontSize: 16),
                    ),
                  if (_genre.isNotEmpty)
                    Text(
                      'Genre: $_genre',
                      style: TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fetchBookDetails(String barcode) async {
   
  }
}
*/