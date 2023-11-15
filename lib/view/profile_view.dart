import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:service_squad/view/category_selection.dart';

import '../model/professional_service.dart';

// TODO iMPLEMENT THE UI  After user authentication is successful USERs MUST COMPLETe THEIR PROFILE IN THIS VIEW AND WE COLLECT MORE DATA ,AND set their role in Firestore either associate or custome
void setUserType(String uid, String userType) {
  FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .set({'userType': userType}, SetOptions(merge: true));
}

void setEmail(String uid, String email) {
  FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .set({'userEmail': email}, SetOptions(merge: true));
}

void setMobileNumber(String uid, String mobileNumber) {
  FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .set({'mobileNumber': mobileNumber}, SetOptions(merge: true));
}

Future<String?> getUserType(String uid) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userSnapshot.exists) {
      // Check if the 'userType' field exists in the document
      if (userSnapshot.data()!.containsKey('userType')) {
        // Return the user type
        return userSnapshot.data()!['userType'];
      }
    }

    // Return null if the user document or 'userType' field doesn't exist
    return null;
  } catch (e) {
    // Handle any errors that occur during the process
    print("Error getting user type: $e");
    return null;
  }
}
//TODO if the registration is completed then redirect to the category grid view
//TODO if the user is an associate when each grid is pressed pop up a new screen allowing to create a new posting of that category type

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // final String userType;
  // List<ProfessionalService>? listOfOfferingProfessionalServices;
  // var userAbout;
  // var userRating;
  // String emailAddress;
  // final mobilePhoneNumber;

  TextEditingController userTypeControleer = TextEditingController();
  TextEditingController userTypeController = TextEditingController();
  TextEditingController userAboutController = TextEditingController();
  TextEditingController useremailAddressController = TextEditingController();
  TextEditingController mobilePhoneNumberController = TextEditingController();
  DropdownMenuExample dropdownMenu = DropdownMenuExample();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('My Profile'),
      content: Column(children: [
        // Center(child:Text('Select your user type')),
        dropdownMenu,
        TextField(
          controller: userAboutController,
          decoration: InputDecoration(labelText: "About Me"),
          maxLines: null, // Allows multiple lines of text.
        ),
        TextField(
          controller: useremailAddressController,
          decoration: InputDecoration(labelText: "Edit your email"),
          //TODO: ADD THE USER'S CURRENT EMAIL HERE
          maxLines: null, // Allows multiple lines of text.
        ),
        TextField(
          controller: mobilePhoneNumberController,
          decoration: InputDecoration(labelText: "Edit your number"),
          maxLines: null, // Allows multiple lines of text.
        ),
        SizedBox(height: 50),
        Text('My Rating is ' //TODO: implement logic
            ),
        SizedBox(height: 10),
        // ElevatedButton(
        //   onPressed: () => _pickImageFromGallery(),
        //   child: Text('pick image from gallery'),
        // )
      ]),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            // Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategorySelection(),
              ),
            );
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () async {
            // Save the edited content to the diary entry.
            // diaryController.updateDiary(
            //     diaryEntry.id,
            //     DiaryModel(
            //         description: descriptionEditingController.text,
            //         rating: int.parse(ratingEditingController.text),
            //         dateTime: DateTime.parse(dateEditingController.text),
            //         imagePath:
            //         await _uploadImageToFirebaseAndReturnDownlaodUrl(
            //             diaryEntry.imagePath),
            //         id: diaryEntry.id));
            // updateState();
            setEmail(FirebaseAuth.instance.currentUser!.uid,useremailAddressController.text);
            setMobileNumber(FirebaseAuth.instance.currentUser!.uid, mobilePhoneNumberController.text);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Center(
                      child: Text('Profile info was successfully updated!')),
                  backgroundColor: Colors.deepPurple),
            );
          },
        ),
      ],
    );
  }
}

const List<String> list = <String>['Client', 'Service Associate'];

class DropdownMenuExample extends StatefulWidget {
  DropdownMenuExample({Key? key}) : super(key: key);
  late final dropDownValue;

  String get DropDownValue => dropDownValue;

  @override
  DropdownMenuExampleState createState() {
    DropdownMenuExampleState dropdownMenuExampleState =
        DropdownMenuExampleState();
    dropDownValue = dropdownMenuExampleState.dropdownValue;
    return dropdownMenuExampleState;
  }
}

class DropdownMenuExampleState extends State<DropdownMenuExample> {
  // String dropdownValue = list.first;
  String dropdownValue = 'Select an option';

  String get DropdownValue => dropdownValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
        value: dropdownValue,
        onChanged: (String? value) {
          setState(() {
            dropdownValue = value!;
            setUserType(FirebaseAuth.instance.currentUser!.uid, dropdownValue);
          });
        },
        items: [
          // Add an additional item for the initial text
          DropdownMenuItem<String>(
            value: 'Select an option',
            child: Text('Select an option'),
          ),
          ...list.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ]);
  }
}
