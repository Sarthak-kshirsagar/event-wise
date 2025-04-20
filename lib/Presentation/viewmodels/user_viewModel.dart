import 'package:btech/data/models/UserModel.dart';
import 'package:btech/domain/repositories/organizer_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/users_repo.dart';

class UserViewmodel{
  final EventWiseUserServices userServices;

  UserViewmodel({required this.userServices});


  Future<bool> create_profile({required UserModel user})async{
    try {
      await userServices.createProfile(user: user);
      return true;
    } on Exception catch (e) {
      return false;
    }
  }

  Future<Map<String,dynamic>?> fetch_profile()async{
    return await userServices.fetchProfile();
  }

}