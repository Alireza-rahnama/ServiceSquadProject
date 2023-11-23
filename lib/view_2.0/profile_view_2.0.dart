import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_squad/controller/profile_controller.dart';
import 'package:service_squad/view/category_selection.dart';
import 'package:service_squad/view_2.0/main_view.dart';

import '../model/user_profile_data.dart';
import '../view/auth_gate.dart';


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

void setUserLocation(String uid, String location) {
  FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .set({'userLocation': location}, SetOptions(merge: true));
}

void setMobileNumber(String uid, String mobileNumber) {
  FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .set({'mobileNumber': mobileNumber}, SetOptions(merge: true));
}

Future<String?> getUserLocation(String uid) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userSnapshot.exists) {
      // Check if the 'userType' field exists in the document
      if (userSnapshot.data()!.containsKey('userLocation')) {
        // Return the user type
        return userSnapshot.data()!['userLocation'];
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
  TextEditingController userTypeControleer = TextEditingController();
  TextEditingController userLocationController = TextEditingController();
  TextEditingController userAliasController = TextEditingController();
  TextEditingController userAboutController = TextEditingController();
  TextEditingController useremailAddressController = TextEditingController();
  TextEditingController mobilePhoneNumberController = TextEditingController();
  DropdownMenuExample dropdownMenu = DropdownMenuExample();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
        "My Profile",
        style: GoogleFonts.pacifico(
        color: Colors.white,
        fontSize: 30.0,))
        ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownMenuExample(),
                  ),
                  Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
              SizedBox(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: userLocationController,
                      decoration: InputDecoration(labelText: "Set your location"),
                    ),
                  ),
                  Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
              TextField(
                controller: userAliasController,
                decoration: InputDecoration(labelText: "Set your alias"),
              ),
              TextField(
                controller: userAboutController,
                decoration: InputDecoration(labelText: "About Me"),
              ),
              TextField(
                controller: useremailAddressController,
                decoration: InputDecoration(labelText: "Edit your email"),
              ),
              TextField(
                controller: mobilePhoneNumberController,
                decoration: InputDecoration(labelText: "Edit your number"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Save'),
                onPressed: () async {
                  setEmail(FirebaseAuth.instance.currentUser!.uid,
                      useremailAddressController.text);
                  setMobileNumber(FirebaseAuth.instance.currentUser!.uid,
                      mobilePhoneNumberController.text);
                  setUserLocation(FirebaseAuth.instance.currentUser!.uid,
                      userLocationController.text);
                  ProfileController().setTechnicianAlias(
                      FirebaseAuth.instance.currentUser!.uid,
                      userAliasController.text);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile info was successfully updated!'),
                      backgroundColor: Colors.deepPurple,
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Sign Out'),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AuthGate(),
                    ),
                  );
                },
              ),
              // Add any additional widgets you need
            ],
          ),
        ),
      ),
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
            selectedUserType = dropdownValue;
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