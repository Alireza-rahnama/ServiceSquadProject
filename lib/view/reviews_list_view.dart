import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:service_squad/controller/professional_service_controller.dart';
import 'package:service_squad/view/review_entry_view.dart';
import 'package:service_squad/view/service_entry_view.dart';
import 'package:service_squad/view_2.0/main_view.dart';
// import 'package:service_squad/view/services_list_view.dart';
//import 'package:service_squad/view_2.0/services_list_view_2.0.dart';
import '../controller/profile_controller.dart';
import '../model/professional_service.dart';
import '../view_2.0/services_list_view_2.0.dart';
import 'auth_gate.dart';
//import 'category_selection.dart';

/// A stateless widget representing the main page where users can view
/// and manage their cars after authentication.
class ReviewsView extends StatefulWidget {
// Constructor to create a HomePage widget.
  ReviewsView({Key? key}) : super(key: key);
  bool isDark = false;
  List<String?>? reviewsList;
  Map<String, int>? reviewsMap;

  late ProfessionalService professionalService;

  ReviewsView.forEachProfessionalService(
      bool inheritedIsDark, ProfessionalService professionalService) {
    isDark = inheritedIsDark;
    reviewsList = professionalService.reviewList ?? [];
    reviewsMap = professionalService.reviewsMap ?? {};

    this.professionalService = professionalService;
  }

  @override
  State<ReviewsView> createState() =>
      _ReviewsViewState.withPersistedThemeAndCategory(
          isDark, professionalService, reviewsList, reviewsMap);
}

class _ReviewsViewState extends State<ReviewsView> {
// Instance of CarService to interact with Firestore for CRUD operations on cars.
  final ProfessionalServiceController professionalServiceController =
      ProfessionalServiceController();
  String? selectedCategory;
  bool isDark;
  List<ProfessionalService> filteredEntries = [];
  final TextEditingController searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late List<String?>? reviewsList;
  late Map<String, int>? reviewsMap;
  XFile? _image;
  late ProfessionalService service;

  _ReviewsViewState.withPersistedThemeAndCategory(
      this.isDark, this.service, this.reviewsList, this.reviewsMap);

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  // filteredServicesByCategory()

  // Future<String?> _uploadImageToFirebaseAndReturnDownlaodUrl async(
  //     String? existingImagePath) async {
  //   if (_image == null) return existingImagePath;
  //   String? downloadURL = null;
  //   final currentUser = FirebaseAuth.instance.currentUser;
  //   if (currentUser == null) return null;
  //   final firebaseStorageRef = FirebaseStorage.instance
  //       .ref()
  //       .child('images/${currentUser.uid}/${_image!.name}');
  //
  //   try {
  //     final uploadTask = await firebaseStorageRef.putFile(File(_image!.path));
  //     if (uploadTask.state == TaskState.success) {
  //       downloadURL = await firebaseStorageRef.getDownloadURL();
  //
  //       print("Uploaded to: $downloadURL");
  //     }
  //   } catch (e) {
  //     print("Failed to upload image: $e");
  //   }
  //   return downloadURL;
  // }

