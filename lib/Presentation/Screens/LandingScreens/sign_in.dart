import 'package:btech/Presentation/Screens/LandingScreens/sign_up.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../data/models/AuthModel.dart';
import '../../../infrastructure/firebase/auth_service.dart';
import '../../styles/elevated_button_style.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../Dashboard/eventWiseHomeScreen.dart';
import '../Organizers/organizerAdminPanel.dart';
import '../Organizers/organizer_sign_up.dart';
import '../components/textField.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthViewModel _authView = AuthViewModel(authRepo: EventWiseAuth());
  final TextEditingController _emailAddress = TextEditingController();
  final TextEditingController _password = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  void _signInUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    AuthModel _userDetails = AuthModel(
      email: _emailAddress.text.trim(),
      password: _password.text.trim(),
      name: '',
    );

    dynamic loginResult = await _authView.login(_userDetails);

    setState(() {
      _isLoading = false;
    });

    if (loginResult == null) {
      String? userId = await FirebaseAuth.instance.currentUser!.uid;
      if(userId.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unexpected Error Occurred")));
      }else{
        CollectionReference ref = FirebaseFirestore.instance.collection('Users');
        print("current user id is ${userId}");
        QuerySnapshot userSnap = await ref.where("user_id",isEqualTo: "${await FirebaseAuth.instance.currentUser!.uid}").get();
        if(userSnap.docs.isNotEmpty){
          print("login as user");
          //   login as a user
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => EventWiseHomeScreen()),
                (route) => false,
          );
        }else{
          CollectionReference ref = FirebaseFirestore.instance.collection('Organizers');
          QuerySnapshot orgSnap = await ref.where('id',isEqualTo: "${userId}").get();
          if(orgSnap.docs.isNotEmpty){
          //   login as organizer
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AllEventsScreen()),
                  (route) => false,
            );
          }
        }
      }
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (context) => EventWiseHomeScreen()),
      //       (route) => false,
      // );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed. \n Please check your credentials / Internet."),backgroundColor: Colors.red,),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    String emailPattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+" ;
    RegExp regex = RegExp(emailPattern);
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required';
    if (value.trim().length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Image.asset("assets/images/logo.png"),
                      const Text(
                        "EventWise",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Sign In", style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(height: 20),
                      event_wise_text_field(
                        textEditingController: _emailAddress,
                        context: context,
                        hintText: "Email Address",
                        icon: Icons.email,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 20),
                      event_wise_text_field(
                        textEditingController: _password,
                        context: context,
                        hintText: "Password",
                        icon: Icons.lock,
                        obscureText: true,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: elevated_button_style(),
                        onPressed: _signInUser,
                        child: const Text("Sign In"),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignUp()),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Sign Up", style: TextStyle(color: Colors.blue)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Center(
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       const Text("Login as an Organizer?"),
                      //       InkWell(
                      //         onTap: () {
                      //           Navigator.pushReplacement(
                      //             context,
                      //             MaterialPageRoute(builder: (context) => OrganizerSignIn()),
                      //           );
                      //         },
                      //         child: const Padding(
                      //           padding: EdgeInsets.all(8.0),
                      //           child: Text("Sign In", style: TextStyle(color: Colors.blue)),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}


