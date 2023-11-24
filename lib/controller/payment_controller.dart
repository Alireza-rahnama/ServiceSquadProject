import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentService {

  static Future<bool> initPayment({required String email, required int amount, required BuildContext context}) async {
    try {
      final response = await http.post(
          Uri.parse("https://stripepaymentintentrequest-efzsfkqsqa-uc.a.run.app/stripePaymentIntentRequest"),
          body: {'email': email, 'amount': amount.toString()});
      final jsonResponse = jsonDecode(response.body);

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: jsonResponse['paymentIntent'],
            merchantDisplayName: "Service Squad",
            customerId: jsonResponse['customer'],
            customerEphemeralKeySecret: jsonResponse['ephemeralKey'],

          )
      );

      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment is successful')));
      return true;
    } catch (error) {
      if (error is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error occurred ${error.error.localizedMessage}')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error occurred $error')));
      }
      return false;
    }
  }

}