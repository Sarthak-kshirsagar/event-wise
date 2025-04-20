import 'package:btech/Presentation/Screens/LandingScreens/sign_in.dart';
import 'package:flutter/material.dart';

import '../../../data/models/AuthModel.dart';
import '../../../infrastructure/firebase/auth_service.dart';
import '../../styles/elevated_button_style.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../components/textField.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthViewModel _authView = AuthViewModel(authRepo: EventWiseAuth());

  final TextEditingController _emailAddress = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Validators
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return "Name cannot be empty";
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return "Email is required";
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return "Enter a valid email";
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _password.text) {
      return "Passwords do not match";
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      AuthModel _userDetails = AuthModel(
        email: _emailAddress.text.trim(),
        password: _password.text.trim(),
        name: _name.text.trim(),
      );

      dynamic registerResult = await _authView.register(_userDetails);

      if (registerResult == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration Successful"),backgroundColor: Colors.green,),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$registerResult")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Sign Up", style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(height: 20),
                  event_wise_text_field(
                    textEditingController: _name,
                    context: context,
                    hintText: "Full Name",
                    icon: Icons.person,
                    validator: _validateName,
                  ),
                  const SizedBox(height: 20),
                  event_wise_text_field(
                    textEditingController: _emailAddress,
                    context: context,
                    hintText: "Your Email Address",
                    icon: Icons.email,
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  event_wise_text_field(
                    textEditingController: _password,
                    context: context,
                    hintText: "Your Password",
                    icon: Icons.lock,
                    validator: _validatePassword,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  event_wise_text_field(
                    textEditingController: _confirmPassword,
                    context: context,
                    hintText: "Confirm Password",
                    icon: Icons.lock_outline,
                    validator: _validateConfirmPassword,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: elevated_button_style(),
                    onPressed: _submitForm,
                    child: const Text("Sign Up"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account..?"),
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SignIn()),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Sign In", style: TextStyle(color: Colors.blue)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

