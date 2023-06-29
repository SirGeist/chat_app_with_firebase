import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to a stream of messages so when a new message is submitted
    // it is automatically loaded and displayed here
    return StreamBuilder(
      // Orderby ensures that the latest messages are displayed at the bottom
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: false,
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
          itemCount: loadedMessages.length,

          // We access the map of the loadedMessages to display our chat messages
          itemBuilder: (ctx, index) => Text(
            loadedMessages[index].data()['text'],
          ),
        );
      },
    );
  }
}