  void _showEditDialog(BuildContext context,
      ProfessionalService professionalServiceEntry, int index) {
    TextEditingController descriptionEditingController =
        TextEditingController();
    descriptionEditingController.text = professionalServiceEntry
        .serviceDescription; // Initialize the text field with existing content.

    TextEditingController wageEditingController = TextEditingController();
    wageEditingController.text = '${professionalServiceEntry!.wage}';

    ProfessionalServiceController professionalServiceController =
        ProfessionalServiceController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Diary Entry'),
          content: Column(children: [
            TextField(
              controller: descriptionEditingController,
              decoration: InputDecoration(labelText: "New Description"),
              maxLines: null, // Allows multiple lines of text.
            ),
            TextField(
              controller: wageEditingController,
              decoration: InputDecoration(labelText: "New Wage"),
              maxLines: null, // Allows multiple lines of text.
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _pickImageFromGallery(),
              child: Text('pick image from gallery'),
            )
          ]),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                print(
                    'professionalServiceEntrycategory is: ${professionalServiceEntry!.category}');
                // Save the edited content to the service entry.
                String location = await ProfileController()
                    .getUserLocation(FirebaseAuth.instance.currentUser!.uid);
                await professionalServiceController.updateProfessionalService(
                    ProfessionalService(
                        serviceDescription: descriptionEditingController.text,
                        wage: double.parse(wageEditingController.text),
                        category: professionalServiceEntry.category,
                        id: professionalServiceEntry!.id,
                        rating: professionalServiceEntry.rating,
                        location: location,
                        technicianAlias:
                            professionalServiceEntry.technicianAlias));

                updateState(professionalServiceEntry.category);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Center(child: Text('Entry successfully saved!')),
                      backgroundColor: Colors.deepPurple),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void applyFilterAndUpdateState3(bool isOnSubmitted) async {
    List<String> categories = [
      "Snow Clearance",
      "House Keeping",
      "Handy Services",
      "Lawn Mowing"
    ];

    final serviceEntries = selectedCategory != null
        ? await professionalServiceController
            .getProfessionalServices(selectedCategory!)
            .first
        : await professionalServiceController
            .getAllProfessionalServices()
            .first;
    print('length of serviceEntries is ${serviceEntries.length}');
    // final serviceEntries = await professionalServiceController
    //     .getAllAvailableProfessionalServiceCollections()
    //     .first;
    String userLocation = await ProfileController()
        .getUserLocation(FirebaseAuth.instance.currentUser!.uid);
    bool isSnackBarDisplayed = false;

    setState(() {
      // Initialize filteredEntries with a copy of serviceEntries
      filteredEntries = List<ProfessionalService>.from(serviceEntries);
      List<int> ratings = [1, 2, 3, 4, 5];
      String queryText = searchController.text.toLowerCase();
      bool queryIsLocation = false;

      print(
          '!categories.contains(queryText): ${!categories.contains(queryText)}');
      if (!categories.contains(queryText) &&
          !ratings.contains(int.tryParse(queryText))) {
        queryIsLocation = true;
      }

      print('queryText: $queryText');
      print(
          'categories.contains(queryText): ${categories.contains(queryText)}');
      print(
          'ratings.contains(int.tryParse(queryText)): ${ratings.contains(int.tryParse(queryText))}');
      // Filter based on the rating or category
      if (searchController.text.isNotEmpty) {
        filteredEntries = filteredEntries.where((entry) {
          print('entry.location.toLowerCase() is ${userLocation}');
          return entry.category
                  .toLowerCase()
                  .contains(queryText.toLowerCase()) ||
              entry.rating == int.tryParse(queryText) ||
              entry.location.contains(queryText.toLowerCase());
        }).toList();
        // } else if (queryIsLocation) {
        //   print('queryIsLocation: ${queryIsLocation}');
        //   filteredEntries = filteredEntries.where((entry) {
        //     print('entry.Category is: ${entry.category}');
        //     return entry.location.toLowerCase().contains(queryText.toLowerCase());
        //   }).toList();
      } else {
        filteredEntries = filteredEntries.where((entry) {
          return entry.category == selectedCategory;
        }).toList();
      }

      // Show a message if no matches are found
      print('filteredEntries.length: ${filteredEntries.length}');
      print('serviceEntries.length: ${serviceEntries.length}');

      if (isOnSubmitted &&
          searchController.text.isNotEmpty &&
          !isSnackBarDisplayed &&
          (filteredEntries.length == serviceEntries.length ||
              filteredEntries.length == 0)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('No match found!')),
            duration: Duration(milliseconds: 1000),
          ),
        );
        isSnackBarDisplayed = true;
      }
    });
  }

  void updateState(String category) async {
    final professionalServiceEntries = await professionalServiceController
        .getProfessionalServices(category)
        .first;

    setState(() {
      filteredEntries = professionalServiceEntries;
    });
  }

  final profileController = ProfileController();

  String convertIntMonthToStringRepresentation(int month) {
    String representation = '';
    switch (month) {
      case 1:
        representation = 'jan';
        break;
      case 2:
        representation = 'feb';
        break;
      case 3:
        representation = 'mar';
        break;
      case 4:
        representation = 'apr';
        break;
      case 5:
        representation = 'may';
        break;
      case 6:
        representation = 'jun';
        break;
      case 7:
        representation = 'jul';
        break;
      case 8:
        representation = 'aug';
        break;
      case 9:
        representation = 'sep';
        break;
      case 10:
        representation = 'oct';
        break;
      case 11:
        representation = 'nov';
        break;
      case 12:
        representation = 'dec';
        break;
    }
    return representation;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light);

    return Theme(
        data: themeData,
        child: Scaffold(
          // App bar with a title and a logout button.
          appBar: AppBar(
            leading: IconButton(
              color: Colors.white,
              icon: Icon(Icons.arrow_back_outlined),
              // Sign out the user on pressing the logout button.
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoriesView.WithPersistedThemeAndCategory(
                        false, service.category),),
                );
              },
            ),
            backgroundColor: Colors.deepPurple,
            title: Text("Reviews",
                style: GoogleFonts.pacifico(
                  color: Colors.white,
                  fontSize: 28.0,
                )),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
              ),
            ),
          ),

          body: ListView.builder(
            // itemCount: reviewsList!.length,
            // itemCount: reviewsMap!.length,
            itemCount: reviewsMap!.keys.length,
            itemBuilder: (context, index) {
              // print('entry = reviewsList![index]: ${reviewsList![index]}');
              // final entry = reviewsList![index];
              // final entry = reviewsMap![index];

              final entryKeyOrReview = reviewsMap!.keys.toList()[index];
              final entryValueOrRating = reviewsMap![entryKeyOrReview];
              return Column(
                children: [
                  Card(
                    margin: EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onLongPress: () {
                        // Perform your action here when the Card is long-pressed.
                        return;
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Column(children: [
                              Text(
                                '${entryKeyOrReview}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Spacer(),
                        Row(children: [SizedBox(height: 10,), Spacer(),RatingEvaluator2(entryValueOrRating!)])
                            // SizedBox(height: 10,),
                            //   RatingEvaluator2(entryValueOrRating!),
                            // ])
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
              // }
            },
          ),
          // Floating action button to open a dialog for adding a new service entry of a specific service category
          floatingActionButton: FloatingActionButton(
            tooltip: "Add a review",
            onPressed: () async {
              String? userType = await profileController
                  .getUserType(FirebaseAuth.instance.currentUser!.uid);
              // if (userType! != "Service Associate") {
              //   () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) =>
                        ReviewEntryView.withInheritedTheme(isDark, service)),
              );
              print('reached on press!');
              // Navigator.of(context).pop();
              // };
              // } else {
              //   print("userType was service associate!");
              // }
            },
            child: Icon(Icons.add),
          ),
        ));
  }
}

Future<Widget> displayOrHideFloatingActionButtonBasedOnUserRole(
    {required bool isDark,
    required String categoryName,
    required BuildContext context}) async {
  ProfileController profileController = ProfileController();

  String? userType = await profileController
      .getUserType(FirebaseAuth.instance.currentUser!.uid);

  if (userType! == "Service Associate") {
    return FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: "Add new service",
        onPressed: () async {
          showDialog(
            context: context,
            builder: (context) =>
                ServiceEntryView.withInheritedTheme(categoryName),
          );
        });
  } else {
    return SizedBox(height: 0.0);
  }
}

