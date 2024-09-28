import 'dart:math';

import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key, required this.currentUser});
  UserModel currentUser;
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _emailController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetuser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where('participants.${widget.currentUser.uid}', isEqualTo: true)
        .where('participants.${targetuser.uid}', isEqualTo: true)
        .get();
    if (snapshot.docs.length > 0) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel chatRoomModel =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = chatRoomModel;
    } else {
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatRoomId: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.currentUser.uid.toString(): true,
          targetuser.uid.toString(): true,
        },
        users: [widget.currentUser.uid.toString(), targetuser.uid.toString()],
        createdAt: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(newChatRoom.chatRoomId)
          .set(newChatRoom.toMap());
      chatRoom = newChatRoom;
    }
    return chatRoom;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 149, 87, 148),
        centerTitle: true,
        title: const Text('Search'),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                  ),
                ),
              ),
              CupertinoButton(
                child: const Text('Search'),
                onPressed: () {
                  setState(() {});
                },
                color: Colors.brown,
              ),
              const SizedBox(height: 30),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where("email", isEqualTo: _emailController.text)
                    .where("email",
                        isNotEqualTo: FirebaseAuth.instance.currentUser!.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('An error occurred'),
                    );
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!;
                    if (data.docs.isNotEmpty) {
                      Map<String, dynamic> userMap =
                          data.docs[0].data() as Map<String, dynamic>;
                      UserModel searchedUser = UserModel.fromMap(userMap);
                      return ListTile(
                        onTap: () async {
                          // navigate to user profile
                          ChatRoomModel? chatRoomModel =
                              await getChatRoomModel(searchedUser);
                          if (chatRoomModel != null) {
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MessageBubble(
                                  targetUser: searchedUser,
                                  currentUser: widget.currentUser,
                                  chatRoom: chatRoomModel,
                                ),
                              ),
                            );
                          }
                        },
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(searchedUser.profilePic ?? ''),
                        ),
                        title: Text(searchedUser.fullname ?? 'No name'),
                        subtitle: Text(searchedUser.email ?? 'No email'),
                        trailing: IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () {
                            // navigate to chat screen
                          },
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text(''),
                      );
                    }
                  } else {
                    return const Center(
                      child: Text('No data'),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
