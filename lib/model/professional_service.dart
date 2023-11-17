import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../controller/profile_controller.dart';

class ProfessionalService {
  // String id = Uuid().v4();
  String? id;
  String category;
  String serviceDescription;
  int? rating = 5;
  double? wage;
  String location;
  List<String?>? reviewList;
  String technicianAlias;
  String? imagePath;

//TODO: MAYBE ADD SOME INFO of the service technician that can be displayed on add cards
  ProfessionalService({
    required this.technicianAlias,
    required this.category,
    required this.serviceDescription,
    required this.location,
    this.wage,
    this.rating,
    this.id,
    this.reviewList,
    this.imagePath,
  }) {
    id = id ?? Uuid().v4();
    reviewList = reviewList?? [];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'serviceDescription': serviceDescription,
      'wage': wage,
      'rating': rating,
      'location': location,
      'reviewList': reviewList,
      'technicianAlias': technicianAlias,
      'imagePath': imagePath
    };
  }

  static ProfessionalService fromMap(Map<String, dynamic> map) {
    return ProfessionalService(
        id: map['id'],
        category: map['category'],
        serviceDescription: map['serviceDescription'],
        wage: map['wage']?.toDouble(),
        // Use null-aware operator to handle null values
        rating: map['rating']?.toInt(),
        location: map['location'],
        technicianAlias: map['technicianAlias']!,
        imagePath: map['imagePath'],
        reviewList: map['reviewList'] != null
            ? List<String?>.from(map['reviewList'])
            : []);
  }
}
