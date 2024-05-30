import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class ConversationSnippet {
  final String id;
  final String conversationID;
  final String lastMessage;
  final String name;
  final String image;
  final MessageType type;
  final int unseenCount;
  final Timestamp timestamp;

  ConversationSnippet({
    required this.conversationID,
    required this.id,
    required this.lastMessage,
    required this.unseenCount,
    required this.timestamp,
    required this.name,
    required this.image,
    this.type = MessageType.Text,
  });

  factory ConversationSnippet.fromFirestore(DocumentSnapshot<Object?> snapshot) {
    var data = snapshot.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data not available");
    }

    var messageType = data["type"] != null ? _messageTypeFromString(data["type"]) : MessageType.Text;
    return ConversationSnippet(
      id: snapshot.id,
      conversationID: data["conversationID"] ?? "",
      lastMessage: data["lastMessage"] ?? "",
      unseenCount: data["unseenCount"] ?? 0,
      timestamp: data["timestamp"] ?? Timestamp.now(),
      name: data["name"] ?? "",
      image: data["image"] ?? "",
      type: messageType,
    );
  }

  static MessageType _messageTypeFromString(String type) {
    switch (type) {
      case "text":
        return MessageType.Text;
      case "image":
        return MessageType.Image;
      default:
        return MessageType.Text;
    }
  }
}

class Conversation {
  final String id;
  final List<String> members;
  final List<Message> messages;
  final String ownerID;

  Conversation({
    required this.id,
    required this.members,
    required this.messages,
    required this.ownerID,
  });

  factory Conversation.fromFirestore(DocumentSnapshot<Object?> snapshot) {
    var data = snapshot.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data not available");
    }

    List<Message> messages = [];
    if (data["messages"] != null) {
      messages = (data["messages"] as List<dynamic>)
          .map((m) => Message(
        type: _messageTypeFromString(m["type"]),
        content: m["message"],
        timestamp: m["timestamp"],
        senderID: m["senderID"],
      ))
          .toList();
    }

    return Conversation(
      id: snapshot.id,
      members: List<String>.from(data["members"] ?? []),
      messages: messages,
      ownerID: data["ownerID"] ?? "",
    );
  }

  static MessageType _messageTypeFromString(String type) {
    switch (type) {
      case "text":
        return MessageType.Text;
      case "image":
        return MessageType.Image;
      default:
        return MessageType.Text;
    }
  }
}
