import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:service_squad/view/category-selection.dart';

import '../model/professional_service.dart';
import 'drop_down_menu.dart';


// TODO iMPLEMENT THE UI  After user authentication is successful USER MUST COMPLETING THEIR PROFILE IN THIS VIEW AND WE COLLECT MORE DATA ,AND set their role in Firestore either associate or custome
// void setUserRole(String uid, String role) {
//   FirebaseFirestore.instance
//       .collection('users')
//       .doc(uid)
//       .set({'role': role}, SetOptions(merge: true));
// }
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
  // TextEditingController userTypeControleer = TextEditingController();
  TextEditingController userAboutController = TextEditingController();
  TextEditingController useremailAddressController = TextEditingController();
  TextEditingController mobilePhoneNumberController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
      title: Text('My Profile'),
      content: Column(children: [
        DropdownMenuExample(),
        TextField(
          controller: userAboutController,
          decoration: InputDecoration(labelText: "About Me"),
          maxLines: null, // Allows multiple lines of text.
        ),
        TextField(
          controller: useremailAddressController,
          decoration: InputDecoration(labelText: "Edit your email"),//TODO: ADD THE USER'S CURRENT EMAIL HERE
          maxLines: null, // Allows multiple lines of text.
        ),
        TextField(
          controller: mobilePhoneNumberController,
          decoration: InputDecoration(labelText: "Edit your number"),
          maxLines: null, // Allows multiple lines of text.
        ),
        SizedBox(height: 50),
        Text(
          'My Rating is '//TODO: implement logic
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
        // TextButton(
        //   child: Text('Save'),
        //   onPressed: () async {
        //     // Save the edited content to the diary entry.
        //     print("long pressed!");
        //     diaryController.updateDiary(
        //         diaryEntry.id,
        //         DiaryModel(
        //             description: descriptionEditingController.text,
        //             rating: int.parse(ratingEditingController.text),
        //             dateTime: DateTime.parse(dateEditingController.text),
        //             imagePath:
        //             await _uploadImageToFirebaseAndReturnDownlaodUrl(
        //                 diaryEntry.imagePath),
        //             id: diaryEntry.id));
        //
        //     updateState();
        //     Navigator.of(context).pop();
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(
        //           content: Center(child: Text('Entry successfully saved!')),
        //           backgroundColor: Colors.deepPurple),
        //     );
        //   },
        // ),
      ],
    );
  }
}
