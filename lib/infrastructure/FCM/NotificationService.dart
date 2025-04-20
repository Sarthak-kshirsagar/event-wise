import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'get_current_user.dart';



class NotificationService {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin notifications =
  FlutterLocalNotificationsPlugin();

  // Shows the red dot when new notification is received
  ValueNotifier<bool> hasNewNotification = ValueNotifier(false);
  void addNewNotification() {
    hasNewNotification.value = true;
  }

  void clearNewNotifications() {
    hasNewNotification.value = false;
  }

  void firebaseInit(BuildContext context) async {
    String? userId = await getCurrentUserId();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground Notification Received:");
      if (message.notification != null) {
        print("Title: ${message.notification!.title}");
        print("Body: ${message.notification!.body}");
        // handleMessage(context, message);
      }
      if (message.data.isNotEmpty) {
        print("Data Payload is here from firebase init: ${message.data}");
      }
      showPopUp(message);

      // storeNotification(userId!, message);
      hasNewNotification.value = true;
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }


  Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    // Handle background message here
    print("Background message received: ${message.notification?.title}");
    showPopUp(message);

  }


  // interacting messaging
  Future<void> setupInteractMessaging(BuildContext context) async {

    print("setting up the interact messaging service");
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification under setup opened from background:");
      if (message.notification != null) {
        print("Title: ${message.notification!.title}");
        print("Body: ${message.notification!.body}");
      }
      if (message.data.isNotEmpty) {
        print("Data Payload is here from setup interact: ${message.data}");
      }
      handleMessage(context, message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("Notification opened from terminated state:");
        if (message.notification != null) {
          print("Title: ${message.notification!.title}");
          print("Body: ${message.notification!.body}");
        }
        if (message.data.isNotEmpty) {
          print("Data Payload: ${message.data}");
        }
        handleMessage(context, message);
      }
    });
  }

  void requestNotificationPermission() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        sound: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User permission granted");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("User provisional status granted");
    } else {
      print("Permission denied");
      Future.delayed(
        Duration(seconds: 2),
            () {
          AppSettings.openAppSettings(type: AppSettingsType.notification);
        },
      );
    }
  }

  Future<String?> getDeviceToken() async {
    String? token = await firebaseMessaging.getToken();
    print("Got the token of the user: $token");
    return token;
  }

  Future<void> storeAndRefreshFCMToken(String userId) async {
    String? token = await firebaseMessaging.getToken();
    if (token != null) {
      await _saveTokenToDatabase(userId, token);
    }

    firebaseMessaging.onTokenRefresh.listen((newToken) async {
      await _saveTokenToDatabase(userId, newToken);
    }).onError((err) {
      print("Error while refreshing token: $err");
    });
  }

  Future<void> _saveTokenToDatabase(String userId, String token) async {
    try {
      final CollectionReference digiSchoolRef =
      FirebaseFirestore.instance.collection("Users");
      final QuerySnapshot snapshot = await digiSchoolRef
          .where("user_id", isEqualTo: userId)
          .get();
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({"fcmToken": token});
        print("Token added in the station manager reference");
      } else {
        print("Snapshot not found to add the token in manager DB");
      }
    } on Exception catch (e) {
      print("Exception in adding the FCM token in manager app: $e");
    }
  }
  Future<String?>getFcmToken(String userId)async{
    final CollectionReference ref = FirebaseFirestore.instance.collection("Users");
    final QuerySnapshot snapshot = await ref.where("user_id",isEqualTo: "${userId}"
    ).get();
    final String? fcmToken = await snapshot.docs.first['fcmToken'];

    return fcmToken;
  }


  Future<void> initLocalNotifications(BuildContext context, RemoteMessage msg) async {
    var androidInitSettingg =
    const AndroidInitializationSettings('@mipmap/ic_launcher');

    var iosInitSetting = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
      android: androidInitSettingg,
      iOS: iosInitSetting,
    );

    await notifications.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
          // handleMessage(context, msg);
        });

    if (Platform.isAndroid) {
      String channelId = "default_channel";
      print("==========================================================");
      print("channel is is ${channelId}");

      AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        'Default Channel', // Channel name
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }


  void iosForegroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
        sound: true, badge: true, alert: true);
  }

  Future<void> showPopUp(RemoteMessage? msg) async {
    String channelId = msg!.notification!.android!.channelId ?? 'default_channel';

    AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      'Default Channel',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: "Channel Description",
      importance: Importance.high,
      playSound: true,
      sound: channel.sound,
      priority: Priority.high,
    );

    DarwinNotificationDetails darwinNotificationDetails =
    DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);


    await notifications.show(
        0,
        msg.notification!.title.toString(),
        msg.notification!.body.toString(),
        notificationDetails,
        payload: "my data");
  }



  Future<void> handleMessage(
      BuildContext context, RemoteMessage message) async {
    // Parse the payload string into a Map
    print("under the handle msg");
    try {

      Map<String, dynamic> payloadData = {};

      if (message.data.containsKey('screen')) {
        payloadData = json.decode(message.data['screen']);;
        print("under the handle payload is ${payloadData}");
        print("screen is ${payloadData['screen']}");
      }

      // Navigate to the desired screen
      if (payloadData['screen'] == 'parentHomeTab') {

      }else if(payloadData['screen']=='homeWorkTab'){

      }else if(payloadData['screen']=='message'){

      }else if(payloadData['screen']=='teacherMsg'){

      }
    } catch (e) {
      print("Error parsing payload or navigating: $e");
    }
  }


}
