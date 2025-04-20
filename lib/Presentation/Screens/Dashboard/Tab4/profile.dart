import 'package:btech/Presentation/Screens/Dashboard/Tab4/portfolio.dart';
import 'package:btech/Presentation/Screens/LandingScreens/sign_in.dart';
import 'package:btech/Presentation/viewmodels/user_viewModel.dart';
import 'package:btech/infrastructure/firebase/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'all_part.dart';
import 'edit_profile.dart';
import 'event_preferences.dart';
import 'faq.dart';
import 'help.dart';
import 'my_teams.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // First Section – Avatar + Name
            Column(
              children: const [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/300', // Replace with user's image URL
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Sarthak Kshirsagar", // Replace with dynamic name
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Second Section – Options
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Column(
                children: [
                  _ProfileOptionTile(
                    icon: Icons.groups,
                    title: "My Teams",
                    onTap: () => _navigateTo(context, const MyTeamsScreen()),
                  ),
                  const Divider(height: 1),
                  _ProfileOptionTile(
                    icon: Icons.work_outline,
                    title: "Won Events",
                    onTap: () => _navigateTo(context,  PortfolioScreen()),
                  ),
                  const Divider(height: 1),
                  _ProfileOptionTile(
                    icon: Icons.work_outline,
                    title: "My Portfolio",
                    onTap: () => _navigateTo(context,  AllParticipated()),
                  ),
                  const Divider(height: 1),
                  _ProfileOptionTile(
                    icon: Icons.event_available,
                    title: "Event Preferences",
                    onTap: () =>
                        _navigateTo(context, const EventPreferencesScreen()),
                  ),
                  const Divider(height: 1),
                  _ProfileOptionTile(
                    icon: Icons.person_outline,
                    title: "Profile",
                    onTap: () => _navigateTo(context, const EditProfileScreen()),
                  ),
                  const Divider(height: 1),
                  _ProfileOptionTile(
                    icon: Icons.question_answer_outlined,
                    title: "FAQ's",
                    onTap: () => _navigateTo(context, const FAQHelpScreen()),
                  ),
                  const Divider(height: 1),
                  _ProfileOptionTile(
                    icon: Icons.help_outline,
                    title: "Help",
                    onTap: () => _navigateTo(context, const HelpScreen()),
                  ),
                  const Divider(height: 1),
                  _ProfileOptionTile(
                    icon: Icons.logout,
                    title: "Logout",
                    onTap: ()async{
                      FirebaseAuth _auth = FirebaseAuth.instance;
                      _auth.signOut();
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignIn(),), (route) => false,);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _ProfileOptionTile({
    Key? key,
    required this.icon,
    required this.title,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
