import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Organizers/chat_field.dart';
class EventChatScreenUser extends StatefulWidget {
  final String eventId;
  final String organizerId;


  EventChatScreenUser({required this.eventId,required this.organizerId});

  @override
  State<EventChatScreenUser> createState() => _EventChatScreenUserState();
}

class _EventChatScreenUserState extends State<EventChatScreenUser> {
  String? organizerDocId;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _getOrganizerDocId();
  }

  Future<void> _getOrganizerDocId() async {
    final organizerSnap = await FirebaseFirestore.instance
        .collection('Organizers')
        .where('id', isEqualTo: widget.organizerId)
        .limit(1)
        .get();

    if (organizerSnap.docs.isNotEmpty) {
      setState(() {
        organizerDocId = organizerSnap.docs.first.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (organizerDocId == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Organizers')
                  .where('id', isEqualTo: widget.organizerId)
                  .snapshots(),
              builder: (context, organizerSnapshot) {
                if (!organizerSnapshot.hasData) return Center(child: CircularProgressIndicator());
                if (organizerSnapshot.data!.docs.isEmpty) return Center(child: Text("Organizer not found"));

                final organizer = organizerSnapshot.data!.docs.first;

                return StreamBuilder<QuerySnapshot>(
                  stream: organizer.reference
                      .collection('Events')
                      .where('id', isEqualTo: widget.eventId)
                      .snapshots(),
                  builder: (context, eventSnapshot) {
                    if (!eventSnapshot.hasData) return Center(child: CircularProgressIndicator());
                    if (eventSnapshot.data!.docs.isEmpty) return Center(child: Text("Event not found"));

                    final event = eventSnapshot.data!.docs.first;

                    return StreamBuilder<QuerySnapshot>(
                      stream: event.reference
                          .collection('Chats')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, chatSnapshot) {
                        if (!chatSnapshot.hasData) return Center(child: CircularProgressIndicator());

                        final messages = chatSnapshot.data!.docs;

                        return ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            final isMe = msg['senderId'] == currentUserId;

                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.blue[200] : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(msg['text']),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          )
          ,

          ChatInputField(
            organizerId: organizerDocId!,
            eventId: widget.eventId,
          )
        ],
      ),
    );
  }
}
