import '../../data/models/UserModel.dart';

abstract class EventWiseUserServices{
  Future<bool> createProfile ({required UserModel user});
  Future<Map<String,dynamic>?> fetchProfile ();
  Future<void> updateProfile();
  Future<void> deleteUser ();
}