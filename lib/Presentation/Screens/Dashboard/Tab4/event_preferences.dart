import 'package:btech/Presentation/styles/elevated_button_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventPreferencesScreen extends StatefulWidget {
  const EventPreferencesScreen({super.key});

  @override
  State<EventPreferencesScreen> createState() => _EventPreferencesScreenState();
}

class _EventPreferencesScreenState extends State<EventPreferencesScreen> {
  final preferences = {
    "AI/ML": false,
    "Cybersecurity": false,
    "Hackathons": false,
    "Robotics": false,
    "Cloud": false,
  };

  bool isLoading = true;

  Future<void> fetchAndSetPreferences() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final usersRef = FirebaseFirestore.instance.collection("Users");
      final userSnapshot =
      await usersRef.where("user_id", isEqualTo: userId).get();

      if (userSnapshot.docs.isNotEmpty) {
        final data = userSnapshot.docs.first.data();
        if (data.containsKey("user_preferences")) {
          final List<dynamic> storedPrefs = data["user_preferences"];
          for (var key in preferences.keys) {
            preferences[key] = storedPrefs.contains(key);
          }
        }
      }
    } catch (e) {
      print("Error fetching preferences: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> savePreferences() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final selectedPreferences = preferences.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      final usersRef = FirebaseFirestore.instance.collection("Users");
      final userSnapshot =
      await usersRef.where("user_id", isEqualTo: userId).get();

      if (userSnapshot.docs.isNotEmpty) {
        final userDocRef = userSnapshot.docs.first.reference;
        await userDocRef.update({
          'user_preferences': selectedPreferences,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Preferences saved successfully!")),
        );
      }
    } catch (e) {
      print("Error saving preferences: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving preferences.")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAndSetPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event Preferences")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView(
              children: preferences.entries.map((entry) {
                return CheckboxListTile(
                  title: Text(entry.key),
                  value: entry.value,
                  onChanged: (val) {
                    setState(() {
                      preferences[entry.key] = val ?? false;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
            style: elevated_button_style(),
            onPressed: savePreferences,
            child: const Text("Save Preferences"),
          ),
          SizedBox(height: 10,),
        ],
      ),
    );
  }
}
