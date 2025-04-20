import 'package:btech/Presentation/Screens/Organizers/qr_view_example.dart';
import 'package:btech/Presentation/styles/elevated_button_style.dart';
import 'package:btech/infrastructure/FCM/getServerKey.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';

import 'evet_wise_chat.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class EventDetailTabsScreen extends StatefulWidget {
  final Map<String, dynamic> eventDetails;

  EventDetailTabsScreen({required this.eventDetails});

  @override
  _EventDetailTabsScreenState createState() => _EventDetailTabsScreenState();
}


class _EventDetailTabsScreenState extends State<EventDetailTabsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.eventDetails['name'] ?? "Event"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Scan & Search", icon: Icon(Icons.qr_code_scanner)),
              Tab(text: "Details", icon: Icon(Icons.info)),
              Tab(text: "Notify", icon: Icon(Icons.notifications_active)),
              Tab(text: "Chat", icon: Icon(Icons.message)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ScanAndSearchTab(event_details: widget.eventDetails,),
            EventDetailsTab(eventDetails: widget.eventDetails), // <== new tab
            SendNotificationTab(event_details: widget.eventDetails),
            EventChatScreen(eventId: widget.eventDetails['id']),
          ],
        ),
      ),
    );
  }
}

class EventDetailsTab extends StatelessWidget {
  final Map<String, dynamic> eventDetails;

  const EventDetailsTab({required this.eventDetails});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          title: Text("Name"),
          subtitle: Text(eventDetails['name'] ?? 'N/A'),
        ),
        ListTile(
          title: Text("Department"),
          subtitle: Text(eventDetails['department'] ?? 'N/A'),
        ),
        ListTile(
          title: Text("Venue"),
          subtitle: Text(eventDetails['venue'] ?? 'N/A'),
        ),
        ListTile(
          title: Text("Start Date & Time"),
          subtitle: Text("${eventDetails['start_date']} at ${eventDetails['start_time']}"),
        ),
        ListTile(
          title: Text("End Date & Time"),
          subtitle: Text("${eventDetails['end_date']} at ${eventDetails['end_time']}"),
        ),
        ListTile(
          title: Text("Mode"),
          subtitle: Text(eventDetails['mode'] ?? 'N/A'),
        ),
        ListTile(
          title: Text("Goodies"),
          subtitle: Text((eventDetails['goodies'] as List?)?.join(', ') ?? 'None'),
        ),
        ListTile(
          title: Text("Prizes"),
          subtitle: Text(eventDetails['prizes']?.toString() ?? 'None'),
        ),
        ListTile(
          title: Text("Description"),
          subtitle: Text(eventDetails['description'] ?? 'N/A'),
        ),
      ],
    );
  }
}

class ScanAndSearchTab extends StatefulWidget {
  Map<String,dynamic> event_details = {};
  ScanAndSearchTab({required this.event_details});
  @override
  _ScanAndSearchTabState createState() => _ScanAndSearchTabState();
}

