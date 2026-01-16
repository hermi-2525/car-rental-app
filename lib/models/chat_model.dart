import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames; // Map userId -> name
  final Map<String, String> participantEmails; // Map userId -> email
  final String initiatorId; // The renter who started the chat
  final String ownerId; // The car owner being contacted
  final String lastMessage;
  final DateTime lastMessageTime;

  Chat({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.participantEmails,
    required this.initiatorId,
    required this.ownerId,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory Chat.fromMap(Map<String, dynamic> data, String id) {
    return Chat(
      id: id,
      participants: List<String>.from(data['participants'] ?? []),
      participantNames: Map<String, String>.from(
        data['participantNames'] ?? {},
      ),
      participantEmails: Map<String, String>.from(
        data['participantEmails'] ?? {},
      ),
      initiatorId: data['initiatorId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime:
          (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class ChatMessage {
  final String senderId;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    return ChatMessage(
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
