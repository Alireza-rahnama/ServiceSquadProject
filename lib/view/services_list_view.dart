import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:service_squad/controller/professional_service_controller.dart';
import 'package:service_squad/view/reviews_list_view.dart';
import 'package:service_squad/view/service_entry_view.dart';
import '../controller/profile_controller.dart';
import '../model/professional_service.dart';
import 'auth_gate.dart';
import 'category_selection.dart';

/// A stateless widget representing the main page where users can view
/// and manage their cars after authentication.
class CategoriesView extends StatefulWidget {
// Constructor to create a HomePage widget.
  CategoriesView({Key? key}) : super(key: key);
  bool isDark = false;
  String categoryToPopulate = '';

  CategoriesView.WithPersistedThemeAndCategory(
      bool inheritedIsDark, String categoryName) {
    isDark = inheritedIsDark;
    categoryToPopulate = categoryName;
  }

  @override
  State<CategoriesView> createState() =>
      _CategoriesViewState.withPersistedThemeAndCategory(
          isDark, categoryToPopulate);
}

class _CategoriesViewState extends State<CategoriesView> {
// Instance of CarService to interact with Firestore for CRUD operations on cars.
  final ProfessionalServiceController professionalServiceController =
      ProfessionalServiceController();
  String? selectedCategory;
  bool isDark;
  List<ProfessionalService> filteredEntries = [];
  final TextEditingController searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String categoryName;
  XFile? _image;

