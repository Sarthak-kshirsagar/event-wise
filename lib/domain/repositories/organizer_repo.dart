abstract class OrganizerServices{
  Future<List<Map<String,dynamic>>> fecth_organizers();

  Future<List<Map<dynamic,dynamic>>> fetch_organizer_event({required dynamic organizerId});
}