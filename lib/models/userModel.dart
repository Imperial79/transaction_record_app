// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  String username = '';
  String email = '';
  String name = '';
  String uid = '';
  String imgUrl = '';
  UserModel({
    required this.username,
    required this.email,
    required this.name,
    required this.uid,
    required this.imgUrl,
  });

  UserModel copyWith({
    String? username,
    String? email,
    String? name,
    String? uid,
    String? imgUrl,
  }) {
    return UserModel(
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      uid: uid ?? this.uid,
      imgUrl: imgUrl ?? this.imgUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'email': email,
      'name': name,
      'uid': uid,
      'imgUrl': imgUrl,
    };
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      username: map['username'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      uid: map['uid'] as String,
      imgUrl: map['imgUrl'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(username: $username, email: $email, name: $name, uid: $uid, imgUrl: $imgUrl)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.username == username &&
        other.email == email &&
        other.name == name &&
        other.uid == uid &&
        other.imgUrl == imgUrl;
  }

  @override
  int get hashCode {
    return username.hashCode ^
        email.hashCode ^
        name.hashCode ^
        uid.hashCode ^
        imgUrl.hashCode;
  }
}
