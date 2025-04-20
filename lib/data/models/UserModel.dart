import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  String userName = '';
  String middleName = '';
  String lastName = '';
  int age = 0;
  String gender = '';
  String bloodGroup = '';
  String profileUrl = '';
  UserModel(
      {required this.userName,
      required this.bloodGroup,
      required this.age,
      required this.lastName,
      required this.gender,
      required this.middleName,required this.profileUrl});
}
