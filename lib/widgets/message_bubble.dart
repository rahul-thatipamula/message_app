import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/messaage_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/widgets/new_messsage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// A MessageBubble for showing a single chat message on the ChatScreen.
class MessageBubble extends StatefulWidget {
  // Create a message bubble which is meant to be the first in the sequence.

  final UserModel targetUser;
  final UserModel currentUser;
  final ChatRoomModel chatRoom;

  MessageBubble({
    super.key,
    required this.targetUser,
    required this.currentUser,
    required this.chatRoom,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  // final user = FirebaseAuth.instance.currentUser;
  final messageController = TextEditingController();
  // Create a amessage bubble that continues the sequence.
  void sendMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty) {
      return;
    }
    final chatRoomId = widget.chatRoom.chatRoomId;

    MessaageModel newMessage = MessaageModel(
      messageId: uuid.v1(),
      sender: widget.currentUser!.uid,
      time: DateTime.now(),
      text: message,
      seen: false,
    );
    FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(newMessage.messageId)
        .set(newMessage.toMap());
    messageController.clear();

    widget.chatRoom.lastMessage = message;
    FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .set(widget.chatRoom.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.targetUser.profilePic!),
            ),
            SizedBox(
              width: 20,
            ),
            Text(widget.targetUser.fullname!),
          ],
        ),
      ),
      body: Container(
        child: Column(children: [
          Expanded(
            child: Container(
                color: Colors.black12,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chatrooms')
                      .doc(widget.chatRoom.chatRoomId)
                      .collection('messages')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot chatMessages =
                            snapshot.data as QuerySnapshot;
                        print("Messages: ${chatMessages.docs.length}");
                        return ListView.builder(
                          reverse: true,
                          itemCount: chatMessages.docs.length,
                          itemBuilder: (context, index) {
                            MessaageModel currentMessage =
                                MessaageModel.fromMap(chatMessages.docs[index]
                                    .data() as Map<String, dynamic>);
                            print("Current Message: ${currentMessage.text}");

                            return Row(
                              mainAxisAlignment: currentMessage.sender ==
                                      widget.currentUser!.uid
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 6, right: 10),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: currentMessage.sender ==
                                            widget.currentUser!.uid
                                        ? Colors.white
                                        : Colors.green,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    currentMessage.text!,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Something went wrong'));
                      } else {
                        return Center(child: Text('Say hi to your new friend'));
                      }
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                )),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: TextField(
                    maxLines: null,
                    controller: messageController,
                    decoration: InputDecoration(labelText: 'Send a message...'),
                  ),
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
