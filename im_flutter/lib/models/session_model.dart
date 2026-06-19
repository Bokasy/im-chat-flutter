class SessionModel {
  final int? id;
  final int? targetId;
  final String? targetName;
  final String? targetAvatar;
  final int? chatType;
  final String? lastMsgContent;
  final String? lastMsgTime;
  final int? unreadCount;
  final int? isPinned;
  final int? isMuted;
  final int? onlineStatus;

  SessionModel({
    this.id,
    this.targetId,
    this.targetName,
    this.targetAvatar,
    this.chatType,
    this.lastMsgContent,
    this.lastMsgTime,
    this.unreadCount,
    this.isPinned,
    this.isMuted,
    this.onlineStatus,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'],
      targetId: json['targetId'],
      targetName: json['targetName'],
      targetAvatar: json['targetAvatar'],
      chatType: json['chatType'],
      lastMsgContent: json['lastMsgContent'],
      lastMsgTime: json['lastMsgTime'],
      unreadCount: json['unreadCount'],
      isPinned: json['isPinned'],
      isMuted: json['isMuted'],
      onlineStatus: json['onlineStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetId': targetId,
      'targetName': targetName,
      'targetAvatar': targetAvatar,
      'chatType': chatType,
      'lastMsgContent': lastMsgContent,
      'lastMsgTime': lastMsgTime,
      'unreadCount': unreadCount,
      'isPinned': isPinned,
      'isMuted': isMuted,
      'onlineStatus': onlineStatus,
    };
  }
}
