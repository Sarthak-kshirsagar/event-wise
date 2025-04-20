import 'package:btech/domain/repositories/event_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
class AppEvent implements EventServices{
  @override
  Future<void> fetch_events() async{
    final CollectionReference ref = FirebaseFirestore.instance.collection("Organizers");

  }

  @override
  Future<void> register_event() {
    // TODO: implement register_event
    throw UnimplementedError();
  }

}