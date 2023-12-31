import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    // Always dispose controllers to make sure that the memory that is being used
    // by the controllers get used up

    _messageController.dispose();
    super.dispose();
  }

  // Reading the entered value after the button for the message is pressed
  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    // Validation
    if (enteredMessage.trim().isEmpty) {
      return;
    }

    // Closing the keyboard immediately
    FocusScope.of(context).unfocus();

    // Making sure that text field becomes empty after a message has been submitted
    _messageController.clear();
    // Should not be null because unauthenticated users can't
    // reach this part
    final user = FirebaseAuth.instance.currentUser!;

    // Contains username and image from firebase
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // Sending to firebase
    // Automatically generated uid created by firebase
    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,

      // Variables were retrieved from firestore
      // Remember that userData information was created in auth.dart
      // that's how we get username and image_url
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });


    


    
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 1,
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            icon: const Icon(
              Icons.send,
            ),
            onPressed: _submitMessage,
          ),
        ],
      ),
    );
  }
}
