import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/grid_item_data.dart';
import 'auth_gate.dart';

class Category extends StatelessWidget {
  const Category({super.key});

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
                  print("tapped navigate adventure enthusiast");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Placeholder()),//TODO
                  );
                  break;
                case(1):
                  print("tapped gridview- route not implemented yet");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Placeholder()),//TODO
                  );
                  break;
                case(2):
                  print("tapped gridview");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Placeholder()),
                  );
                  break;
//TODO
                case(3):
                  print("tapped gridview");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Placeholder()),
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
