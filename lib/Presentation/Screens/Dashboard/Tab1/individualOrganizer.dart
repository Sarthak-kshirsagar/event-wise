import 'package:btech/Presentation/viewmodels/organizer_viewmodel.dart';
import 'package:btech/domain/repositories/organizer_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../infrastructure/firebase/organizer_service.dart';
import 'individualEvent.dart';

class OrganizerScreen extends StatefulWidget {
  String logo = '';
  String description = '';
  String organizerId = '';
  String name = '';
   OrganizerScreen({required this.name,required this.logo, required this.organizerId,required this.description});

  @override
  State<OrganizerScreen> createState() => _OrganizerScreenState();
}

class _OrganizerScreenState extends State<OrganizerScreen> {
  OrganizerViewModel _oraginzerViewModel  = OrganizerViewModel(organizer: EventWiseOrganizer());
  List<Map<dynamic,dynamic>> events = [];


  Future<List<Map<String,dynamic>>> fetch_reviews()async{
    List<Map<String,dynamic>> feedbacksList = [];
    CollectionReference ref = FirebaseFirestore.instance.collection("Organizers");
    QuerySnapshot snapshot = await ref.where("id",isEqualTo: "${widget.organizerId}").get();
    if(snapshot.docs.isNotEmpty){
      CollectionReference eventsRef = await snapshot.docs.first.reference.collection('Events');
      QuerySnapshot eventSnap = await eventsRef.get();
      for(var events in eventSnap.docs){
        CollectionReference feedbackRef = await events.reference.collection('Feedback');
        QuerySnapshot feedbackSnap  = await feedbackRef.get();
        for(var feedbacks in feedbackSnap.docs){
          feedbacksList.add(feedbacks.data() as Map<String,dynamic>);
        }
      }
    }
    return feedbacksList;
  }

  Future<List<Map<String, String>>> fetchReviewsWithNames() async {
    List<Map<String, String>> feedbacksWithNames = [];

    CollectionReference organizerRef = FirebaseFirestore.instance.collection("Organizers");
    QuerySnapshot organizerSnap = await organizerRef.where("id", isEqualTo: "${widget.organizerId}").get();

    if (organizerSnap.docs.isNotEmpty) {
      CollectionReference eventsRef = organizerSnap.docs.first.reference.collection('Events');
      QuerySnapshot eventSnap = await eventsRef.get();

      for (var event in eventSnap.docs) {
        CollectionReference feedbackRef = event.reference.collection('Feedback');
        QuerySnapshot feedbackSnap = await feedbackRef.get();

        for (var feedbackDoc in feedbackSnap.docs) {
          Map<String, dynamic> feedbackData = feedbackDoc.data() as Map<String, dynamic>;
          String userId = feedbackData['user_id'];

          // Fetch user details
          QuerySnapshot userSnap = await FirebaseFirestore.instance.collection("Users").where("user_id",isEqualTo: "${userId}").get();

          if (userSnap.docs.isNotEmpty) {
            Map<String, dynamic> userData = userSnap.docs.first.data() as Map<String, dynamic>;
            String fullName = "${userData['user_name']} ${userData['last_name']}";

            feedbacksWithNames.add({
              "name": fullName,
              "feedback": feedbackData['feedback']
            });
          }
        }
      }
    }

    return feedbacksWithNames;
  }
  List<Map<String,dynamic>> feedbacks = [];
  Future<void> init()async{
    setState(() {
      isLoading=true;
    });
    events = await _oraginzerViewModel.fetch_organizers_events(organizerId: widget.organizerId);
    print("I got events");
    print(events);
    feedbacks = await fetchReviewsWithNames();
    setState(() {
      isLoading=false;
    });
  }
bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print("hete");
    print(widget.description);
    print("fetching events");
    init();
    // print(events);
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Organizer Details"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "About"),
              Tab(text: "Events"),
              Tab(text: "Reviews"),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: init,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Organizer Logo and Name
              Column(
                children:  [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      "https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png",
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "${widget.name}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tab Views
              Expanded(
                child: TabBarView(
                  children: [
                    // About Tab
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Text(
                         "${widget.description}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    // Events Tab
                    ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Individualevent(
                              organizer_id: widget.organizerId,
                              event_id: event['id'],
                              max_team_size: event['max_team_size'],
                              min_team_size: event['min_team_size'],
                              description: event['description'],
                              venue: event['venue'],
                              endTime: event['end_time'],
                              startTime: event['start_time'],
                              date: "${event['start_date']}",
                              eventInfo: event['description'],
                              name: event['name'],
                              organizer: widget.name,
                            ),));
                          },
                          child: EventCard(
                            title: event['name'] ?? "Unnamed Event",
                            date: event['start_date'] ?? "No Date",
                            location: event['venue'] ?? "No Location",
                          ),
                        );
                      },
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(16),
                    //   child: ListView(
                    //     children: const [
                    //       EventCard(
                    //         title: "Flutter Forward",
                    //         date: "March 15, 2025",
                    //         location: "Pune, India",
                    //       ),
                    //       EventCard(
                    //         title: "Hack the UI",
                    //         date: "April 20, 2025",
                    //         location: "Mumbai, India",
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // Reviews Tab
                    // Padding(
                    //   padding: const EdgeInsets.all(16),
                    //   child: ListView(
                    //     children:  [
                    //       ElevatedButton(onPressed: ()async{
                    //         print(await fetchReviewsWithNames());
                    //       }, child: Text("")),
                    //
                    //       ReviewTile(
                    //         reviewer: "Sarthak Kshirsagar",
                    //         review:
                    //         "Very well organized event with great speakers and networking opportunities!",
                    //       ),
                    //       ReviewTile(
                    //         reviewer: "Priya Sharma",
                    //         review:
                    //         "Amazing community vibes and extremely helpful mentors.",
                    //       ),
                    //     ],
                    //   ),
                    // ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : feedbacks.isEmpty
                ? const Center(child: Text("No reviews available yet."))
                : RefreshIndicator(
              onRefresh: init,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: feedbacks.isEmpty
                    ?  ListView(
                  // Needed for RefreshIndicator to work when empty
                  children: [
                    Center(child: Text("No reviews available yet.")),
                  ],
                )
                    : ListView.builder(
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final review = feedbacks[index];
                    return ReviewTile(
                      reviewer: review['name'] ?? 'Anonymous',
                      review: review['feedback'] ?? '',
                    );
                  },
                ),
              ),
          ),)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String location;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const Icon(Icons.event, color: Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$date • $location"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

      ),
    );
  }
}

class ReviewTile extends StatelessWidget {
  final String reviewer;
  final String review;

  const ReviewTile({
    super.key,
    required this.reviewer,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.indigo),
        title: Text(reviewer, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(review),
      ),
    );
  }
}
