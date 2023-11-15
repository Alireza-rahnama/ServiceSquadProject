import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileController{
  Future<String?> getUserType(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {

        // Check if the 'userType' field exists in the document
        if (userSnapshot.data()!.containsKey('userType')) {
          // Return the user type
          print('userSnapshot.data()!["userType"]: ${userSnapshot.data()!['userType']}');
          return userSnapshot.data()!['userType'];
        }
      }
      print("userType is: ${userSnapshot.data()!['userType']}");

      // Return null if the user document or 'userType' field doesn't exist
      return null;
    } catch (e) {
      // Handle any errors that occur during the process
      print("Error getting user type: $e");
      return null;
    }
  }

  void setUserType(String uid, String userType) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'userType': userType}, SetOptions(merge: true));
  }
}