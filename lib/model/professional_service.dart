class ProfessionalService {
  String? id;
  String category;
  String serviceDescription;
  int? rating = 5;
  double? wage;

  ProfessionalService(
      {required this.category,
      required this.serviceDescription,
      this.wage,
      this.id,
      this.rating});

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'serviceDescription': serviceDescription,
      'wage': wage
    };
  }

  static ProfessionalService fromMap(Map<String, dynamic> map) {
    return ProfessionalService(
        id: map['id'],
        category: map['category'],
        serviceDescription: map['serviceDescription'],
        wage: map['wage'].toDouble());
  }
}
