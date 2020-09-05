import 'dart:convert';

class AppMessenger {
  String uid;
  String name;
  String photoUrl;
  String phoneNo;
  String token;
  num rating;
  int totalRides;
  num currentLat;
  num currentLng;
  AppMessenger({
    this.uid,
    this.name,
    this.photoUrl,
    this.phoneNo,
    this.token,
    this.rating,
    this.totalRides,
    this.currentLat,
    this.currentLng,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'photoUrl': photoUrl,
      'phoneNo': phoneNo,
      'token': token,
      'rating': rating,
      'totalRides': totalRides,
      'currentLat': currentLat,
      'currentLng': currentLng,
    };
  }

  factory AppMessenger.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return AppMessenger(
      uid: map['uid'],
      name: map['name'],
      photoUrl: map['photoUrl'],
      phoneNo: map['phoneNo'],
      token: map['token'],
      rating: map['rating'],
      totalRides: map['totalRides'],
      currentLat: map['currentLat'],
      currentLng: map['currentLng'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AppMessenger.fromJson(String source) =>
      AppMessenger.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AppMessenger(uid: $uid, name: $name, photoUrl: $photoUrl, phoneNo: $phoneNo, token: $token, rating: $rating, totalRides: $totalRides, currentLat: $currentLat, currentLng: $currentLng)';
  }
}
