import 'dart:convert';

class AppUser {
  String uid;
  String name;
  String email;
  String photoUrl;
  String token;
  AppUser({
    this.uid,
    this.name,
    this.email,
    this.photoUrl,
    this.token,
  });
  

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'token': token,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return AppUser(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      token: map['token'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AppUser.fromJson(String source) => AppUser.fromMap(json.decode(source));
}
