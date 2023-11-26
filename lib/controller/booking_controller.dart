
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:service_squad/model/service_booking_data.dart';

class BookingController {
  /// The currently authenticated user from Firebase.
  final user = FirebaseAuth.instance.currentUser;

  /// A reference to the Firestore collection where bookings are stored
  late final CollectionReference bookingsCollection;

  /// Constructor initializes the reference to the Firestore collection
  BookingController() {
    bookingsCollection = FirebaseFirestore.instance
        .collection('service_bookings');
  }

  Future<void> createBooking(ServiceBookingData bookingData) async {
    await bookingsCollection.add(bookingData);
  }

}