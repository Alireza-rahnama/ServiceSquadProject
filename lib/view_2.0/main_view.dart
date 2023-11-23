import 'package:flutter/material.dart';
import 'package:service_squad/view_2.0/profile_view_2.0.dart';
import 'package:service_squad/view_2.0/messages_view.dart';
import 'package:service_squad/view_2.0/services_list_view_2.0.dart';
import 'package:service_squad/view_2.0/services_list_view_professional.dart';



class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

String selectedUserType = 'Select an option';

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2;

  Widget getServicesView() {
    // Determine which view to return based on user type
    if (selectedUserType == 'Client') {
      return CategoriesView();
    } else if (selectedUserType == 'Service Associate') {
      return ProfessionalListServicesView();
    } else {
      return Placeholder(); // Or any default view
    }
  }



  List<Widget> get _children => [
    getServicesView(),
    MessagesView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.list),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.mail),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    if (selectedUserType != 'Select an option' || index != 0) {
      setState(() {
        _currentIndex = index;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a User Type in Profile and Click Save'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  /*
  final List<Widget> _children = [
    CategoriesView(),
    MessagesView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.list),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.mail),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    // Assuming 'selectedUserType' is a global variable that stores the user type
    // print("TO DEBUGGGGGGGGGGGGGGGGGG");
    // print(selectedUserType);
    if (selectedUserType != 'Select an option' || index == 2) {
      setState(() {
        _currentIndex = index;
      });
    } else {
      // Show an alert or a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a User Type in Profile and Click Save'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

   */