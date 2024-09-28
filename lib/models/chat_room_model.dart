class ChatRoomModel {
  String? chatRoomId;
  Map<String, dynamic>? participants;
  String? lastMessage;
  List<dynamic>? users;

  DateTime? createdAt;
  ChatRoomModel(
      {this.chatRoomId,
      this.participants,
      this.createdAt,
      this.lastMessage,
      this.users});
  ChatRoomModel.fromMap(Map<String, dynamic> data) {
    chatRoomId = data['chatRoomId'];
    participants = data['participants'];
    lastMessage = data['lastMessage'];
    users = data['users'];
    createdAt = data['createdAt'] != null ? (data['createdAt']).toDate() : null;
  }

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'participants': participants,
      'lastMessage': lastMessage,
      'users': users,
      'createdAt': createdAt,
    };
  }
}
