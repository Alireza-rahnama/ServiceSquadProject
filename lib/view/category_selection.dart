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

class CategorySelection extends StatelessWidget {
  const CategorySelection({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
        cardColor: Color(0xFF008080),
        useMaterial3: true,
      ),
      home: CategoryView(),
    );
  }
}

class CategoryView extends StatelessWidget {
  CategoryView({super.key});

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
          backgroundColor: Colors.black,
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
              icon: const Icon(Icons.arrow_back_outlined),
              tooltip: 'Go back',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthGate()),
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
                  opacity: 0.7,
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