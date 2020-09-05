import 'dart:convert';

import 'app_messenger.dart';


enum OrderStatus {
  notStarted, // scheduled but there is some time left
  findingMessenger, // scheduled time has come, now finding a messenger
  findingMessengerFailed, // finding failed
  messengerOnWay, // finding success, messenger on the way
  messengerReachedSource,
  messengerReachedDestination,
  orderCompleted,
  orderCancelled,
}

class Order {
  String orderId;
  OrderStatus status;
  String userUid;
  AppMessenger messenger;
  String messengerName;
  double rating;
  String instruction;
  String ratingComment;
  double sourceLat;
  double sourceLng;
  String sourceLocationName;
  double destLat;
  double destlng;
  String destLocationName;
  int creationTime;
  int scheduledTime;
  int completedTime;
  Order({
    this.orderId,
    this.status,
    this.userUid,
    this.messenger,
    this.messengerName,
    this.rating,
    this.instruction,
    this.ratingComment,
    this.sourceLat,
    this.sourceLng,
    this.sourceLocationName,
    this.destLat,
    this.destlng,
    this.destLocationName,
    this.creationTime,
    this.scheduledTime,
    this.completedTime,
  });
  

  Order copyWith({
    String orderId,
    String userUid,
    AppMessenger messenger,
    String messengerName,
    double rating,
    String instruction,
    String ratingComment,
    double sourceLat,
    double sourceLng,
    String sourceLocationName,
    double destLat,
    double destlng,
    String destLocationName,
    int creationTime,
    int scheduledTime,
    int completedTime,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      userUid: userUid ?? this.userUid,
      messenger: messenger ?? this.messenger,
      messengerName: messengerName ?? this.messengerName,
      rating: rating ?? this.rating,
      instruction: instruction ?? this.instruction,
      ratingComment: ratingComment ?? this.ratingComment,
      sourceLat: sourceLat ?? this.sourceLat,
      sourceLng: sourceLng ?? this.sourceLng,
      sourceLocationName: sourceLocationName ?? this.sourceLocationName,
      destLat: destLat ?? this.destLat,
      destlng: destlng ?? this.destlng,
      destLocationName: destLocationName ?? this.destLocationName,
      creationTime: creationTime ?? this.creationTime,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      completedTime: completedTime ?? this.completedTime,
    );
  }

  Map<String, dynamic> toMap() {

    return {
      'orderId': orderId,
      'orderStatus' : status.index,
      'userUid': userUid,
      'messenger': messenger?.toMap(),
      'messengerName': messengerName,
      'rating': rating,
      'instruction': instruction,
      'ratingComment': ratingComment,
      'sourceLat': sourceLat,
      'sourceLng': sourceLng,
      'sourceLocationName': sourceLocationName,
      'destLat': destLat,
      'destlng': destlng,
      'destLocationName': destLocationName,
      'creationTime': creationTime,
      'scheduledTime': scheduledTime,
      'completedTime': completedTime,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return Order(
      status: OrderStatus.values[map['orderStatus']],
      orderId: map['orderId'],
      userUid: map['userUid'],
      messenger: AppMessenger.fromMap(map['messenger']),
      messengerName: map['messengerName'],
      rating: map['rating'],
      instruction: map['instruction'],
      ratingComment: map['ratingComment'],
      sourceLat: map['sourceLat'],
      sourceLng: map['sourceLng'],
      sourceLocationName: map['sourceLocationName'],
      destLat: map['destLat'],
      destlng: map['destlng'],
      destLocationName: map['destLocationName'],
      creationTime: map['creationTime'],
      scheduledTime: map['scheduledTime'],
      completedTime: map['completedTime'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Order(orderId: $orderId, userUid: $userUid, messenger: $messenger, messengerName: $messengerName, rating: $rating, instruction: $instruction, ratingComment: $ratingComment, sourceLat: $sourceLat, sourceLng: $sourceLng, sourceLocationName: $sourceLocationName, destLat: $destLat, destlng: $destlng, destLocationName: $destLocationName, creationTime: $creationTime, scheduledTime: $scheduledTime, completedTime: $completedTime)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
  
    return o is Order &&
      o.orderId == orderId &&
      o.userUid == userUid &&
      o.messenger == messenger &&
      o.messengerName == messengerName &&
      o.rating == rating &&
      o.instruction == instruction &&
      o.ratingComment == ratingComment &&
      o.sourceLat == sourceLat &&
      o.sourceLng == sourceLng &&
      o.sourceLocationName == sourceLocationName &&
      o.destLat == destLat &&
      o.destlng == destlng &&
      o.destLocationName == destLocationName &&
      o.creationTime == creationTime &&
      o.scheduledTime == scheduledTime &&
      o.completedTime == completedTime;
  }

  @override
  int get hashCode {
    return orderId.hashCode ^
      userUid.hashCode ^
      messenger.hashCode ^
      messengerName.hashCode ^
      rating.hashCode ^
      instruction.hashCode ^
      ratingComment.hashCode ^
      sourceLat.hashCode ^
      sourceLng.hashCode ^
      sourceLocationName.hashCode ^
      destLat.hashCode ^
      destlng.hashCode ^
      destLocationName.hashCode ^
      creationTime.hashCode ^
      scheduledTime.hashCode ^
      completedTime.hashCode;
  }
}
