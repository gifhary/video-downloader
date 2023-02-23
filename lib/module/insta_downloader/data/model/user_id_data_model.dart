import 'dart:convert';

class UserIdDataModel {
  final bool showQRModal;
  final InstaUser user;
  UserIdDataModel({
    required this.showQRModal,
    required this.user,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'showQRModal': showQRModal,
      'user': user.toMap(),
    };
  }

  factory UserIdDataModel.fromMap(Map<String, dynamic> map) {
    return UserIdDataModel(
      showQRModal: map['showQRModal'] as bool,
      user: InstaUser.fromMap(map['user'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserIdDataModel.fromJson(String source) =>
      UserIdDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'UserIdDataModel(showQRModal: $showQRModal, user: $user)';
}

class InstaUser {
  final String id;
  final String profilePicUrl;
  final String username;
  InstaUser({
    required this.id,
    required this.profilePicUrl,
    required this.username,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'profile_pic_url': profilePicUrl,
      'username': username,
    };
  }

  factory InstaUser.fromMap(Map<String, dynamic> map) {
    return InstaUser(
      id: map['id'] as String,
      profilePicUrl: map['profile_pic_url'] as String,
      username: map['username'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory InstaUser.fromJson(String source) =>
      InstaUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'InstaUser(id: $id, profile_pic_url: $profilePicUrl, username: $username)';
}
