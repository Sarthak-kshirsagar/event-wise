import 'package:btech/Presentation/viewmodels/auth_viewmodel.dart';
import 'package:btech/data/models/AuthModel.dart';
import 'package:btech/domain/repositories/auth_repo.dart';
import 'package:btech/infrastructure/firebase/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Presentation/Screens/Dashboard/eventWiseHomeScreen.dart';
import 'Presentation/Screens/LandingScreens/sign_in.dart';
import 'Presentation/Screens/components/textField.dart';
import 'Presentation/styles/elevated_button_style.dart';
import 'firebase_options.dart';
import 'infrastructure/FCM/NotificationService.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    print("Background message received: ${message.notification?.title}");
    final NotificationService service = NotificationService();
    service.showPopUp(message);
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await Firebase.initializeApp();

  // Initialize NotificationService
  NotificationService notificationService = NotificationService();

  runApp(MyApp(notificationService: notificationService));
}

class MyApp extends StatefulWidget {
  final NotificationService notificationService;

  const MyApp({required this.notificationService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.notificationService.firebaseInit(context);
    widget.notificationService.setupInteractMessaging(context);
    widget.notificationService.initLocalNotifications(context, RemoteMessage(
        notification: RemoteNotification(title: "Init", body: "Init"),
        data: {}
    ));
    widget.notificationService.firebaseInit(context);
    widget.notificationService.setupInteractMessaging(context);
    widget.notificationService.iosForegroundMessage();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: SignIn());
  }
}


// landingPage->login or signup->tab 1 homePage(events based on trending,recommendation,college,feedback)
// tab2 show events based on map
// tab 3 current events -> qr code scanning,event updates,evetn wise chat
// tab 4-> Tab4 (Tab4,settings,teams,portfolio)



// authentication -> done
// fetch all organizers and events -> done
// profile complete of students -> done
// team creation for users -> done
// register for events ->
// qr functionality with events app
// api integration
// payment gateway integration


// 1) input form validation -> done
// 4) events should be registered only once
// 3) team invitation -> done
// 2) don't show user name while creating the team -> done

// ======= extra features =========
// 1) show the winner of event
// 2) event should be shareable

// ==== today tasks ======
// set user preferences
// show trending events
// modify ui and show loading screen