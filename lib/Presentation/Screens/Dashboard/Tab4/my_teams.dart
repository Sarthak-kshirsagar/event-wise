import 'package:btech/Presentation/styles/elevated_button_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'invitations.dart';

class MyTeamsScreen extends StatefulWidget {
  const MyTeamsScreen({Key? key}) : super(key: key);

  @override
  State<MyTeamsScreen> createState() => _MyTeamsScreenState();
}

class _MyTeamsScreenState extends State<MyTeamsScreen> {
  List<Map<String, dynamic>>? users = [];
  Set<String> selectedUsers = {};
  TextEditingController teamNameController = TextEditingController();
  List<Map<String, dynamic>> my_teams = [];

  Future<List<Map<String, dynamic>>?> fetch_users() async {
    final CollectionReference usersRef =
        FirebaseFirestore.instance.collection("Users");
    QuerySnapshot usersSnap = await usersRef.get();
    FirebaseAuth _auth = FirebaseAuth.instance;

    List<Map<String, dynamic>> usersList = [];

    if (usersSnap.docs.isNotEmpty) {
      for (var userDoc in usersSnap.docs) {
        Map<String, dynamic> current_user =
            userDoc.data() as Map<String, dynamic>;

        // 🚫 Skip current logged-in user
        if (current_user['user_id'] == _auth.currentUser!.uid) continue;

        if (current_user.containsKey('user_name') &&
            current_user.containsKey('user_id') &&
            current_user.containsKey('last_name')) {
          usersList.add({
            'name': current_user['user_name'],
            'last_name': current_user['last_name'],
            'id': current_user['user_id'],
          });
        }
      }
      return usersList;
    }
    return null;
  }

  Future<void> create_team() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final String currentUserId = _auth.currentUser!.uid;
    final CollectionReference usersRef =
        FirebaseFirestore.instance.collection("Users");

    QuerySnapshot usersSnap =
        await usersRef.where("user_id", isEqualTo: currentUserId).get();

    if (usersSnap.docs.isEmpty) return;

    final userDoc = usersSnap.docs.first;
    final CollectionReference teams = userDoc.reference.collection('Teams');

