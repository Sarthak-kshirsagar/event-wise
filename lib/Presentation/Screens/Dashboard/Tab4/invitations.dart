import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InvitationsScreen extends StatefulWidget {
  @override
  _InvitationsScreenState createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final CollectionReference usersRef = FirebaseFirestore.instance.collection("Users");

  // Future<void> acceptInvitation(DocumentSnapshot invitationDoc) async {
  //   final data = invitationDoc.data() as Map<String, dynamic>;
  //   final String fromUserId = data['from_user_id'];
  //   final String teamId = data['team_id'];
  //
  //   try {
  //     // 1. Update invitation as accepted
  //     await invitationDoc.reference.update({'accepted': true});
  //
  //     // 2. Find the team in creator's teams
  //     DocumentSnapshot teamDoc = await usersRef
  //         .where("user_id", isEqualTo: fromUserId)
  //         .get()
  //         .then((snap) => snap.docs.first.reference.collection("Teams").doc(teamId).get());
  //
  //     if (teamDoc.exists) {
  //       Map<String, dynamic> teamData = teamDoc.data() as Map<String, dynamic>;
  //       List<dynamic> members = teamData['team_members'];
  //
  //       // 3. Update 'accepted' field for current user
  //       List updatedMembers = members.map((m) {
  //         if (m['id'] == currentUserId) {
  //           return {'id': m['id'], 'accepted': true};
  //         }
  //         return m;
  //       }).toList();
  //
  //       await teamDoc.reference.update({'team_members': updatedMembers});
  //     }
  //
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invitation accepted.')));
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  //   }
  // }

  // Future<void> acceptInvitation(DocumentSnapshot invitationDoc) async {
  //   final data = invitationDoc.data() as Map<String, dynamic>;
  //   final String fromUserId = data['from_user_id'];
  //   final String teamId = data['team_id'];
  //
  //   try {
  //     // Reference to current user doc
  //     final currentUserDocRef = await usersRef.where("user_id", isEqualTo: currentUserId).get().then((snap) => snap.docs.first.reference);
  //
  //     // Reference to sender user doc
  //     final fromUserDocRef = await usersRef.where("user_id", isEqualTo: fromUserId).get().then((snap) => snap.docs.first.reference);
  //
  //     // Reference to team in sender's Teams collection
  //     final teamDocRef = fromUserDocRef.collection("Teams").doc(teamId);
  //     final teamDoc = await teamDocRef.get();
  //
  //     if (teamDoc.exists) {
  //       Map<String, dynamic> teamData = teamDoc.data() as Map<String, dynamic>;
  //
  //       // Update member's accepted status in the original team
  //       List<dynamic> members = teamData['team_members'];
  //       List updatedMembers = members.map((m) {
  //         if (m['id'] == currentUserId) {
  //           return {'id': m['id'], 'accepted': true};
  //         }
  //         return m;
  //       }).toList();
  //
  //       await teamDocRef.update({'team_members': updatedMembers});
  //
  //       // Add the same team to current user's Teams collection
  //       await currentUserDocRef.collection("Teams").doc(teamId).set({
  //         ...teamData,
  //         'team_members': updatedMembers,
  //         'copied_from': fromUserId, // optional for traceability
  //       });
  //
  //       // Delete the invitation
  //       await invitationDoc.reference.delete();
  //
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invitation accepted and team added.')));
  //       setState(() {
  //
  //       });
  //     } else {
  //       throw Exception("Team document not found.");
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  //   }
  // }

  Future<void> acceptInvitation(DocumentSnapshot invitationDoc) async {
    final data = invitationDoc.data() as Map<String, dynamic>;
    final String fromUserId = data['from_user_id'];
    final String teamId = data['team_id'];

    try {
      final currentUserDocRef = await usersRef.where("user_id", isEqualTo: currentUserId).get().then((snap) => snap.docs.first.reference);
      final fromUserDocRef = await usersRef.where("user_id", isEqualTo: fromUserId).get().then((snap) => snap.docs.first.reference);

      final teamDocRef = fromUserDocRef.collection("Teams").doc(teamId);
      final teamDoc = await teamDocRef.get();

      if (!teamDoc.exists) throw Exception("Team document not found.");

      Map<String, dynamic> teamData = teamDoc.data() as Map<String, dynamic>;
      List<dynamic> members = teamData['team_members'];

      // 1. Update current user's status to accepted
      List updatedMembers = members.map((m) {
        if (m['id'] == currentUserId) {
          return {'id': m['id'], 'accepted': true};
        }
        return m;
      }).toList();

      // 2. Update the original team doc
      await teamDocRef.update({'team_members': updatedMembers});

      // 3. Update all accepted users' team copies
      for (var member in updatedMembers) {
        if (member['accepted'] == true) {
          final userDocRef = await usersRef.where("user_id", isEqualTo: member['id']).get().then((snap) => snap.docs.first.reference);
          await userDocRef.collection("Teams").doc(teamId).set({
            ...teamData,
            'team_members': updatedMembers,
            'copied_from': fromUserId, // optional
          });
        }
      }

      // 4. Delete the invitation
      await invitationDoc.reference.delete();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invitation accepted and team synced.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }


  Future<List<DocumentSnapshot>> getInvitations() async {
    try {
      final userSnap = await usersRef.where("user_id", isEqualTo: currentUserId).get();
      if (userSnap.docs.isNotEmpty) {
        var invitationsRef = userSnap.docs.first.reference.collection('Invitations');
        var invitationsSnap = await invitationsRef.where('accepted', isEqualTo: false).get();
        return invitationsSnap.docs;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: getInvitations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No pending invitations"));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data![index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    data['team_name'] ?? 'Unnamed Team',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Invitation from ${data['from_user_id']}"),
                  trailing: ElevatedButton(
                    onPressed: () => acceptInvitation(doc),
                    child: Text("Accept"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
