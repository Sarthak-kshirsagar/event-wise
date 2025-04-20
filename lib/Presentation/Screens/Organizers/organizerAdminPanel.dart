import 'package:btech/Presentation/Screens/LandingScreens/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'event_detail_tabs_screen.dart';


class AllEventsScreen extends StatefulWidget {
  @override
  _AllEventsScreenState createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  List<Map<String, dynamic>> allEvents = [
  ];
  String organizer_id = '';

  String searchText = '';
  Future<List<Map<String,dynamic>>> get_events()async{
    List<Map<String,dynamic>> fetched_events = [];
    String userId = await FirebaseAuth.instance.currentUser!.uid;
    CollectionReference ref = FirebaseFirestore.instance.collection('Organizers');
    QuerySnapshot organizerSnap = await ref.where("id",isEqualTo:"${userId}").get();
    if(organizerSnap.docs.isNotEmpty){
      CollectionReference eventsRef = await organizerSnap.docs.first.reference.collection("Events");
      QuerySnapshot eventsSnap = await eventsRef.get();
      for(var events in eventsSnap.docs){
        fetched_events.add(events.data() as Map<String,dynamic>);
      }

    }
    return fetched_events;
  }

  Future<void> init()async{
    allEvents = await get_events();
    print(allEvents);
    if (mounted) {
      setState(() {

      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();

  }
  @override
  Widget build(BuildContext context) {
    final filteredEvents = allEvents
        .where((event) =>
        event['name'].toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text("All Events"),actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(onTap: ()async{
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignIn(),), (route) => false,);
          },child: Icon(Icons.logout,color: Colors.red,)),
        )
      ],),
      body: RefreshIndicator(
      onRefresh: init,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) => setState(() => searchText = val),
              decoration: InputDecoration(
                hintText: "Search events",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: allEvents.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    title: Text(event['name'] ?? 'Unnamed Event'),
                    subtitle: Text(event['venue'] ?? 'No venue'),
                    leading: Icon(Icons.event),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailTabsScreen(eventDetails: event),
                        ),
                      );

                    },
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
