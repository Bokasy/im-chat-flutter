class MessageModel {
  final int? id;
  final String? msgId;
  final int? senderId;
  final String? senderName;
  final String? senderAvatar;
  final int? receiverId;
  final int? chatType;
  final int? msgType;
  final String? content;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? replyMsgId;
  final String? replyContent;
  final String? atUserIds;
  final int? isRecalled;
  final int? isRead;
  final int? seqId;
  final String? createTime;

  MessageModel({
    this.id,
    this.msgId,
    this.senderId,
    this.senderName,
    this.senderAvatar,
    this.receiverId,
    this.chatType,
    this.msgType,
    this.content,
    this.mediaUrl,
    this.thumbnailUrl,
    this.replyMsgId,
    this.replyContent,
    this.atUserIds,
    this.isRecalled,
    this.isRead,
    this.seqId,
    this.createTime,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      msgId: json['msgId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderAvatar: json['senderAvatar'],
      receiverId: json['receiverId'],
      chatType: json['chatType'],
      msgType: json['msgType'],
      content: json['content'],
      mediaUrl: json['mediaUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      replyMsgId: json['replyMsgId'],
      replyContent: json['replyContent'],
      atUserIds: json['atUserIds'],
      isRecalled: json['isRecalled'],
      isRead: json['isRead'],
      seqId: json['seqId'],
      createTime: json['createTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'msgId': msgId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'receiverId': receiverId,
      'chatType': chatType,
      'msgType': msgType,
      'content': content,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'replyMsgId': replyMsgId,
      'replyContent': replyContent,
      'atUserIds': atUserIds,
      'isRecalled': isRecalled,
      'isRead': isRead,
      'seqId': seqId,
      'createTime': createTime,
    };
  }
}
