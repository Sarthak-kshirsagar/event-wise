import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatInputField extends StatefulWidget {
  final String organizerId;
  final String eventId;

  const ChatInputField({required this.organizerId, required this.eventId});

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;

    final eventQuery = await FirebaseFirestore.instance
        .collection('Organizers')
        .doc(widget.organizerId)
        .collection('Events')
        .where('id', isEqualTo: widget.eventId)
        .limit(1)
        .get();

    if (eventQuery.docs.isEmpty) return;

    final eventDocId = eventQuery.docs.first.id;

    await FirebaseFirestore.instance
        .collection('Organizers')
        .doc(widget.organizerId)
        .collection('Events')
        .doc(eventDocId)
        .collection('Chats')
        .add({
      'text': text,
      'senderId': currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Send a message...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: _sendMessage,
            )
          ],
        ),
      ),
    );
  }
}
