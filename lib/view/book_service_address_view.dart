import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_gate.dart';

class BookServiceAddressView extends StatefulWidget {
  const BookServiceAddressView({super.key});

  @override
  State<BookServiceAddressView> createState() => _BookServiceAddressViewState();
}

class _BookServiceAddressViewState extends State<BookServiceAddressView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
            "Book Service",
            style: GoogleFonts.pacifico(
              color: Colors.white,
              fontSize: 30.0,
            )
        ),
        actions: <Widget>[
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
        ]
      ),
      // todo: add scrollable
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                alignLabelWithHint: false,
                labelText: "Address line 1",

              ),

            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Address line 2"
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "City"
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Province"
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            label: const Text("Proceed to checkout"),
            icon: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
