// room_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomService {
  // Function to get the room list from Firestore
  Future<Map<String, dynamic>?> fetchgeneralRoomList(
      String lname, String code) async {
    try {
      // Fetch the document snapshot from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('general')
          .doc('all_users_rooms')
          .collection('rooms')
          .doc('$lname$code')
          .get();

      // Extract data from the snapshot
      var datageneral = snapshot.data() as Map<dynamic, dynamic>;

      // Check if roomlist exists and return it, or return an empty list if null
      if (datageneral['roomdata'] != null) {
        return datageneral['roomdata'];
      } else {
        return null;
      }
    } catch (e) {
      // Handle any errors, like network issues
      print("Error fetching room list: $e");
      return null;
    }
  }
}
