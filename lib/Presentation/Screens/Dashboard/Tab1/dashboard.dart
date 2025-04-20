import 'package:btech/Presentation/viewmodels/organizer_viewmodel.dart';
import 'package:btech/infrastructure/FCM/NotificationService.dart';
import 'package:btech/infrastructure/firebase/organizer_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../infrastructure/FCM/getServerKey.dart';
import '../../Organizers/event_detail_tabs_screen.dart';
import '../../Organizers/organizerAdminPanel.dart';
import '../../components/eventComponent.dart';
import '../../components/recommendedEvents.dart';
import 'event_calendar.dart';
import 'individualEvent.dart';
import 'individualOrganizer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  OrganizerViewModel _view_organizer =
      OrganizerViewModel(organizer: EventWiseOrganizer());
  List<Map<dynamic, dynamic>> organizersList = [];
  List<Map<dynamic, dynamic>>? data = [];
  List<Map<dynamic, dynamic>>? recommendedEvents = [];
  bool isLoading = false;

  Future<List<Map<String, dynamic>>> fetchUserEventMatches() async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      final Uri url =
          Uri.parse("https://em-api-o9je.onrender.com/api/eventr/?id=$uid");

      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        // Safely cast each item to Map<String, dynamic>
        final List<Map<String, dynamic>> matches = jsonList
            .map<Map<String, dynamic>>(
                (item) => Map<String, dynamic>.from(item))
            .toList();

        return matches;
      } else {
        print('API call failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching event matches: $e');
      return [];
    }
  }

  Future<void> init() async {
    setState(() {
      isLoading = true;
    });
    organizersList = await _view_organizer.fetch_organizers();
    data = await fetchUserEventMatches();
    print(data);
    recommendedEvents = await findRecommendedEvents(apiResult: data!);
    setState(() {
      isLoading = false;
    });
    print(recommendedEvents);
  }

  Future<List<Map<dynamic, dynamic>>> findRecommendedEvents({
    required List<Map<dynamic, dynamic>> apiResult,
  }) async {
    List<Map<String, dynamic>> recommendedEvents = [];
    CollectionReference ref =
        FirebaseFirestore.instance.collection("Organizers");

    for (var item in apiResult) {
      final String organizerId = item['organizer_id'];
      final String eventId = item['event_id'];
      final double score = (item['similarity'] as num).toDouble();

      // Apply the threshold filter
      if (score > 0.30) continue;

      QuerySnapshot organizerSnap =
          await ref.where("id", isEqualTo: organizerId).get();
      if (organizerSnap.docs.isNotEmpty) {
        CollectionReference eventRef =
            organizerSnap.docs.first.reference.collection('Events');
        QuerySnapshot eventSnap =
            await eventRef.where("id", isEqualTo: eventId).get();

        if (eventSnap.docs.isNotEmpty) {
          Map<String, dynamic> event =
              eventSnap.docs.first.data() as Map<String, dynamic>;
          event['similarity'] = score;
          event['organizer_id'] = organizerId;
          recommendedEvents.add(event);
        }
      }
    }

    return recommendedEvents;
  }

  List<String> assets = [
    'assets/images/event1.png',
    'assets/images/event2.jpg',
    'assets/images/event3.jpg',
    'assets/images/event1.png',
    'assets/images/event2.jpg',
    'assets/images/event3.jpg',
    'assets/images/event1.png',
    'assets/images/event2.jpg',
    'assets/images/event3.jpg'
  ];

  @override
  void initState() {
    super.initState();
    init();
    print("list ${organizersList}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RefreshIndicator(
            onRefresh: init,
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  "assets/images/logo.png",
                                  width: 50,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "Event Wise",
                                  style: TextStyle(fontSize: 22),
                                )
                              ],
                            ),
                            Icon(
                              Icons.person,
                              size: 30,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Divider(),
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Recommended Events",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            )),

                        SizedBox(
                          height: 5,
                        ),

                        // ============= recommended events ================

                        if (recommendedEvents!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 300,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: recommendedEvents!.length,
                                itemBuilder: (context, index) {
                                  return recommended_events(
                                    ctx: context,
                                      enddate:
                                          "${recommendedEvents![index]['end_date']}",
                                      event_name:
                                          "${recommendedEvents![index]['name']}",
                                      image: "${assets[index]}",
                                      startdate:
                                          "${recommendedEvents![index]['start_date']}",
                                      w: Individualevent(
                                          organizer_id:
                                              "${recommendedEvents![index]['organizer_id']}",
                                          max_team_size:
                                              recommendedEvents![index]
                                                  ['max_team_size'],
                                          min_team_size:
                                              recommendedEvents![index]
                                                  ['max_team_size'],
                                          event_id:
                                              "${recommendedEvents![index]['event_id']}",
                                          description:
                                              "${recommendedEvents![index]['end_date']}",
                                          venue:
                                              "${recommendedEvents![index]['venue']}",
                                          startTime:
                                              "${recommendedEvents![index]['start_date']}",
                                          endTime:
                                              "${recommendedEvents![index]['end_date']}",
                                          name:
                                              "${recommendedEvents![index]['name']}",
                                          date:
                                              "${recommendedEvents![index]['end_date']}",
                                          organizer:
                                              "${recommendedEvents![index]['organizer_id']}",
                                          eventInfo:
                                              "${recommendedEvents![index]['description']}"));
                                },
                              ),
                            ),
                          ),
                        // ============ Organizers ============
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Organizers",
                              style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                            )),

                        if (organizersList.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 250,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: organizersList.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      print(organizersList[index]);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OrganizerScreen(
                                            name: "${organizersList[index]['name']}",
                                            organizerId: "${organizersList[index]['id']}",
                                            logo: " ",
                                            description: "${organizersList[index]['description']}",
                                          ),
                                        ),
                                      );
                                    },
                                    child: event_component(
                                      eventImage: assets[index + 1],
                                      context: context,
                                      eventName: "${organizersList[index]['name']}",
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                        // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: Container(
                          //     height: 250,
                          //     child: ListView.builder(
                          //       scrollDirection: Axis.vertical,
                          //       itemCount: organizersList.length,
                          //       itemBuilder: (context, index) {
                          //         return Row(
                          //           children: [
                          //             InkWell(
                          //                 onTap: () {
                          //                   print(organizersList[index]);
                          //                   Navigator.push(
                          //                       context,
                          //                       MaterialPageRoute(
                          //                         builder: (context) =>
                          //                             OrganizerScreen(
                          //                           name:
                          //                               "${organizersList[index]['name']}",
                          //                           organizerId:
                          //                               "${organizersList[index]['id']}",
                          //                           logo: " ",
                          //                           description:
                          //                               "${organizersList[index]['description']}",
                          //                         ),
                          //                       ));
                          //                 },
                          //                 child: event_component(
                          //                     eventImage: assets[index + 1],
                          //                     context: context,
                          //                     eventName:
                          //                         "${organizersList[index]['name']}")),
                          //             SizedBox(
                          //               width: 15,
                          //             ),
                          //           ],
                          //         );
                          //       },
                          //     ),
                          //   ),
                          // ),
                        CalendarScreen(),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CalendarScreen(),
                                  ));
                            },
                            child: Text("calendar"))
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
