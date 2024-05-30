import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/contact.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class DBService {
  static DBService instance = DBService();

  FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _userCollection = "Users";
  final String _conversationsCollection = "Conversations";

  DBService();

  Future<void> createUserInDB(
      String uid,
      String name,
      String email,
      String imageURL,
      ) async {
    try {
      await _db.collection(_userCollection).doc(uid).set({
        "name": name,
        "email": email,
        "image": imageURL ?? "",
        "lastSeen": Timestamp.fromDate(DateTime.now().toUtc()),
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> updateUserLastSeenTime(String userID) {
    var ref = _db.collection(_userCollection).doc(userID);
    return ref.update({"lastSeen": Timestamp.fromDate(DateTime.now().toUtc())}); // Use update instead of updateData
  }

  Future<void> sendMessage(String conversationID, Message message) {
    var ref = _db.collection(_conversationsCollection).doc(conversationID);
    var messageType = message.type.name;
    return ref.update({
      "messages": FieldValue.arrayUnion(
        [
          {
            "message": message.content,
            "senderID": message.senderID,
            "timestamp": message.timestamp,
            "type": messageType,
          },
        ],
      ),
    });
  }

  Future<void> createOrGetConversation(
      String currentID,
      String recipientID,
      Future<void> onSuccess(String conversationID),
      ) async {
    var ref = _db.collection(_conversationsCollection);
    var userConversationRef = _db
        .collection(_userCollection)
        .doc(currentID) // Changed from document to doc
        .collection(_conversationsCollection);
    try {
      var conversation = await userConversationRef.doc(recipientID).get(); // Changed from document to doc
      if (conversation.data() != null) { // Changed from data to data()
        return onSuccess(conversation.data()!["conversationID"]); // Changed from data to data()
      } else {
        var conversationRef = ref.doc(); // Changed from document to doc
        await conversationRef.set({ // Changed from setData to set
          "members": [currentID, recipientID],
          "ownerID": currentID,
          'messages': [],
        });
        return onSuccess(conversationRef.id); // Changed from documentID to id
      }
    } catch (e) {
      print(e);
    }
  }

  Stream<Contact> getUserData(String userID) {
    var ref = _db.collection(_userCollection).doc(userID); // Changed from document to doc
    return ref.snapshots().map((snapshot) {
      return Contact.fromFirestore(snapshot);
    });
  }

  Stream<List<ConversationSnippet>> getUserConversations(String userID) {
    var ref = _db
        .collection(_userCollection)
        .doc(userID) // Changed from document to doc
        .collection(_conversationsCollection);
    return ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) { // Changed from documents to docs
        return ConversationSnippet.fromFirestore(doc);
      }).toList();
    });
  }

  Stream<List<Contact>> getUsersInDB(String searchName) {
    if (searchName == null || searchName.isEmpty) {
      return Stream.value([]);
    }
    var ref = _db
        .collection(_userCollection)
        .where("name", isGreaterThanOrEqualTo: searchName)
        .where("name", isLessThan: searchName + 'z');
    return ref.get().asStream().map((snapshot) { // Changed from getDocuments to get
      return snapshot.docs.map((doc) { // Changed from documents to docs
        return Contact.fromFirestore(doc);
      }).toList();
    });
  }

  Stream<Conversation> getConversation(String conversationID) {
    var ref = _db.collection(_conversationsCollection).doc(conversationID); // Changed from document to doc
    return ref.snapshots().map(
          (doc) {
        return Conversation.fromFirestore(doc);
      },
    );
  }
}