    // Check for duplicate name or member set
    QuerySnapshot existingTeamsSnap = await teams.get();
    for (var doc in existingTeamsSnap.docs) {
      Map<String, dynamic> teamData = doc.data() as Map<String, dynamic>;
      if ((teamData['team_name'] as String).toLowerCase() ==
          teamNameController.text.trim().toLowerCase()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "A team with this name already exists. Please choose a different name.")),
        );
        return;
      }

      List<dynamic> existingMembers = teamData['team_members'] ?? [];
      List<String> existingIds =
          existingMembers.map((e) => e['id'].toString()).toList();

      if (Set.from(existingIds).containsAll(selectedUsers) &&
          selectedUsers.containsAll(Set.from(existingIds))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "This combination of members already exists. Please choose different members.")),
        );
        return;
      }
    }

    // Build members with accepted: false
    List<Map<String, dynamic>> membersWithStatus =
        selectedUsers.map((id) => {'id': id, 'accepted': false}).toList();

    // Create the team
    DocumentReference newTeamRef = await teams.add({
      'team_name': teamNameController.text.trim(),
      'team_members': membersWithStatus,
      'created_by': currentUserId,
      'created_at': DateTime.now(),
    });

    // Send invitations
    for (var memberId in selectedUsers) {
      QuerySnapshot userSnap =
          await usersRef.where("user_id", isEqualTo: memberId).get();
      if (userSnap.docs.isNotEmpty) {
        await userSnap.docs.first.reference.collection("Invitations").add({
          'team_id': newTeamRef.id,
          'team_name': teamNameController.text.trim(),
          'from_user_id': currentUserId,
          'accepted': false,
          'timestamp': DateTime.now(),
        });
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              "Team '${teamNameController.text.trim()}' created and invitations sent!")),
    );
  }

  Future<void> fetch_teams() async {
    final CollectionReference usersRef =
    FirebaseFirestore.instance.collection("Users");
    FirebaseAuth _auth = FirebaseAuth.instance;
    QuerySnapshot usersSnap = await usersRef
        .where("user_id", isEqualTo: _auth.currentUser!.uid)
        .get();

    if (usersSnap.docs.isNotEmpty) {
      CollectionReference teams =
      usersSnap.docs.first.reference.collection('Teams');
      QuerySnapshot teamsSnap = await teams.get();

      List<Map<String, dynamic>> fetchedTeams = [];

      for (var teamDoc in teamsSnap.docs) {
        Map<String, dynamic> teamData = teamDoc.data() as Map<String, dynamic>;
        List<dynamic> memberMeta = teamData['team_members'] ?? [];

        List<Map<String, dynamic>> membersInfo = [];

        for (var member in memberMeta) {
          String memberId = member['id'];
          bool accepted = member['accepted'] ?? false;

          QuerySnapshot memberSnap =
          await usersRef.where("user_id", isEqualTo: memberId).get();

          if (memberSnap.docs.isNotEmpty) {
            Map<String, dynamic> memberData =
            memberSnap.docs.first.data() as Map<String, dynamic>;
            memberData['accepted'] = accepted;
            membersInfo.add(memberData);
          }
        }

        teamData['members_info'] = membersInfo;
        fetchedTeams.add(teamData);
      }

      setState(() {
        my_teams = fetchedTeams;
      });
    }
  }


  Future<List<Map<String, dynamic>>> my_team_members_infoo(
      {required List<dynamic> user_ids}) async {
    final CollectionReference usersRef =
        FirebaseFirestore.instance.collection('Users');
    List<Map<String, dynamic>> membersInfo = [];

    for (var uid in user_ids) {
      QuerySnapshot snapshot =
          await usersRef.where("user_id", isEqualTo: uid).get();
      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> currentUser =
            snapshot.docs.first.data() as Map<String, dynamic>;
        membersInfo.add(currentUser);
      }
    }

    return membersInfo;
  }

  Future<void> init() async {
    users = await fetch_users();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    init();
    fetch_teams();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Teams"),
          bottom: const TabBar(tabs: [
            Tab(text: "Create Team"),
            Tab(text: "Invitations"),
            Tab(text: "My Teams"),
          ]),
        ),
        body: TabBarView(
          children: [
            // Create Team Tab
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: teamNameController,
                    decoration: const InputDecoration(
                      labelText: "Team Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: users!.length,
                      itemBuilder: (context, index) {
                        final user =
                            "${users![index]['name']} ${users![index]['last_name']}";
                        final userId = users![index]['id'];
                        final isSelected = selectedUsers.contains(userId);
                        return ListTile(
                          title: Text(user),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : const Icon(Icons.circle_outlined),
                          onTap: () {
                            setState(() {
                              isSelected
                                  ? selectedUsers.remove(userId)
                                  : selectedUsers.add(userId);
                            });
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    style: elevated_button_style(),
                    onPressed: () async {
                      if (teamNameController.text.length > 5 &&
                          selectedUsers.length >= 1) {
                        await create_team();
                        selectedUsers.clear();
                        teamNameController.clear();
                        setState(() {});
                      } else {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Please select at least one member and provide a valid team name.")),
                        );
                      }
                    },
                    child: const Text("Create Team"),
                  ),
                ],
              ),
            ),
            InvitationsScreen(),
            // My Teams Tab
            // My Teams Tab
            RefreshIndicator(
              onRefresh: () async {
                await fetch_teams();
              },
              child: ListView.builder(
                itemCount: my_teams.length,
                itemBuilder: (context, index) {
                  final team = my_teams[index];
                  final teamName = team['team_name'] ?? 'Unnamed Team';
                  final members = team['members_info'] ?? [];
                  final memberStatusList = team['team_members'] ?? [];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 6),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        title: Text(teamName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        children: members.map<Widget>((member) {
                          final memberId = member['user_id'];
                          final fullName =
                              '${member['user_name']} ${member['last_name']}';
                          final status = memberStatusList.firstWhere(
                            (m) => m['id'] == memberId,
                            orElse: () => {'accepted': false},
                          );

                          final accepted = status['accepted'] ?? false;
                          return ListTile(
                            title: Text(fullName),
                            trailing: Icon(
                              accepted ? Icons.check_circle : Icons.cancel,
                              color: accepted ? Colors.green : Colors.red,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Center(
            //   child: Column(
            //     children: [
            //       const SizedBox(height: 20),
            //       const Text("Your created teams will appear here."),
            //       const SizedBox(height: 20),
            //       Expanded(
            //         child: ListView.builder(
            //           itemCount: my_teams.length,
            //           itemBuilder: (context, index) {
            //             final team = my_teams[index];
            //             final members = team['members_info'] ?? [];
            //
            //             return Card(
            //               margin: const EdgeInsets.all(8),
            //               child: Padding(
            //                 padding: const EdgeInsets.all(12),
            //                 child: Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text(
            //                       team['team_name'] ?? "Unnamed Team",
            //                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //                     ),
            //                     const SizedBox(height: 8),
            //                     ...members.map<Widget>((member) {
            //                       final fullName = "${member['user_name']} ${member['last_name']}";
            //                       final accepted = member['accepted']; // Fetching accepted status
            //
            //                       // Show acceptance status with a colored indicator
            //                       return Row(
            //                         children: [
            //                           Icon(
            //                             accepted ? Icons.check_circle : Icons.error,
            //                             color: accepted ? Colors.green : Colors.red,
            //                           ),
            //                           const SizedBox(width: 8),
            //                           Text("• $fullName"),
            //                         ],
            //                       );
            //                     }).toList(),
            //                   ],
            //                 ),
            //               ),
            //             );
            //           },
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
