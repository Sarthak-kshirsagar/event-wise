import 'package:btech/Presentation/Screens/LandingScreens/sign_up.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../data/models/AuthModel.dart';
import '../../../infrastructure/firebase/auth_service.dart';
import '../../styles/elevated_button_style.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../Dashboard/eventWiseHomeScreen.dart';
import '../components/textField.dart';
import 'organizerAdminPanel.dart';

class OrganizerSignIn extends StatefulWidget {
  const OrganizerSignIn({super.key});

  @override
  State<OrganizerSignIn> createState() => _OrganizerSignInState();
}

class _OrganizerSignInState extends State<OrganizerSignIn> {
  final AuthViewModel _authView = AuthViewModel(authRepo: EventWiseAuth());
  TextEditingController _emailAddress = TextEditingController();
  TextEditingController _password = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  bool isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 50),
                      Image.asset("assets/images/logo.png"),
                      Text("EventWise", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Organizer Sign In", style: TextStyle(fontSize: 20)),
                      ),
                      SizedBox(height: 20),
                      event_wise_text_field(
                        textEditingController: _emailAddress,
                        context: context,
                        hintText: "Email Address",
                        icon: Icons.email,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email is required';
                          if (!isEmailValid(value)) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      event_wise_text_field(
                        textEditingController: _password,
                        context: context,
                        hintText: "Password",
                        icon: Icons.password,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password is required';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: elevated_button_style(),
                        onPressed: () async {
                          CollectionReference ref = FirebaseFirestore.instance.collection("Organizers");
                          QuerySnapshot snapshot = await ref.where("email",isEqualTo: "${_emailAddress.text.trim()}").get();
                          if(snapshot.docs.isNotEmpty && await snapshot.docs.first['role']=='organizer'){
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);

                              AuthModel _userDetails = AuthModel(
                                email: _emailAddress.text.trim(),
                                password: _password.text.trim(),
                                name: '',
                              );

                              dynamic loginResult = await _authView.login(_userDetails);

                              setState(() => _isLoading = false);

                              if (loginResult == null) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => AllEventsScreen()),
                                      (route) => false,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Login failed: $loginResult"),backgroundColor: Colors.red,),
                                );
                              }
                            }
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Not a Organizer"),backgroundColor: Colors.red,),
                            );
                          }

                        },
                        child: Text("Sign In"),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Login as a User..?"),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignUp()),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Loading Indicator
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}



// class _OrganizerSignInState extends State<OrganizerSignIn> {
//   final AuthViewModel _authView = AuthViewModel(authRepo: EventWiseAuth());
//   TextEditingController _emailAddress = TextEditingController();
//   TextEditingController _password = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 // mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     height: 50,
//                   ),
//                   // Center(child: Text("Welcome to eventwise")),
//                   Image.asset("assets/images/logo.png"),
//                   Text(
//                     "EventWise",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//
//                   Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         "Organizer Sign In",
//                         style: TextStyle(fontSize: 20),
//                       )),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   event_wise_text_field(
//                       textEditingController: _emailAddress,
//                       context: context,
//                       hintText: "Email Address",
//                       icon: Icons.email),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   event_wise_text_field(
//                       textEditingController: _password,
//                       context: context, hintText: "Password", icon: Icons.password),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   ElevatedButton(
//                       style: elevated_button_style(),
//                       onPressed: () async{
//                         AuthModel _userDetails = AuthModel(
//                             email: _emailAddress.text.trim(),
//                             password: _password.text.trim(),name: '');
//                         dynamic loginResult = await _authView.login(_userDetails);
//                         if(loginResult==null){
//                           Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => AllEventsScreen(),), (route) => false,);
//                         }else{
//                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${_userDetails}")));
//                         }
//                       },
//
//                       child: Text("Sign In")),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   // Center(
//                   //   child: Row(
//                   //     mainAxisAlignment: MainAxisAlignment.center,
//                   //     children: [
//                   //       Text("Dont have an account..?"),
//                   //       InkWell(
//                   //           onTap: () {
//                   //             Navigator.pushReplacement(
//                   //                 context,
//                   //                 MaterialPageRoute(
//                   //                   builder: (context) => SignUp(),
//                   //                 ));
//                   //           },
//                   //           child: Padding(
//                   //             padding: const EdgeInsets.all(8.0),
//                   //             child: Text(
//                   //               "Sign Up",
//                   //               style: TextStyle(color: Colors.blue),
//                   //             ),
//                   //           ))
//                   //     ],
//                   //   ),
//                   // ),
//                   // SizedBox(height: 15,),
//                   Center(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text("Login as a User..?"),
//                         InkWell(
//                             onTap: () {
//                               Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => SignUp(),
//                                   ));
//                             },
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Text(
//                                 "Sign In",
//                                 style: TextStyle(color: Colors.blue),
//                               ),
//                             ))
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           )),
//     );
//   }
// }

