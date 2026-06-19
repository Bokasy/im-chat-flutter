class UserModel {
  final int? id;
  final String? username;
  final String? userCode;
  final String? nickname;
  final String? avatar;
  final String? signature;
  final int? status;
  final String? lastLoginTime;

  UserModel({
    this.id,
    this.username,
    this.userCode,
    this.nickname,
    this.avatar,
    this.signature,
    this.status,
    this.lastLoginTime,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      userCode: json['userCode'],
      nickname: json['nickname'],
      avatar: json['avatar'],
      signature: json['signature'],
      status: json['status'],
      lastLoginTime: json['lastLoginTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'userCode': userCode,
      'nickname': nickname,
      'avatar': avatar,
      'signature': signature,
      'status': status,
      'lastLoginTime': lastLoginTime,
    };
  }
}
