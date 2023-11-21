import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_squad/controller/professional_service_controller.dart';
import 'package:service_squad/view/profile_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_squad/view/service_entry_view.dart';

import '../model/grid_item_data.dart';
import 'auth_gate.dart';
import 'services_list_view.dart';

import 'message_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CategorySelection extends StatelessWidget {
  
  const CategorySelection({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: CategoryView(),
    );
  }
}

class CategoryView extends StatefulWidget {
  CategoryView({super.key});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  final List<GridItemData> gridData = [
    GridItemData(
      imagePath: 'assets/house_keeping.jpeg',
      icon: Icons.cleaning_services,
      text: 'House Keeping',
    ),
    GridItemData(
      imagePath: 'assets/snow_clearance.jpeg',
      icon: Icons.snowmobile,
      text: 'Snow Clearance',
    ),
    GridItemData(
      imagePath: 'assets/lawn_mowing.jpeg',
      icon: Icons.grass,
      text: 'Lawn Mowing',
    ),
    GridItemData(
      imagePath: 'assets/handy.jpeg',
      icon: Icons.construction,
      text: 'Handy \n Services',
    ),
  ];

  @override
  void initState() {
    super.initState();
    updateFcmToken();  // Call the method to update the token
  }
  
  Future<void> updateFcmToken() async {
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  if (userEmail != null) {
    String? token = await FirebaseMessaging.instance.getToken();
    print('START TO GET TOKENTOKENTOKENTOKENTOKEN  ${token}');

    QuerySnapshot userDocs = await FirebaseFirestore.instance.collection('users')
                                          .where('email', isEqualTo: userEmail)
                                          .get();
    
    if (userDocs.docs.isEmpty) {
      // Create the document if it doesn't exist
      await FirebaseFirestore.instance.collection('users').add({
        'email': userEmail,
        'fcmToken': token,
        // add other user details as necessary
      });
    } else {
      // Update the document
      if (token != null) {
        DocumentReference userDocRef = userDocs.docs.first.reference;
        await userDocRef.update({'fcmToken': token});
      }
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          // leading: IconButton(
          //   color: Colors.white,
          //     icon: Icon(Icons.add),
          //     onPressed: () async {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) =>
          //                 ServiceEntryView.withInheritedTheme(false,category)),
          //       );
          //     }),
          title: Text(
              "Service Categories",
              style: GoogleFonts.pacifico(
                color: Colors.white,
                fontSize: 30.0,
              )
          ),
          actions: <Widget>[

            // David: add a Message Icon
            IconButton(
              icon: Icon(Icons.inbox_outlined,color: Colors.white,),
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessageScreen()),
                );
              }
              ),
            // David: till here

            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.person),
              tooltip: 'Go to profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileView()),
                );
              },
            ),
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.logout),
              tooltip: 'Log out',
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

            
          ]),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.53
        ),
        itemCount: gridData.length,

        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              switch (index){
                case(0):
                  print("tapped navigate housekeeping");
                  //TODO: here we could implement the logic based on the user type/role: if they are
                  //a service provider they will be able to see all the services available and they will be able to add
                  //their own professional_service posting
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoriesView.WithPersistedThemeAndCategory(
                        false, "House Keeping"),),//TODO
                  );
                  break;
                case(1):
                  print("tapped gridview- route not implemented yet");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoriesView.WithPersistedThemeAndCategory(
                        false, "Snow Clearance")),//TODO
                  );
                  break;
                case(2):
                  print("tapped gridview");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoriesView.WithPersistedThemeAndCategory(
                        false, "Lawn Mowing")),
                  );
                  break;
//TODO
                case(3):
                  print("tapped gridview");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoriesView.WithPersistedThemeAndCategory(
                        false, "Handy Services")),
                  );
                  break;
              }
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35) ,
                image: DecorationImage(
                  image: AssetImage(gridData[index].imagePath),
                  fit: BoxFit.cover,
                  opacity: 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    gridData[index].icon,
                    size: 36.0,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    gridData[index].text,
                    style: GoogleFonts.pacifico(
                      color: Colors.white,
                      fontSize: 30.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

//TODO: after user logs in we need to show this alert and ask users to complete their profile
//userType is required for the level of access in the app
class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error Exception'),
      content: const Text('Please complete your profile to continue'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
  }
}