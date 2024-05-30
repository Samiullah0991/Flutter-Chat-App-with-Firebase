import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String email;
  final String image;
  final Timestamp lastseen;
  final String name;

  Contact({
    required this.id,
    required this.email,
    required this.name,
    required this.image,
    required this.lastseen,
  });

  factory Contact.fromFirestore(DocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data not available");
    }

    return Contact(
      id: snapshot.id,
      lastseen: data["lastSeen"] ?? Timestamp.now(),
      email: data["email"] ?? "",
      name: data["name"] ?? "",
      image: data["image"] ?? "",
    );
  }
}
