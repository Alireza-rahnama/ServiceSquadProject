class ProfessionalService {
  String category;
  String serviceDescription;
  var wage;

  ProfessionalService({required this.category, required this.serviceDescription, this.wage});

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'serviceDescription': serviceDescription,
      'wage' : wage
    };
  }

  static ProfessionalService fromMap(Map<String, dynamic> map) {
    return ProfessionalService(
      category: map['category'],
        serviceDescription: map['serviceDescription'],
      wage: map['wage'].toDouble()
    );
  }
}