  _CategoriesViewState.withPersistedThemeAndCategory(
      this.isDark, this.categoryName);

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
              icon: Icon(Icons.navigate_before),
              // Sign out the user on pressing the logout button.
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategorySelection(),
                  ),
                );
              },
            ),
            backgroundColor: Colors.deepPurple,
            title: Text("${categoryName}",
                style: GoogleFonts.pacifico(
                  color: Colors.white,
                  fontSize: 28.0,
                )),
            actions: [
              IconButton(
                color: Colors.white,
                icon: Icon(Icons.logout),
                // Sign out the user on pressing the logout button.
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
              PopupMenuButton<String>(
                onSelected: (String category) async {
                  setState(() {
                    selectedCategory = category;
                  });
                  print("selectedCategory is $selectedCategory");
                  applyFilterAndUpdateState3(false);
                },
                icon: Icon(
                  Icons.filter_list,
                  color: Colors.white,
                ),
                itemBuilder: (BuildContext context) {
                  // Create a list of months for filtering
                  final List<String> serviceCategories = [
                    'Housekeeping',
                    'Snow Clearance',
                    'Handy Services',
                    'Lawn Mowing'
                    // December
                  ];

                  return serviceCategories.map((String category) {
                    return PopupMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList();
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchAnchor(builder:
                    (BuildContext context, SearchController controller) {
                  //TODO: We can implement the location logic here to search services by location
                  return SearchBar(
                    hintText: "location, category, or rating",
                    controller: searchController,
                    padding: const MaterialStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    onChanged: (_) async {
                      applyFilterAndUpdateState3(false);
                    },
                    onSubmitted: (_) async {
                      applyFilterAndUpdateState3(true);
                    },
                    leading: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          applyFilterAndUpdateState3(false);
                        }),
                    // trailing: <Widget>[
                    //   Tooltip(
                    //     message: 'Change brightness mode',
                    //     child: IconButton(
                    //       isSelected: isDark,
                    //       onPressed: () {
                    //         setState(() {
                    //           isDark = !isDark;
                    //         });
                    //       },
                    //       icon: const Icon(Icons.wb_sunny_outlined),
                    //       selectedIcon: const Icon(Icons.brightness_2_outlined),
                    //     ),
                    //   )
                    // ],
                  );
                }, suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  return List<ListTile>.generate(5, (int index) {
                    final String item = 'item $index';
                    return ListTile(
                      title: Text(item),
                      onTap: () {
                        setState(() {
                          controller.closeView(item);
                        });
                      },
                    );
                  });
                }),
              ),
            ),
          ),

          // Body of the widget using a StreamBuilder to listen for changes
          // in the professionalServiceCollection  and reflect them in the UI in real-time.
          body: StreamBuilder<List<ProfessionalService>>(
            stream: professionalServiceController.getAllProfessionalServices(),
            builder: (context, snapshot) {
              // Show a loading indicator until data is fetched from Firestore.
              if (!snapshot.hasData) return CircularProgressIndicator();

              List<ProfessionalService> professionalServices =
                  (!filteredEntries.isEmpty) ? filteredEntries : snapshot.data!;
              // professionalServices
              //     .sort((a, b) => (b.wage! as num).compareTo(a.wage! as num));

              String? lastCategory;

              return ListView.builder(
                itemCount: professionalServices.length,
                itemBuilder: (context, index) {
                  final entry = professionalServices[index];
                  if (lastCategory == null || entry.category != lastCategory) {
                    final headerText = entry.category;
                    lastCategory = entry.category!;

                    return Column(
                      children: [
                        DateHeader(text: headerText),
                        Card(
                          margin: EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onLongPress: () {
                              // Perform your action here when the Card is long-pressed.
                              _showEditDialog(context, entry, index);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BuildImageFromUrl(entry),
                                  //TODO: DO WEE= NEED AN IMAGe HERE?
                                  Row(
                                    children: [
                                      Text(
                                        'Technician: ${entry.technicianAlias}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Spacer(),
                                      IconButton(
                                        icon: Icon(Icons.rate_review_rounded),
                                        onPressed: () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ReviewsView
                                                  .forEachProfessionalService(
                                                  isDark, entry),
                                            ),
                                          );
                                          print(
                                              '${FirebaseAuth.instance.currentUser!.email}');
                                          print(
                                              'selectedProfessionalServiceCategory is ${entry.category}');
                                          //TODO: IMPLEMENT LOGIC AND VIEW Maybe only for client user type

                                        },
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    '${entry.serviceDescription}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      RatingEvaluator(entry),
                                      Spacer(),
                                      Spacer(),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () async {
                                          print(
                                              'entry with id: ${entry!.id} was selected to delete');
                                          //TODO: IMPLEMENT OR NOT
                                          String? userType =
                                              await profileController
                                                  .getUserType(FirebaseAuth
                                                      .instance
                                                      .currentUser!
                                                      .uid);
                                          if (userType! ==
                                              "Service Associate") {
                                            await professionalServiceController
                                                .deleteProfessionalService(
                                                    entry!.id);

                                            final serviceEntries =
                                                await professionalServiceController
                                                    .getAllProfessionalServices()
                                                    .first;

                                            setState(() {
                                              // Initialize filteredEntries with a copy of serviceEntries
                                              filteredEntries = List<
                                                      ProfessionalService>.from(
                                                  serviceEntries);
                                            });
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.calendar_today),
                                        onPressed: () async {
                                          print(
                                              '${FirebaseAuth.instance.currentUser!.email}');
                                          print(
                                              'selectedCategory is ${selectedCategory}');
                                          //TODO: IMPLEMENT LOGIC AND VIEW Maybe only for client user type
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onLongPress: () {
                          // Perform your action here when the Card is long-pressed.
                          _showEditDialog(context, entry, index);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // BuildImageFromUrl(entry),todo: do we need image here?
                              Text(
                                entry.serviceDescription,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 15),
                              Text(
                                '${entry.serviceDescription}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  RatingEvaluator(entry),
                                  Spacer(),
                                  Spacer(),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      await professionalServiceController
                                          .deleteProfessionalService(entry!.id);

                                      final serviceEntries =
                                          await professionalServiceController
                                              .getAllProfessionalServices()
                                              .first;

                                      setState(() {
                                        // Initialize filteredEntries with a copy of serviceEntries
                                        filteredEntries =
                                            List<ProfessionalService>.from(
                                                serviceEntries);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),

          // Floating action button to open a dialog for adding a new service entry of a specific service category
          floatingActionButton: FloatingActionButton(
            tooltip: "Add my service",
            onPressed: () async {
              String? userType = await profileController
                  .getUserType(FirebaseAuth.instance.currentUser!.uid);
              if (userType! == "Service Associate") {
                showDialog(
                  context: context,
                  builder: (context) =>
                      ServiceEntryView.withInheritedTheme(categoryName),
                );
              } else {
                print("userType wasnt provider!");
              }
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

  if (userType! == "provider") {
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

    return Card(
      elevation: 4, // Add elevation for a card-like appearance
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0), // Add rounded corners
        child: Image.network(
          entry.imagePath!,
          height: 200,
          width: 400, // Set a fixed size for the image
          fit: BoxFit.cover, // Adjust how the image is displayed
        ),
      ),
    );
  } else {
    // If entry.imagePath is null, display a placeholder or an empty container
    return Container(); // You can customize this to show a placeholder image
  }
}

Row RatingEvaluator(ProfessionalService entry) {
  switch (entry.rating) {
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