Widget BuildImageFromUrl(ProfessionalService entry) {
  if (entry.imagePath != null) {
    // If entry.imagePath is not null, display the image from the network
    // return Container(child: Image.network(entry.imagePath!),
    //     height: 100, fit: BoxFit.cover );

    // return Card(
    //   elevation: 4, // Add elevation for a card-like appearance
    //   child: ClipRRect(
    //     borderRadius: BorderRadius.circular(360.0), // Add rounded corners
    //     child: Image.network(
    //       entry.imagePath!,
    //       height: 50,
    //       width: 500, // Set a fixed size for the image
    //       fit: BoxFit.cover, // Adjust how the image is displayed
    //     ),
    //   ),
    // );
    return  Center(child:ClipOval(
        child: Image.network(
          entry.imagePath!,
          height: 65, // Set the desired height
          width: 65, // Take the available width
          fit: BoxFit.fill, // Adjust how the image is displayed
        ),

    ));
  } else {
    // If entry.imagePath is null, display a placeholder or an empty container
    return Container(); // You can customize this to show a placeholder image
  }
}

// Row RatingEvaluator(ProfessionalService entry) {
//   switch (entry.rating) {
//     case (1):
//       return Row(children: [
//         Icon(Icons.star),
//       ]);
//     case (2):
//       return Row(children: [Icon(Icons.star), Icon(Icons.star)]);
//     case (3):
//       return Row(
//           children: [Icon(Icons.star), Icon(Icons.star), Icon(Icons.star)]);
//     case (4):
//       return Row(children: [
//         Icon(Icons.star),
//         Icon(Icons.star),
//         Icon(Icons.star),
//         Icon(Icons.star)
//       ]);
//     case (5):
//       return Row(children: [
//         Icon(Icons.star),
//         Icon(Icons.star),
//         Icon(Icons.star),
//         Icon(Icons.star),
//         Icon(Icons.star)
//       ]);
//     default:
//       return Row(); // Handle other cases or return an empty row if the rating is not 1-5.
//   }
// }

