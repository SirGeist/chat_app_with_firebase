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
  void _submitMessage(){
    final enteredMessage = _messageController.text;

    // Validation
    if(enteredMessage.trim().isEmpty){
      return;
    }

    // send to firebase

    // Making sure that text field becomes empty after a message has been submitted
    _messageController.clear();
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
