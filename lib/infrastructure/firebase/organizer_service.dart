
import 'package:btech/domain/repositories/organizer_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventWiseOrganizer implements OrganizerServices{
  @override
  Future<List<Map<String,dynamic>>> fecth_organizers() async{
    CollectionReference ref = FirebaseFirestore.instance.collection("Organizers");
    List<Map<String,dynamic>> organizersList = [];
    QuerySnapshot snapshot = await ref.get();
    for(var organizers in snapshot.docs){
      organizersList.add(organizers.data() as Map<String,dynamic>);
    }
    return organizersList;
  }

  @override
  Future<List<Map<dynamic,dynamic>>> fetch_organizer_event({required dynamic organizerId}) async{
    List<Map<dynamic,dynamic>> eventsList = [];
    final CollectionReference ref  = FirebaseFirestore.instance.collection("Organizers");
    QuerySnapshot organizerSnap = await ref.where("id",isEqualTo: "${organizerId}").get();
    if(organizerSnap.docs.isNotEmpty){
      print("From imple");
      CollectionReference eventsRef = await organizerSnap.docs.first.reference.collection("Events");
      QuerySnapshot eventsSnap  = await eventsRef.get();
      for(var events in eventsSnap.docs){
        print("Here is the event");
        print(events.data());
        eventsList.add(events.data() as Map<dynamic,dynamic>);
      }
      print("now returning");
      return eventsList;
    }
    print("or this");
    return [{}];
  }

}