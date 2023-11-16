import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../controller/professional_service_controller.dart';
import '../model/professional_service.dart';
import 'services_list_view.dart';

class ServiceEntryView extends StatefulWidget {
  bool isDark;
  String category;

  ServiceEntryView.withInheritedTheme(this.isDark, this.category);


  @override
  // _NewEntryViewState createState() => _NewEntryViewState();
  _NewEntryViewState createState() =>
      _NewEntryViewState.withInheritedThemeAndCategory(isDark, category);
}

class _NewEntryViewState extends State<ServiceEntryView> {
  late final TextEditingController descriptionController;
  late final TextEditingController categoryController ;
  late final TextEditingController wageController;

  double? wage;
  double rating = 5.0; // Initial rating value
  late String serviceDescription;
  late String category;
  String? imagePath;
  List<String?> imagePathList = [];
  var professionalServiceController = ProfessionalServiceController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  late bool isDark;

  _NewEntryViewState.withInheritedThemeAndCategory(bool isDark, String category) {
    this.isDark = isDark;
    this.category = category;
    descriptionController = TextEditingController();
    categoryController = TextEditingController(text: '${category}');
    wageController = TextEditingController();
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  Future<String?> _uploadImageToFirebaseAndReturnDownlaodUrl() async {
    if (_image == null) return null;
    String? downloadURL = null;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('images/${currentUser.uid}/${_image!.name}');

    try {
      final uploadTask = await firebaseStorageRef.putFile(File(_image!.path));
      if (uploadTask.state == TaskState.success) {
        downloadURL = await firebaseStorageRef.getDownloadURL();

        print("Uploaded to: $downloadURL");
      }
    } catch (e) {
      print("Failed to upload image: $e");
    }
    return downloadURL;
  }

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //   );
  //
  //   if (picked != null && picked != selectedDate)
  //     setState(() {
  //       selectedDate = picked;
  //     });
  // }

  void _saveServiceEntry() async {
    serviceDescription = descriptionController.text;
    category = categoryController.text;
    wage = double.parse(wageController.text);

    imagePath = await _uploadImageToFirebaseAndReturnDownlaodUrl();
    imagePathList.add(imagePath);

    if (serviceDescription == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Center(
                child: Text('Description can not be left empty!',
                    style: TextStyle(
                      color: Colors.white, // Customize the hint text color
                      fontSize: 12, // Customize the hint text font size
                    ))),
            backgroundColor: Colors.deepPurple),
      );
      return;
    }

    ProfessionalService professionalService = ProfessionalService(
        category: categoryController.text,
        serviceDescription: serviceDescription,
        wage: double.parse(wageController.text),
        rating: 5);

    bool successfullyAdded = await professionalServiceController
        .addProfessionalService(professionalService);

    descriptionController.clear();
    print('rating is: $rating');
    try {
      if (successfullyAdded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Center(
                  child: Text('Entry successfully saved!',
                      style: TextStyle(
                        color: Colors.white, // Customize the hint text color
                        fontSize: 12, // Customize the hint text font size
                      ))),
              backgroundColor: Colors.deepPurple),
        );
        print('isDark in diary entry view is: $isDark');
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CategoriesView.WithPersistedThemeAndCategory(
                      isDark, category),
            ));
      } else if (!successfullyAdded) {
        // Show the error dialog when the button is pressed
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog();
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Unexpected error ocured: $e'),
            backgroundColor: Colors.deepPurple),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light);

    return Theme(
        data: themeData,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepPurple,
            title: Text("Add Diary Entry",
                style: GoogleFonts.pacifico(
                  color: isDark ? Colors.black87 : Colors.white,
                  fontSize: 30.0,
                )),
            leading: IconButton(
                icon: Icon(Icons.arrow_back_outlined),
                tooltip: 'Go back',
                color: isDark ? Colors.black87 : Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => DiaryLogView()),
                  // );
                }),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    labelText: '${category}',
                    hintText:
                        'Enter your service category', //TODO: BETTER MAKE IT A DROP DOWN OR RADIO BUTTON
                  ),
                  maxLength: 50, // Set the maximum character limit
                  maxLines: null, // Allow multiple lines of text
                ),
                Text('Enter your service category',
                    style: TextStyle(
                      color: Colors.grey, // Customize the hint text color
                      fontSize: 12, // Customize the hint text font size
                    )),
                SizedBox(height: 20),
                TextField(
                  controller: wageController,
                  decoration: InputDecoration(
                    labelText: 'wage',
                    hintText: 'Enter your hourly rate',
                  ),
                  maxLength: 140, // Set the maximum character limit
                  maxLines: null, // Allow multiple lines of text
                ),
                Text('Enter your hourly rate',
                    style: TextStyle(
                      color: Colors.grey, // Customize the hint text color
                      fontSize: 12, // Customize the hint text font size
                    )),
                SizedBox(height: 20),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Service Description',
                    hintText:
                        'Enter the service description', //TODO: BETTER MAKE IT A DROP DOWN OR RADIO BUTTON
                  ),
                  maxLength: 50, // Set the maximum character limit
                  maxLines: null, // Allow multiple lines of text
                ),
                Text('Enter your service category',
                    style: TextStyle(
                      color: Colors.grey, // Customize the hint text color
                      fontSize: 12, // Customize the hint text font size
                    )),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Rate Your Day: ${rating.toInt()} Stars'),
                    Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      onChanged: (newRating) {
                        setState(() {
                          rating = newRating;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: <Widget>[
                //     Text('Date: ${selectedDate.toLocal()}'.split(' ')[0]),
                //     ElevatedButton(
                //       onPressed: () => _selectDate(context),
                //       child: Text(
                //           '${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                //     ),
                //   ],
                // ),
                // SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImageFromGallery,
                  child: Text('Add Image from Gallery'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImageFromCamera,
                  child: Text('Add Image from Camera'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saveServiceEntry,
                  child: Text('Save Entry'),
                ),
              ],
            ),
          ),
        ));
  }
}

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error Exception'),
      content: const Text('You are already providing this service, instead of creating new posting modify your existing ad!'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
