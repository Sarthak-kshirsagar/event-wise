import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../../infrastructure/FCM/NotificationService.dart';
import 'Tab1/dashboard.dart';
import 'Tab3/my_events.dart';
import 'Tab4/profile.dart';

class EventWiseHomeScreen extends StatefulWidget {
  const EventWiseHomeScreen({Key? key}) : super(key: key);

  @override
  State<EventWiseHomeScreen> createState() => _EventWiseHomeScreenState();
}

class _EventWiseHomeScreenState extends State<EventWiseHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    // OpenStreetMapScreen(),
    MyEventsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> set_up_notification()async{
    FirebaseAuth _auth = FirebaseAuth.instance;
    String userId = await _auth.currentUser!.uid;
    NotificationService fcm = NotificationService();
   await fcm.storeAndRefreshFCMToken(userId);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final NotificationService notificationService = NotificationService();
    notificationService.requestNotificationPermission();
    notificationService.initLocalNotifications(context, RemoteMessage(
        notification: RemoteNotification(title: "Init", body: "Init"),
        data: {}
    ));
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessaging(context);
    notificationService.iosForegroundMessage();
    NotificationService fcm = NotificationService();
    set_up_notification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'My Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}


