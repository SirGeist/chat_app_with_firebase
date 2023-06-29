import 'package:chat_app_with_firebase/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    // Listen to a stream of messages so when a new message is submitted
    // it is automatically loaded and displayed here
    return StreamBuilder(
      // Orderby ensures that the latest messages are displayed at the bottom
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        // If chat snapshot is loading, we want to see a circular progress bar spinning
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Checking to see if we don't have data or we have data but it is an empty
        // list to show "No message found"
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found.'),
          );
        }

        // If we have an error, display an error message
        if (chatSnapshots.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }

        // We know its not null because it passed the if checks
        // We use this later to get the items count
        final loadedMessages = chatSnapshots.data!.docs;

        // Building the list of sent messages
        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 13,
            right: 13,
          ),
          // Making the list of messages at the bottom
          reverse: true,
          itemCount: loadedMessages.length,

          // We access the map of the loadedMessages to display our chat messages
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index].data();

            // Checking to see if our index is greater than the list, meaning that if
            // it is smaller, than there is another message after it and vice versa
            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;

            final currentMessageUsernameId = chatMessage['userId'];
            final nextMessageUsernameId =
                nextChatMessage != null ? nextChatMessage['userId'] : null;
            final nextUserIsSame =
                nextMessageUsernameId == currentMessageUsernameId;

            // If next user is the same as current user
            // Changing the style of the setting based on if the currentUser is the same
            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUsernameId,
              );
            } 
            // If the current user is not the same, change message color
            else {
              return MessageBubble.first(
                  userImage: chatMessage['userImage'],
                  username: chatMessage['username'],
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid == currentMessageUsernameId);
            }
          },
        );
      },
    );
  }
}
