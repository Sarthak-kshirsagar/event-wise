import 'package:btech/Presentation/Screens/Dashboard/eventWiseHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EligibleTeamsScreen extends StatefulWidget {
  final int minTeamSize;
  final int maxTeamSize;
  final String eventId;
  final String organizer_id;

  const EligibleTeamsScreen({
    super.key,
    required this.organizer_id,
    required this.minTeamSize,
    required this.maxTeamSize,
    required this.eventId,
  });

  @override
  State<EligibleTeamsScreen> createState() => _EligibleTeamsScreenState();
}

class _EligibleTeamsScreenState extends State<EligibleTeamsScreen> {
  List<Map<String, dynamic>> myTeams = [];
  Map<String, dynamic>? selectedTeam;

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userSnap = await FirebaseFirestore.instance
        .collection("Users")
        .where("user_id", isEqualTo: userId)
        .get();

    if (userSnap.docs.isNotEmpty) {
      final teamsRef = userSnap.docs.first.reference.collection("Teams");
      final teamsSnap = await teamsRef.get();

      List<Map<String, dynamic>> fetchedTeams = [];

      for (var doc in teamsSnap.docs) {
        Map<String, dynamic> data = doc.data();
        List<dynamic> membersRaw = data["team_members"] ?? [];

        if (membersRaw.length >= widget.minTeamSize &&
            membersRaw.length <= widget.maxTeamSize) {
          List<Map<String, dynamic>> memberDetails = [];

          for (var member in membersRaw) {
            String uid = member['id'];
            bool accepted = member['accepted'];

            final snapshot = await FirebaseFirestore.instance
                .collection("Users")
                .where("user_id", isEqualTo: uid)
                .get();

            if (snapshot.docs.isNotEmpty) {
              final user = snapshot.docs.first.data();
              memberDetails.add({
                "user_id": uid,
                "user_name": user['user_name'],
                "last_name": user['last_name'],
                "accepted": accepted,
              });
            }
          }

          data['members_info'] = memberDetails;
          data['doc_id'] = doc.id;

          fetchedTeams.add(data);
        }
      }

      setState(() {
        myTeams = fetchedTeams;
      });
    }
  }

  // Function to show a prompt to the user if no teams are found
  void _showCreateTeamPrompt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Eligible Teams Found'),
          content: const Text('Would you like to create a team?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to a screen where the user can create a team
                Navigator.pushNamed(context, '/create-team');
              },
              child: const Text('Create Team'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Register the selected team for the event
  Future<void> registerSelectedTeam({required organizerId}) async {
    if (selectedTeam == null) return;

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final ref = FirebaseFirestore.instance.collection("Organizers");
    final organizeSnap = await ref.where("id", isEqualTo: organizerId).get();

    if (organizeSnap.docs.isNotEmpty) {
      final eventRef = organizeSnap.docs.first.reference.collection('Events');
      final eventSnap =
      await eventRef.where("id", isEqualTo: widget.eventId).get();

      if (eventSnap.docs.isNotEmpty) {
        final registerRef = eventSnap.docs.first.reference.collection('Registrations');

        final currentUserRef = FirebaseFirestore.instance.collection("Users");
        final currentUserSnap = await currentUserRef
            .where("user_id", isEqualTo: _auth.currentUser!.uid)
            .get();

        if (currentUserSnap.docs.isNotEmpty) {
          final userDoc = currentUserSnap.docs.first;
          final userData = userDoc.data();
          final List<dynamic> registeredEvents =
              userData['registered_events'] ?? [];

          // 🔁 Check if already registered
          if (registeredEvents.contains(widget.eventId)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.orange,
                content: Text("Already registered for this event."),
              ),
            );
            return;
          }

          // ✅ Check if all team members have accepted
          bool allAccepted = true;
          List<dynamic> memberIds = selectedTeam?['team_members'] ?? [];
          for (var member in memberIds) {
            if (!member['accepted']) {
              allAccepted = false;
              break; // No need to check further if one member hasn't accepted
            }
          }

          if (!allAccepted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.orange,
                content: Text("All team members must accept the invitation to register."),
              ),
            );
            return;
          }

          // ✅ Register team
          await registerRef.add({
            'team_name': selectedTeam?['team_name'],
            'members': memberIds,
            'user_id': _auth.currentUser!.uid,
            'payment_info': {},
          });

          // 🧠 Add event to portfolio of each member
          for (var member in memberIds) {
            final userRef = FirebaseFirestore.instance.collection("Users");
            final userSnap =
            await userRef.where("user_id", isEqualTo: member['id']).get();

            if (userSnap.docs.isNotEmpty) {
              await userSnap.docs.first.reference.collection('Portfolio').add({
                'organizer_id': widget.organizer_id,
                'event_id': widget.eventId,
              });

              await userSnap.docs.first.reference.update({
                'registered_events': FieldValue.arrayUnion([widget.eventId])
              });
            }
          }

          // ✅ Add to current user’s portfolio & update registered_events
          await userDoc.reference.collection('Portfolio').add({
            'organizer_id': widget.organizer_id,
            'event_id': widget.eventId,
          });

          await userDoc.reference.update({
            'registered_events': FieldValue.arrayUnion([widget.eventId])
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Registered for event"),
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => EventWiseHomeScreen()),
                (route) => false,
          );
        }
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Team for Event"),
      ),
      body: myTeams.isEmpty
          ? const Center(child: Text("No Teams Found"))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Text(
                    "Eligible Teams",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: myTeams.length,
                      itemBuilder: (context, index) {
                        final team = myTeams[index];
                        final isSelected =
                            selectedTeam?['doc_id'] == team['doc_id'];

                        return Card(
                          color: isSelected ? Colors.blue[100] : null,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              team['team_name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                ...team['members_info'].map<Widget>((member) {
                                  return Text(
                                    "• ${member['user_name']} ${member['last_name']} - ${member['accepted'] ? 'Accepted' : 'Not Accepted'}",
                                    style: TextStyle(
                                      color: member['accepted'] ? Colors.green : Colors.red,
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : const Icon(Icons.circle_outlined),
                            onTap: () {
                              setState(() {
                                selectedTeam = team;
                              });
                            },
                          ),
                            
                        );
                      },
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: selectedTeam != null
                        ? () async {
                            await registerSelectedTeam(
                                organizerId: widget.organizer_id);
                          }
                        : null,
                    icon: const Icon(Icons.app_registration),
                    label: const Text("Register Team"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
