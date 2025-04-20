import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Organizers/evet_wise_chat.dart';
import 'event_chat.dart';

class MyEventsHomePage extends StatefulWidget {
  Map<String,dynamic> eventDetails = {};
   MyEventsHomePage({required this.eventDetails});

  @override
  State<MyEventsHomePage> createState() => _MyEventsHomePageState();
}

class _MyEventsHomePageState extends State<MyEventsHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Events"),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Entry QR", icon: Icon(Icons.qr_code,color: Colors.black,)),
              Tab(text: "Event Timeline", icon: Icon(Icons.timeline,color: Colors.black)),
              Tab(text: "Chat", icon: Icon(Icons.chat_bubble_outline,color: Colors.black)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            EntryQRTab(eventDetails: widget.eventDetails,),
            EventTimelineTab(eventDetails: widget.eventDetails,),
            EventChatScreenUser(eventId: widget.eventDetails['id'],organizerId: widget.eventDetails['organizer_id'], ),
          ],
        ),
      ),
    );
  }
}

// Placeholder widgets for each tab

// class EntryQRTab extends StatefulWidget {
//   Map<String,dynamic> eventDetails = {};
//    EntryQRTab({Key? key,required this.eventDetails}) : super(key: key);
//
//   @override
//   State<EntryQRTab> createState() => _EntryQRTabState();
// }
//
// class _EntryQRTabState extends State<EntryQRTab> {
//   String userId = '';
//   Future<void> get_qr_code_details()async{
//     FirebaseAuth _auth = FirebaseAuth.instance;
//     String user_id = await _auth.currentUser!.uid;
//     this.userId = user_id;
//     setState(() {
//
//     });
//   }
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     get_qr_code_details();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold(
//       floatingActionButton: FloatingActionButton(onPressed: ()async{
//         CollectionReference orgRef = FirebaseFirestore.instance.collection('Organizers');
//         QuerySnapshot orgsnap = await orgRef.where("id",isEqualTo: "${widget.eventDetails['organizer_id']}").get();
//         if(orgsnap.docs.isNotEmpty){
//           CollectionReference eventRef = await orgsnap.docs.first.reference.collection('Events');
//           QuerySnapshot eventSnap = await eventRef.where("id",isEqualTo: "${widget.eventDetails['event_id']}").get();
//           if(eventSnap.docs.isNotEmpty){
//             CollectionReference feedbackRef = await eventSnap.docs.first.reference.collection('Feedback');
//             await feedbackRef.add({});
//           }
//         }
//       },child: Icon(Icons.feedback),),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Center(
//             child: QrImageView(
//               data: "${userId}",
//               version: QrVersions.auto,
//               size: 200.0,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//


class EntryQRTab extends StatefulWidget {
  Map<String, dynamic> eventDetails = {};
  EntryQRTab({Key? key, required this.eventDetails}) : super(key: key);

  @override
  State<EntryQRTab> createState() => _EntryQRTabState();
}

class _EntryQRTabState extends State<EntryQRTab> {
  String userId = '';
  final TextEditingController _feedbackController = TextEditingController();

  Future<void> getQRCodeDetails() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    String user_id = _auth.currentUser!.uid;
    setState(() {
      userId = user_id;
    });
  }

  @override
  void initState() {
    super.initState();
    getQRCodeDetails();
  }

  void _showFeedbackForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "We value your feedback!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _feedbackController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Enter your feedback',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _submitFeedback();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitFeedback() async {
    final feedbackText = _feedbackController.text.trim();
    if (feedbackText.isEmpty) return;

    final orgRef = FirebaseFirestore.instance.collection('Organizers');
    final orgSnap = await orgRef
        .where("id", isEqualTo: "${widget.eventDetails['organizer_id']}")
        .get();

    if (orgSnap.docs.isNotEmpty) {
      print("got the orh snap");
      print(widget.eventDetails);
      final eventRef = orgSnap.docs.first.reference.collection('Events');
      final eventSnap = await eventRef
          .where("id", isEqualTo: "${widget.eventDetails['id']}")
          .get();

      if (eventSnap.docs.isNotEmpty) {
        print("got the event snap");
        final feedbackRef = eventSnap.docs.first.reference.collection('Feedback');
        await feedbackRef.add({
          'feedback': feedbackText,
          'user_id': userId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _feedbackController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thank you for your feedback!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFeedbackForm(context),
        child: const Icon(Icons.feedback),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: userId.isEmpty
                ? const CircularProgressIndicator()
                : QrImageView(
              data: userId,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
        ],
      ),
    );
  }
}

class EventTimelineTab extends StatefulWidget {
  final Map<String, dynamic> eventDetails;

  const EventTimelineTab({Key? key, required this.eventDetails}) : super(key: key);

  @override
  State<EventTimelineTab> createState() => _EventTimelineTabState();
}

class _EventTimelineTabState extends State<EventTimelineTab> {
  @override
  Widget build(BuildContext context) {
    final details = widget.eventDetails;

    String formatDate(String date) {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    }

    String formatTime(String time) {
      return DateFormat.jm().format(DateFormat("HH:mm").parse(time));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(onPressed: (){
            print(widget.eventDetails);
          }, child: Text("data")),
          // Title
          Text(
            details['name'] ?? "Event",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Date + Time
          Column(
            // mainAxisAlignment: MainAxisAlignment.,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📅 ${formatDate(details['start_date'])} - ${formatDate(details['end_date'])}"),
              Text("🕘 ${formatTime(details['start_time'])} - ${formatTime(details['end_time'])}"),
            ],
          ),
          const SizedBox(height: 12),

          // Event Type, Department, Mode
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _chip("Type: ${details['type']}"),
              _chip("Mode: ${details['mode']}"),
              _chip("Dept: ${details['department']}"),
            ],
          ),
          const SizedBox(height: 16),

          // Venue
          _sectionTitle("📍 Venue"),
          Text(details['venue']),

          const SizedBox(height: 12),

          // Description
          _sectionTitle("📖 Description"),
          Text(details['description'] ?? "No description provided."),

          const SizedBox(height: 16),

          // Categories
          _sectionTitle("📂 Event Categories"),
          Wrap(
            spacing: 8,
            children: List<Widget>.from(
              (details['event_categories'] as List).map((cat) => _chip(cat)),
            ),
          ),

          const SizedBox(height: 16),

          // Team Info
          _sectionTitle("👥 Team Details"),
          Text(details['is_team_event'] ? "Team Event" : "Individual Event"),
          Text("Team Size: ${details['min_team_size']} - ${details['max_team_size']}"),

          const SizedBox(height: 16),

          // Goodies
          _sectionTitle("🎁 Goodies"),
          Wrap(
            spacing: 8,
            children: List<Widget>.from(
              (details['goodies'] as List).map((g) => _chip(g)),
            ),
          ),

          const SizedBox(height: 16),

          // Prizes
          _sectionTitle("🏆 Prizes"),
          ...((details['prizes'] as Map).entries.map((e) {
            return Text("Position ${e.key}: ₹${e.value}");
          })),

          const SizedBox(height: 16),

          // Images
          if ((details['images'] as List).isNotEmpty) ...[
            _sectionTitle("🖼️ Image"),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(details['images'][0], fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
          ],

          // Video
          if ((details['videos'] as List).isNotEmpty) ...[
            _sectionTitle("📹 Promo Video"),
            GestureDetector(
              onTap: () {
                // You can use `url_launcher` to open the video
              },
              child: Text(
                details['videos'][0],
                style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _chip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class ChatTab extends StatelessWidget {
  const ChatTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Event group chat will appear here."));
  }
}
