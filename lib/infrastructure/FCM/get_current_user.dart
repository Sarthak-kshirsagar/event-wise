import 'package:firebase_auth/firebase_auth.dart';
//
Future<String?>getCurrentUserId()async{
  String? currentUserId;
  try {

    final FirebaseAuth _auth = FirebaseAuth.instance;
    if (_auth.currentUser!=null) {

      currentUserId = await _auth.currentUser!.uid;
      return currentUserId;
    }else{
      print("current user is null");
      return null;
    }


  } on Exception catch (e) {
    print("Excpetion occured while fetch the current user id ${e}");
  }
  return currentUserId;
}