import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/professional_service.dart';

/// A service class that provides methods to perform CRUD operations
/// on user's cars stored in Firestore.
class ProfessionalServiceController {
  /// The currently authenticated user from Firebase.
  final user = FirebaseAuth.instance.currentUser;

  /// A reference to the Firestore collection where the cars for
  /// the current user are stored.
  final CollectionReference professionalServiceCollection;

  /// Constructor initializes the reference to the Firestore collection
  /// specific to the current user's car details.
  ProfessionalServiceController():
    professionalServiceCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('professional_services');

  /// Adds a new diary entry to Firestore and returns the document reference.
  Future<bool> addProfessionalService(ProfessionalService professionalServiceEntry) async {
    bool shouldAdd = true;

    final snapshot =
    await getAllProfessionalServices().first; // Wait for the first snapshot

    for (ProfessionalService professionalService in snapshot) {
      //add new only if the category already doesnt exist for the user
      if (professionalService.category == professionalServiceEntry.category) {
        shouldAdd = false;
        break;
      }
    }

    if (shouldAdd) {
      await professionalServiceCollection.add(professionalServiceEntry.toMap());
    }
    return shouldAdd;
  }

  /// Updates details of an existing [professionalService] in Firestore.
  Future<void> updateProfessionalService(ProfessionalService professionalService) async {
    return await professionalServiceCollection.doc(professionalService.category).update(professionalService.toMap());
  }

  /// Deletes a car with the specified [id] from Firestore.
  Future<void> deleteProfessionalService(String? id) async {
    return await professionalServiceCollection.doc(id).delete();
  }

  /// Retrieves a stream of a list of `profesiional services` objects associated
  /// with the current user from Firestore with specific category.
  Stream<List<ProfessionalService>> getProfessionalServices(String CategoryNameToRetrieve) {
    return professionalServiceCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProfessionalService.fromMap(doc.data() as Map<String, dynamic>))
          .where((service) => service.category == CategoryNameToRetrieve)
          .toList();
    });
  }

  Stream<List<ProfessionalService>> getAllProfessionalServices() {
    return professionalServiceCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProfessionalService.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

}
