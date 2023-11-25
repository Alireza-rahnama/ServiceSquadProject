import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentService {

  static Future<bool> payBooking({
    required String email,
    required String serviceID,
    required int bookingStart,
    required int bookingLength,
    required String clientID,
    required String address,
    required BuildContext context,
  }) async {

    try {
      /*
      let serviceDocID = req.body.serviceDocID;
      let bookingStartEpoch = req.body.startEpoch;
      let bookingLength = parseInt(req.body.bookingLength); // Number of 30 minute blocks the user selected.
      let clientID = req.body.clientID;
      let address = req.body.address;
       */

      print("Payment attempt for booking of length ${bookingLength.toString()} service id $serviceID");
      print("Waiting for response");
      final response = await http.post(
          Uri.parse(
              "https://stripepaymentintentrequest-efzsfkqsqa-uc.a.run.app/stripePaymentIntentRequest"),
          body: {
            'email': email,
            'serviceID': serviceID,
            'startEpoch': bookingStart.toString(),
            'bookingLength': bookingLength.toString(),
            'clientID': clientID,
            'address': address,
          }
      );

      final jsonResponse = jsonDecode(response.body);
      print("got $jsonResponse");

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: jsonResponse['paymentIntent'],
            merchantDisplayName: "Service Squad",
            customerId: jsonResponse['customer'],
            customerEphemeralKeySecret: jsonResponse['ephemeralKey']
        ),
      );

      print("initialized payment sheet");

      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment was successful'))
      );
      print("Presented payment sheet");
    } catch (error) {
      if (error is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error occurred ${error.error.localizedMessage}'))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error occurred $error'))
        );
      }
    }
    return false;
  }

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