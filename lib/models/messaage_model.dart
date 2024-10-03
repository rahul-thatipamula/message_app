import 'package:cloud_firestore/cloud_firestore.dart';

class MessaageModel {
  String? sender;
  String? text;
  DateTime? time;
  String? messageId;

  MessaageModel({this.messageId, this.sender, this.text, this.time});

  MessaageModel.fromMap(Map<String, dynamic> data) {
    messageId = data['messageId'];
    sender = data['sender'];
    text = data['text'];
    time:
    (data['time'] as Timestamp).toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'sender': sender,
      'text': text,
      'time': Timestamp.fromDate(time!),
    };
  }
}
