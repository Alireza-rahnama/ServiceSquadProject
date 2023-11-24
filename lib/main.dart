import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:service_squad/view/auth_gate.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Stripe.publishableKey = "pk_test_51OF3BFCRzhLSPD1XuoRlWUA0ae8YFEIi8QL2Ogj5Bh9VaAZH8N4kYi2samABXboL17xjA99E1EUpkko95iYOpUht005uAhPBn7";
  await Stripe.instance.applySettings();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthGate()
    );
  }
}
