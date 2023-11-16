import 'package:uuid/uuid.dart';

class ProfessionalService {
  // String id = Uuid().v4();
  String? id;
  String category;
  String serviceDescription;
  int? rating = 5;
  double? wage;
  String location;

//TODO: MAYBE ADD SOME INFO of the service technician that can be displayed on add cards
  ProfessionalService(
      {required this.category,
      required this.serviceDescription,
      required this.location,
      this.wage,
      this.rating,
      this.id}) {
    id = id ?? Uuid().v4();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'serviceDescription': serviceDescription,
      'wage': wage,
      'rating': rating,
      'location' : location
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
        location: map['location']);
  }
}
