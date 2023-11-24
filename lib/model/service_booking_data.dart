import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceBookingData {
  final id;
  final serviceID;
  final serviceDocID;
  final bookingStart;
  final bookingEnd;
  final dateCreated;
  final clientID;
  final address;

  ServiceBookingData(
      {this.id,
        required this.serviceID,
        required this.serviceDocID,
        required this.bookingStart,
        required this.bookingEnd,
        required this.dateCreated,
        required this.clientID,
        required this.address,});

  Map<String, dynamic> toMap() {
    return {
      'serviceID': serviceID,
      'serviceDocID': serviceDocID,
      'bookingStart': bookingStart,
      'bookingEnd': bookingEnd,
      'dateCreated': dateCreated,
      'clientID': clientID,
      'address': address,
    };
  }

  /// Converts a Firestore `DocumentSnapshot` back into a `UserProfileData` object.
  ///
  /// This static method handles the **deserialization** process. It extracts the
  /// data from the Firestore document and constructs a `UserProfileData` object. By providing
  /// this method, it offers an encapsulated way to transform Firestore data back
  /// into custom Dart objects, making CRUD (Create, Read, Update, Delete) operations
  /// easier and more intuitive.
  ///
  /// [doc] is the Firestore `DocumentSnapshot` that contains the data to be deserialized.
  static ServiceBookingData? fromMap(DocumentSnapshot doc) {
    Map<String, dynamic>? map = doc.data() as Map<String, dynamic>?;

    if (map == null) {
      // Handle the case where the document doesn't contain data as expected
      return null;
    }

    return ServiceBookingData(
        id: doc.id,
        serviceID: map['userType'],
        serviceDocID: map['serviceDocID'],
        bookingStart: map['bookingStart'],
        bookingEnd: map['bookingEnd'],
        dateCreated: map['dateCreated'],
        clientID: map['clientID'],
        address: map['address'],);
  }
}

