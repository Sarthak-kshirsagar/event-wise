import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/AuthModel.dart';
import '../../domain/repositories/auth_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
final FirebaseAuth _auth = FirebaseAuth.instance;

class EventWiseAuth implements EventWiseAuthenticationService {
  @override
  Future<void> register({required AuthModel userCred}) async {
    try {
      UserCredential authDetails = await _auth.createUserWithEmailAndPassword(
        email: userCred.email,
        password: userCred.password,
      );
      final CollectionReference ref = FirebaseFirestore.instance.collection("Users");
      await ref.add({
        'user_id':'${authDetails.user!.uid}',
        'user_name':'${userCred.name}',
        'user_email':'${userCred.email}',
      });

    } catch (e) {
      print('Registration Error: $e');
    }
  }

  @override
  Future<String?> login({required AuthModel userCred}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: userCred.email,
        password: userCred.password,
      );
      return null;
    } catch (e) {
      print('Login Error: $e');
      return "${e}";
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Logout Error: $e');
    }
  }
}