Row RatingEvaluator(int entryRating) {
  switch (entryRating) {
    case (1):
      return Row(children: [
        Icon(Icons.star),
      ]);
    case (2):
      return Row(children: [Icon(Icons.star), Icon(Icons.star)]);
    case (3):
      return Row(
          children: [Icon(Icons.star), Icon(Icons.star), Icon(Icons.star)]);
    case (4):
      return Row(children: [
        Icon(Icons.star),
        Icon(Icons.star),
        Icon(Icons.star),
        Icon(Icons.star)
      ]);
    case (5):
      return Row(children: [
        Icon(Icons.star),
        Icon(Icons.star),
        Icon(Icons.star),
        Icon(Icons.star),
        Icon(Icons.star)
      ]);
    default:
      return Row(); // Handle other cases or return an empty row if the rating is not 1-5.
  }
}

Row RatingEvaluator2(int entryRating) {
  switch (entryRating) {
    case (1):
      return Row(children: [
        Icon(
          Icons.sentiment_very_dissatisfied,
          color: Colors.red,
        )
      ]);
    case (2):
      return Row(children: [
        Icon(
          Icons.sentiment_dissatisfied,
          color: Colors.yellow.shade700,
        ),
        Icon(
          Icons.sentiment_dissatisfied,
          color: Colors.yellow.shade700,
        )
      ]);
    case (3):
      return Row(children: [
        Icon(
          Icons.sentiment_neutral,
          color: Colors.amber,
        ),
        Icon(
          Icons.sentiment_neutral,
          color: Colors.amber,
        ),
        Icon(
          Icons.sentiment_neutral,
          color: Colors.amber,
        )
      ]);
    case (4):
      return Row(children: [
        Icon(
          Icons.sentiment_satisfied,
          color: Colors.lightGreen,
        ),
        Icon(
          Icons.sentiment_satisfied,
          color: Colors.lightGreen,
        ),
        Icon(
          Icons.sentiment_satisfied,
          color: Colors.lightGreen,
        ),
        Icon(
          Icons.sentiment_satisfied,
          color: Colors.lightGreen,
        )
      ]);
    case (5):
      return Row(children: [
        Icon(
          Icons.sentiment_very_satisfied,
          color: Colors.green,
        ),
        Icon(
          Icons.sentiment_very_satisfied,
          color: Colors.green,
        ),
        Icon(
          Icons.sentiment_very_satisfied,
          color: Colors.green,
        ),
        Icon(
          Icons.sentiment_very_satisfied,
          color: Colors.green,
        ),
        Icon(
          Icons.sentiment_very_satisfied,
          color: Colors.green,
        ),
      ]);
    default:
      return Row(); // Handle other cases or return an empty row if the rating is not 1-5.
  }
}

class Month {
  int num;
  String name;

  Month(this.num, this.name);

  String get Name {
    return name;
  }

  int get Number {
    return num;
  }
}

class DateHeader extends StatelessWidget {
  final String text;

  const DateHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8.0),
        child: Text(text,
            style: GoogleFonts.pacifico(
              color: Colors.deepPurple,
              fontSize: 30.0,
            )));
  }
}
