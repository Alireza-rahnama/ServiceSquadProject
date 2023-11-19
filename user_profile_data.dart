import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_squad/model/professional_service.dart';

class UserProfileData {
  final userType;
  List<ProfessionalService>? listOfOfferingProfessionalServices;
  var userAbout;
  var userRating;
  String? imagePath;
  String emailAddress;
  final mobilePhoneNumber;

  // String fcmToken;  // David: add fcmToken

  /// The unique identifier for the car.
  /// Might be `null` before saving to Firestore.
  String? id;

  UserProfileData(
      {required this.userType,
      this.listOfOfferingProfessionalServices,
      this.userAbout,
      this.userRating,
      this.imagePath,
      this.id,
      required this.emailAddress,
      required this.mobilePhoneNumber,
      
      // required this.fcmToken
    });

  Map<String, dynamic> toMap() {
    return {
      'userType': userType,
      'listOfOfferingProfessionalServices': listOfOfferingProfessionalServices
          ?.map((service) => service.toMap())
          .toList(),
      'userAbout': userAbout,
      'userRating': userRating,
      'imagePath': imagePath,
      'emailAddress': emailAddress,
      'mobilePhoneNumber': mobilePhoneNumber,
      // 'fcmToken': fcmToken,
    };
  }


  /// Converts a Firestore `DocumentSnapshot` back into a `Todo` object.
  ///
  /// This static method handles the **deserialization** process. It extracts the
  /// data from the Firestore document and constructs a `Todo` object. By providing
  /// this method, it offers an encapsulated way to transform Firestore data back
  /// into custom Dart objects, making CRUD (Create, Read, Update, Delete) operations
  /// easier and more intuitive.
  ///
  /// [doc] is the Firestore `DocumentSnapshot` that contains the data to be deserialized.
  static UserProfileData? fromMap(DocumentSnapshot doc) {
    Map<String, dynamic>? map = doc.data() as Map<String, dynamic>?;

    if (map == null) {
      // Handle the case where the document doesn't contain data as expected
      return null;
    }

    return UserProfileData(
      id: doc.id,
      userType: map['userType'],
      listOfOfferingProfessionalServices:
          (map['listOfOfferingProfessionalServices'] as List<dynamic>?)
              ?.map((serviceData) => ProfessionalService.fromMap(serviceData))
              .toList(),
      userAbout: map['userAbout'],
      userRating: map['userRating'],
      imagePath: map['imagePath'],
        emailAddress: map['emailAddress'],
      mobilePhoneNumber: map['mobilePhoneNumber'],
      // fcmToken: map['fcmToken'] ?? '' // Retrieve fcmToken, default to empty string if not found
    );
  }
}
