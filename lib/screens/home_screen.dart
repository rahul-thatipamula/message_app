import 'dart:developer';

import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/firebase_helper.dart';
// import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:chat_app/screens/auth.dart';
import 'package:chat_app/screens/splash.dart';
import 'package:chat_app/widgets/message_bubble.dart';
// import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key, required this.userData});
  UserModel userData;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        title: const Text('Message App'),
        backgroundColor: const Color.fromARGB(255, 149, 87, 148),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Sign out the Firebase user
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return AuthScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chatrooms')
              .where("users", arrayContains: widget.userData.uid)
              .orderBy('createdAt')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SplashScreen(),
              );
            } else if (snapshot.connectionState == ConnectionState.active &&
                !snapshot.hasData) {
              return const Center(
                child: Text('No chat rooms available'),
              );
            } else {
              if (snapshot.hasData) {
                QuerySnapshot? chatRoomsSnapshot =
                    snapshot.data as QuerySnapshot?;

                return ListView.builder(
                    itemCount: chatRoomsSnapshot!.docs.length,
                    itemBuilder: (context, index) {
                      final chatRoom = chatRoomsSnapshot.docs[index];
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          chatRoom.data() as Map<String, dynamic>);

                      Map<String, dynamic> participants =
                          chatRoomModel.participants!;
                      List<String> participantKeys = participants.keys.toList();

                      // Remove current user's ID to get the target user(s)
                      participantKeys.remove(widget.userData.uid);

                      if (participantKeys.isEmpty) {
                        return const Center(
                          child: Text('No target user found'),
                        );
                      }

                      // Debugging the participant keys
                      print(
                          "Remaining participant (targetUser): ${participantKeys[0]}");

                      return Column(
                        children: [
                          FutureBuilder(
                            future: FirebaseHelper.getUserModelById(
                                participantKeys[0]),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: SplashScreen(),
                                );
                              } else if (userSnapshot.hasData) {
                                if (userSnapshot.data == null) {
                                  return const Center(
                                    child: Text('User not found'),
                                  );
                                }
                                UserModel targetUser =
                                    userSnapshot.data as UserModel;

                                return ListTile(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                        return MessageBubble(
                                            targetUser: targetUser,
                                            currentUser: widget.userData,
                                            chatRoom: chatRoomModel);
                                      }),
                                    );
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        targetUser.profilePic.toString()),
                                  ),
                                  title: Text(targetUser.fullname.toString()),
                                  subtitle: chatRoomModel
                                          .lastMessage!.isNotEmpty
                                      ? Text(
                                          chatRoomModel.lastMessage.toString())
                                      : const Text(
                                          'Say hello to your friend',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                );
                              } else {
                                return const Center(
                                  child: Text('User not found'),
                                );
                              }
                            },
                          ),
                          const Divider(
                            thickness: 1,
                            indent: 13,
                            endIndent: 13,
                          ),
                        ],
                      );
                    });
              } else {
                return const Center(
                  child: Text('No chat rooms available'),
                );
              }
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SearchPage(
                currentUser: widget.userData,
              ),
            ),
          );
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
