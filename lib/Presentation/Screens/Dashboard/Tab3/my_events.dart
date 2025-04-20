import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/my_events_card.dart';
import 'myEventHomePage.dart';

class MyEventsScreen extends StatefulWidget {
  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List<Map<String, dynamic>> fetchedEvents = [];

  Future<List<Map<String, dynamic>>?> getEventOrganizerIds() async {
    List<Map<String, dynamic>> eventsList = [];
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId != null && currentUserId.isNotEmpty) {
      CollectionReference usersRef = FirebaseFirestore.instance.collection('Users');
      QuerySnapshot userSnap = await usersRef.where("user_id", isEqualTo: currentUserId).get();

      if (userSnap.docs.isNotEmpty) {
        CollectionReference portfolioRef = userSnap.docs.first.reference.collection('Portfolio');
        QuerySnapshot portfolioSnap = await portfolioRef.get();

        for (var eventDoc in portfolioSnap.docs) {
          eventsList.add(eventDoc.data() as Map<String, dynamic>);
        }
        return eventsList;
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchRegisteredEvents() async {
    List<Map<String, dynamic>>? registeredEvents = await getEventOrganizerIds();
    List<Map<String, dynamic>> fetchedEvents = [];

    if (registeredEvents == null) return [];

    CollectionReference organizerRef = FirebaseFirestore.instance.collection("Organizers");

    for (var event in registeredEvents) {
      QuerySnapshot organizerSnap = await organizerRef.where('id', isEqualTo: event['organizer_id']).get();

      if (organizerSnap.docs.isNotEmpty) {
        CollectionReference eventsRef = organizerSnap.docs.first.reference.collection('Events');
        QuerySnapshot eventsSnap = await eventsRef.where("id", isEqualTo: event['event_id']).get();

        for (var doc in eventsSnap.docs) {
          final eventData = doc.data() as Map<String, dynamic>;
          eventData['organizer_id'] = event['organizer_id']; // ✅ Attach organizer ID
          fetchedEvents.add(eventData);
        }
      }
    }

    return fetchedEvents;
  }

  Future<void> init() async {
    List<Map<String, dynamic>> events = await fetchRegisteredEvents();
    if (mounted) {
      setState(() {
        fetchedEvents = events;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: RefreshIndicator(
            onRefresh: init,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Events",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Search Your Events",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                fetchedEvents.isEmpty
                    ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
                    : Expanded(
                  child: ListView.builder(
                    itemCount: fetchedEvents.length,
                    itemBuilder: (context, index) {
                      final event = fetchedEvents[index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => MyEventsHomePage(eventDetails: event,),));
                            },
                            child: my_events_card(
                              context: context,
                              eventName: event['name'],
                              eventTime: event['start_time'],
                              imagePath: "assets/images/event1.png",
                            ),
                          ),
                          SizedBox(height: 20,),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
