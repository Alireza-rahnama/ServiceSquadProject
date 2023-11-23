import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          "My Messages",
          style: GoogleFonts.pacifico(
            color: Colors.white,
            fontSize: 30.0,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.message, // Icon for no messages
              size: 100.0,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 20), // Space between icon and text
            Text(
              'You currently have no messages',
              style: GoogleFonts.lato(
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
