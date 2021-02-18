import 'dart:convert';

class Chat {
  final String orderId;
  final String messengerNotifToken;
  final String userNotifToken;
  List<Message> messages;
  Chat({
    this.orderId,
    this.messages,
    this.messengerNotifToken,
    this.userNotifToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'messages': messages?.map((x) => x?.toMap())?.toList(),
      'messengerNotifToken': messengerNotifToken,
      'userNotifToken': userNotifToken,
      
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Chat(
      orderId: map['orderId'],
      messages: map['messages'] != null
          ? List<Message>.from(map['messages']?.map((x) => Message.fromMap(x)))
          : null,
      userNotifToken: map['userNotifToken'],
      messengerNotifToken: map['messengerNotifToken'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Chat.fromJson(String source) => Chat.fromMap(json.decode(source));

  @override
  String toString() => 'Chat(orderId: $orderId, messages: $messages)';
}

class Message {
  String messageId;
  ChatRole sender;
  String message;
  MessageType type;
  int sendingTime;
  PaymentStatus paymentStatus;

  Message({
    this.sender,
    this.message,
    this.type,
    this.sendingTime,
    this.paymentStatus,
    this.messageId,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender': sender?.index,
      'message': message,
      'type': type?.index,
      'sendingTime': sendingTime,
      'paymentStatus': paymentStatus?.index,
      'messageId': messageId,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Message(
      sender: ChatRole.values[(map['sender'])],
      message: map['message'],
      type: MessageType.values[(map['type'])],
      sendingTime: map['sendingTime'],
      paymentStatus: PaymentStatus.values[map['paymentStatus']],
      messageId: map['messageId'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source));
}

enum MessageType {
  text,
  image,
  money,
}

enum ChatRole {
  user,
  messenger,
}

enum PaymentStatus {
  none,
  requested,
  accepted,
  completed,
  failed,
}