class _ScanAndSearchTabState extends State<ScanAndSearchTab> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final TextEditingController searchController = TextEditingController();
  String? qrResult;

  List<dynamic> students = [
    'Sarthak Kshirsagar',
    'Aarav Mehta',
    'Isha Kulkarni',
    'Tanvi Deshmukh',
    'Rohan Patil',
  ];

  Future<List<dynamic>> fetch_present_students()async{
    FirebaseAuth _auth = FirebaseAuth.instance;
    String userId = await  _auth.currentUser!.uid;
    List<dynamic> event_attendance = [];
    CollectionReference oragnizerRef = FirebaseFirestore.instance.collection('Organizers');
    QuerySnapshot organizerSnap = await oragnizerRef.where('id',isEqualTo: "${userId}").get();
    if(organizerSnap.docs.isNotEmpty){
      CollectionReference eventRef = await organizerSnap.docs.first.reference.collection('Events');
      QuerySnapshot eventSnap = await eventRef.where('id',isEqualTo: "${widget.event_details['id']}").get();
      if(eventSnap.docs.isNotEmpty){
        CollectionReference attendanceRef = await eventSnap.docs.first.reference.collection('Attendance');
        QuerySnapshot attendanceSnap = await attendanceRef.get();
        if(attendanceSnap.docs.isNotEmpty){
          for(var docs in attendanceSnap.docs){
            Map<String,dynamic> data = await docs.data() as Map<String,dynamic>;
            event_attendance.add(data['user_id']);
          }

        }
      }
    }
    return event_attendance;
  }

  Future<List<dynamic>> user_names_registered()async{
    List<dynamic> user_ids = [];
    List<dynamic> names = [];
    user_ids = await fetch_present_students();
    CollectionReference ref = FirebaseFirestore.instance.collection('Users');
    for(var users in user_ids){
      QuerySnapshot snapshot = await ref.where('user_id',isEqualTo: "${users}").get();
      if(snapshot.docs.isNotEmpty){
        for(var docs in snapshot.docs){
          Map<String,dynamic> user_data = await docs.data() as Map<String,dynamic>;
          names.add("${user_data['user_name']} ${user_data['last_name']}");
        }
      }
    }
    return names;
  }
  void _openQRScanner() async {
    await  Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScannerScreen(event_id:widget.event_details['id'],)),
    );
  }

  Future<void> init()async{
    students = await user_names_registered();
    setState(() {

    });
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }
  @override
  Widget build(BuildContext context) {
    final filtered = students
        .where((name) =>
        name.toLowerCase().contains(searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _openQRScanner,child: Icon(Icons.qr_code),),
      body: RefreshIndicator(
        onRefresh: init,
        child: Column(
          children: [
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              ],
            ),
            if (qrResult != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  qrResult!,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search Student",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => setState(() {}),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filtered[index]),
                    leading: Icon(Icons.person),
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

class SendNotificationTab extends StatefulWidget {
  Map<String,dynamic> event_details = {};
  SendNotificationTab({required this.event_details});
  @override
  _SendNotificationTabState createState() => _SendNotificationTabState();
}

class _SendNotificationTabState extends State<SendNotificationTab> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  // get the user ids from the participants
  // based on user id get the fcm token and send notification
Future<void> send_notification_participants({required title,required msg})async{
  FirebaseAuth _auth = FirebaseAuth.instance;
  String userId = await _auth.currentUser!.uid;
  CollectionReference organizerRef = FirebaseFirestore.instance.collection('Organizers');
  QuerySnapshot organizerSnap = await organizerRef.where('id',isEqualTo: "${userId}").get();
  if(organizerSnap.docs.isNotEmpty){
    print("got the organizer");
    CollectionReference eventRef  = await organizerSnap.docs.first.reference.collection('Events');
    QuerySnapshot eventSnap = await eventRef.where('id',isEqualTo: "${widget.event_details['id']}").get();
    if(eventSnap.docs.isNotEmpty){
      print("got the event");
      CollectionReference participantRef = await eventSnap.docs.first.reference.collection('Registrations');
      QuerySnapshot participantSnap = await participantRef.get();
      CollectionReference usersRef  = FirebaseFirestore.instance.collection('Users');
      List<dynamic> ids = [];
      for(var participants in participantSnap.docs){
        // print("current part is $participants");
        Map<String,dynamic> data = await participants.data() as Map<String,dynamic>;
        ids.add(data['user_id']);
        ids.addAll(data['members']);
        print(data);
        for(var id in ids){
          QuerySnapshot usersSnap  = await usersRef.where("user_id",isEqualTo: "${id}").get();
          if(usersSnap.docs.isNotEmpty){
            print('fcm token is }');
            Map<String,dynamic> userData = await usersSnap.docs.first.data() as Map<String,dynamic>;
            if(userData.containsKey('fcmToken')){
              String fcmToken = await userData['fcmToken'];
              GetServerKey fcm = GetServerKey();
              fcm.sendNotification(fcmToken, '${title}', '${msg}', 'payload');
            }
          }
        }

      }
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: "Enter notification message",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 15,),
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              labelText: "Enter notification message",
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            style: elevated_button_style(),
            onPressed: ()async{
              print("hi");
              await send_notification_participants(title: _titleController.text.trim(),msg: _messageController.text.trim());
            },
            icon: Icon(Icons.send),
            label: Text("Send Notification"),
          )
        ],
      ),
    );
  }
}
