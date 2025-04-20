import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/UserModel.dart';
import '../../domain/repositories/users_repo.dart';
import 'package:firebase_core/firebase_core.dart';

class UserProfile implements EventWiseUserServices{
final CollectionReference usersRef = FirebaseFirestore.instance.collection("Users");
final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Future<bool> createProfile({required UserModel user}) async{
    String userId = await _auth.currentUser!.uid;
    if(userId.isNotEmpty){
      QuerySnapshot usersSnap = await usersRef.where("user_id",isEqualTo: "${userId}").get();
      if(usersSnap.docs.isNotEmpty){
        await usersSnap.docs.first.reference.update({
          'user_name':user.userName,
          'last_name':user.lastName,
          'middle_name':user.middleName,
          'gender': user.gender,
          'blood_group':user.bloodGroup,
          'profile_pic':user.profileUrl,
          'profile_completed':true,
          'user_age':user.age,
        });
      }
      return true;
    }
    return false;
  }

  @override
  Future<void> deleteUser() {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }

  @override
  Future<Map<String,dynamic>?> fetchProfile() async{
    QuerySnapshot snapshot = await usersRef.where('user_id',isEqualTo: "${_auth.currentUser!.uid}").get();
    if(snapshot.docs.isNotEmpty){
      Map<String,dynamic> data = await snapshot.docs.first.data() as Map<String,dynamic>;
      if(data.containsKey('profile_completed') && data['profile_completed']==true){
        return data;
      }else{
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> updateProfile() {
    // TODO: implement updateProfile
    throw UnimplementedError();
  }

}