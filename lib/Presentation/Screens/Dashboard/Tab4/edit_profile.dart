import 'dart:ffi';

import 'package:btech/Presentation/styles/elevated_button_style.dart';
import 'package:btech/Presentation/viewmodels/user_viewModel.dart';
import 'package:btech/data/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../domain/repositories/users_repo.dart';
import '../../../../infrastructure/firebase/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  UserViewmodel _userServices = UserViewmodel(userServices: UserProfile() );
  Map<String,dynamic>? usersData = {};
  final TextEditingController nameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String gender = 'Male';
  String bloodGroup = 'A+';
  String profileUrl = '';

  Future<void> init()async{
    usersData = await _userServices.fetch_profile();
    print(usersData);
    setState(() {

    });
    if (usersData != null) {
      nameController.text = usersData!['user_name'] ?? '';
      middleNameController.text = usersData!['middle_name'] ?? '';
      lastNameController.text = usersData!['last_name'] ?? '';
      ageController.text = usersData!['user_age']?.toString() ?? '';
      gender = usersData!['gender'] ?? 'Male';
      bloodGroup = usersData!['blood_group'] ?? 'A+';
      profileUrl = usersData!['profile_pic'] ?? '';
    }
    setState(() {});
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RefreshIndicator(
          onRefresh: init,
          child: ListView(
            children: [
              const Center(
                child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/300')),
              ),
              const SizedBox(height: 20),
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "First Name")),
              TextField(
                  controller: middleNameController,
                  decoration: const InputDecoration(labelText: "Middle Name")),
              TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: "Last Name")),
              TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Age")),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: gender,
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) => gender = value ?? 'Male',
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: bloodGroup,
                items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                    .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                    .toList(),
                onChanged: (value) => bloodGroup = value ?? 'A+',
                decoration: const InputDecoration(labelText: "Blood Group"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: elevated_button_style(),
                onPressed: () async {
                  UserViewmodel _user =
                      UserViewmodel(userServices: UserProfile());
                  UserModel userDetails = UserModel(
                      userName: nameController.text.trim(),
                      bloodGroup: bloodGroup.trim(),
                      age: int.parse(ageController.text.trim()),
                      lastName: lastNameController.text.trim(),
                      gender: gender.trim(),
                      middleName: middleNameController.text.trim(),
                      profileUrl: profileUrl);
                  await _user.create_profile(user: userDetails);
                },
                child: const Text("Save"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
