import 'package:btech/domain/repositories/organizer_repo.dart';

class OrganizerViewModel{
  final OrganizerServices organizer;

  OrganizerViewModel({required this.organizer});

  Future<List<Map<dynamic,dynamic>>> fetch_organizers()async{
    try {
      return await organizer.fecth_organizers();
    } on Exception catch (e) {
      return await [{}];
    }
  }

  Future<List<Map<dynamic,dynamic>>> fetch_organizers_events({required organizerId})async{
    try {
      print("From view model");
      print(await organizer.fetch_organizer_event(organizerId: organizerId));
      return await organizer.fetch_organizer_event(organizerId: organizerId);
    } on Exception catch (e) {

      return [{}];
    }
  }


}