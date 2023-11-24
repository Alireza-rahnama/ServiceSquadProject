import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_squad/model/professional_service.dart';
import 'package:service_squad/model/service_booking_data.dart';

import '../controller/payment_controller.dart';

class CheckoutView extends StatelessWidget {
  final ProfessionalService service;
  final ServiceBookingData booking;
  const CheckoutView({super.key, required this.service, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
            "Checkout",
            style: GoogleFonts.pacifico(
              color: Colors.white,
              fontSize: 30.0,
            )
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text("Item 1"),
            ElevatedButton(
              child: Text("Pay \$20"),
              onPressed: () async {
                await PaymentService.initPayment(
                    email: FirebaseAuth.instance.currentUser!.email!,
                    amount: 2000,
                    context: context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
