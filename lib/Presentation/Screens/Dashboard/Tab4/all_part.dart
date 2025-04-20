import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
class AllParticipated extends StatefulWidget {
  const AllParticipated({super.key});

  @override
  State<AllParticipated> createState() => _AllParticipatedState();
}

class _AllParticipatedState extends State<AllParticipated> {
  List<Map<String, dynamic>> userEventDetails = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPortfolio();
  }

  Future<void> getPortfolio() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    String userId = _auth.currentUser!.uid;

    CollectionReference ref = FirebaseFirestore.instance.collection('Users');
    QuerySnapshot userSnap = await ref.where('user_id', isEqualTo: userId).get();

    if (userSnap.docs.isNotEmpty) {
      var userDoc = userSnap.docs.first;
      CollectionReference portfolioRef = userDoc.reference.collection('Portfolio');
      QuerySnapshot portfolioSnap = await portfolioRef.get();

      List<Map<String, dynamic>> events = [];

      for (var eventDoc in portfolioSnap.docs) {
        Map<String, dynamic> portfolioData = eventDoc.data() as Map<String, dynamic>;

        String eventId = portfolioData['event_id'];
        String orgId = portfolioData['organizer_id'];
        bool isWinner = portfolioData['is_winner'] ?? false;
        int position = portfolioData['position'] ?? 0;
        String certificate = portfolioData['certificate'] ?? '';

        CollectionReference organizerRef = FirebaseFirestore.instance.collection('Organizers');
        QuerySnapshot organizerSnap = await organizerRef.where("id", isEqualTo: orgId).get();

        if (organizerSnap.docs.isNotEmpty) {
          CollectionReference eventRef = organizerSnap.docs.first.reference.collection('Events');
          QuerySnapshot eventSnap = await eventRef.where('id', isEqualTo: eventId).get();

          if (eventSnap.docs.isNotEmpty) {
            Map<String, dynamic> eventData = eventSnap.docs.first.data() as Map<String, dynamic>;

            events.add({
              'event_name': eventData['name'] ?? 'Untitled Event',
              'event_description': eventData['description'] ?? '',
              'venue': eventData['venue'] ?? '',
              'is_winner': isWinner,
              'position': position,
              'certificate': certificate,
            });
          }
        }
      }

      setState(() {
        userEventDetails = events;
        isLoading = false;
      });
    }
  }

  void _showEventBottomSheet(BuildContext context, Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Event: ${event['event_name']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Performance: ${event['is_winner'] ? '${event['position']} Place' : 'Not a winner'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Certificate: ${event['certificate'].isNotEmpty ? 'Available' : 'Not available'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Event Details:\n${event['event_description']}", style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Portfolio")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userEventDetails.isEmpty
          ? const Center(child: Text("No portfolio entries found."))
          : ListView.builder(
        itemCount: userEventDetails.length,
        itemBuilder: (context, index) {
          final event = userEventDetails[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(event['event_name']),
              subtitle: const Text("Tap to view your performance"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showEventBottomSheet(context, event),
            ),
          );
        },
      ),
    );
  }
}
