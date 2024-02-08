// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class KUser {
  String userName = '';
  String userEmail = '';
  String userDisplayName = '';
  String uid = '';
  String userProfilePic = '';
  KUser({
    required this.userName,
    required this.userEmail,
    required this.userDisplayName,
    required this.uid,
    required this.userProfilePic,
  });

  KUser copyWith({
    String? userName,
    String? userEmail,
    String? userDisplayName,
    String? uid,
    String? userProfilePic,
  }) {
    return KUser(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      uid: uid ?? this.uid,
      userProfilePic: userProfilePic ?? this.userProfilePic,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userName': userName,
      'userEmail': userEmail,
      'userDisplayName': userDisplayName,
      'uid': uid,
      'userProfilePic': userProfilePic,
    };
  }

  factory KUser.fromMap(Map<String, dynamic> map) {
    return KUser(
      userName: map['userName'] as String,
      userEmail: map['userEmail'] as String,
      userDisplayName: map['userDisplayName'] as String,
      uid: map['uid'] as String,
      userProfilePic: map['userProfilePic'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory KUser.fromJson(String source) =>
      KUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'KUser(userName: $userName, userEmail: $userEmail, userDisplayName: $userDisplayName, uid: $uid, userProfilePic: $userProfilePic)';
  }

  @override
  bool operator ==(covariant KUser other) {
    if (identical(this, other)) return true;

    return other.userName == userName &&
        other.userEmail == userEmail &&
        other.userDisplayName == userDisplayName &&
        other.uid == uid &&
        other.userProfilePic == userProfilePic;
  }

  @override
  int get hashCode {
    return userName.hashCode ^
        userEmail.hashCode ^
        userDisplayName.hashCode ^
        uid.hashCode ^
        userProfilePic.hashCode;
  }
}
