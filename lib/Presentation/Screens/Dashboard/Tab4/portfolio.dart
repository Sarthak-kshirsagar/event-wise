import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class PortfolioScreen extends StatefulWidget {
  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> userEventDetails = [];
  List<Map<String, dynamic>> wonEventDetails = [];

  @override
  void initState() {
    super.initState();
    getPortfolio();
  }

  Future<void> getPortfolio() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      CollectionReference ref = FirebaseFirestore.instance.collection('Users');
      QuerySnapshot userSnap =
      await ref.where('user_id', isEqualTo: userId).get();

      if (userSnap.docs.isNotEmpty) {
        var userDoc = userSnap.docs.first;
        Map<String, dynamic> userData =
        userDoc.data() as Map<String, dynamic>;

        List<dynamic> participationList = userData['participation'] ?? [];
        List<Map<String, dynamic>> allEvents = [];
        List<Map<String, dynamic>> wonEvents = [];
        CollectionReference portRef = await userSnap.docs.first.reference.collection('Portfolio');
        QuerySnapshot portSnap = await portRef.get();
        if(portSnap.docs.isNotEmpty){
          for(var events in portSnap.docs){
            allEvents.add(events.data() as Map<String,dynamic>);
          }
        }
        QuerySnapshot organizersSnap =
        await FirebaseFirestore.instance.collection('Organizers').get();

        for (var participation in participationList) {
          String eventId = participation['event_id'];
          bool isWinner = participation['is_winner'] ?? false;
          int position = participation['position'] ?? 0;
          String certificate = participation['certificate'] ?? '';

          for (var organizerDoc in organizersSnap.docs) {
            CollectionReference eventRef =
            organizerDoc.reference.collection('Events');
            QuerySnapshot eventSnap =
            await eventRef.where('id', isEqualTo: eventId).get();

            if (eventSnap.docs.isNotEmpty) {
              Map<String, dynamic> eventData =
              eventSnap.docs.first.data() as Map<String, dynamic>;

              Map<String, dynamic> eventInfo = {
                'event_name': eventData['name'] ?? 'Untitled Event',
                'event_description': eventData['description'] ?? '',
                'venue': eventData['venue'] ?? '',
                'is_winner': isWinner,
                'position': position,
                'certificate': certificate,
              };

              // allEvents.add(eventInfo);
              if (isWinner) wonEvents.add(eventInfo);

              break;
            }
          }
        }

        setState(() {
          userEventDetails = allEvents;
          wonEventDetails = wonEvents;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Portfolio')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text("All Participated Events",
            //     style:
            //     TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            // const SizedBox(height: 10),
            // Flexible(child: AllParticipated(events: userEventDetails)),
            const SizedBox(height: 20),
            Text("Won Events",
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Flexible(
              child: wonEventDetails.isEmpty
                  ? const Text("No events won yet.")
                  : ListView.builder(
                itemCount: wonEventDetails.length,
                itemBuilder: (context, index) {
                  final event = wonEventDetails[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 4),
                    child: ListTile(
                      title: Text(event['event_name']),
                      subtitle: Text(event['event_description']),
                      trailing: Icon(Icons.star,
                          color: Colors.amber.shade700),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
