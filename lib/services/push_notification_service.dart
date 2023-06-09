import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:absentip/main.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/sessions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../page_login.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm;

  PushNotificationService(this._fcm);

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future initialise() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);

    if (Platform.isIOS) {
      iospermission();
    }

    _fcm.getToken().then((token) {
      setPrefrence(TOKEN, token.toString());
      log("TOKEN==${token.toString()}");
    });

    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    FirebaseMessaging.onMessage.listen(myForgroundMessageHandler);
    // FirebaseMessaging.onMessageOpenedApp.listen(myForgroundMessageHandler);
  }

  void iospermission() {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<dynamic> myForgroundMessageHandler(RemoteMessage message) async {
    late AndroidNotificationChannel channel;

    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description: 'This channel is used for important notifications.', // description
        importance: Importance.high,
      );

      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    }

    RemoteNotification? notification = message.notification;
    if (notification != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: json.encode(message.data),
      );
    }
    if (kDebugMode) {
      print(message.data);
    }

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      message.data['title'].toString(),
      message.data['message'].toString(),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: json.encode(message.data),
    );

    //? Notification on foreground
    switch (message.data['module'].toString()) {
      case "force_logout":
        clearUserSession();
        if (navigatorKey.currentContext != null) {
          Navigator.pushAndRemoveUntil(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) => const PageLogin()), (route) => false);
        }
        break;
      default:
        log("default");
        break;
    }
  }

  static Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
    late AndroidNotificationChannel channel;
    late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description: 'This channel is used for important notifications.', // description
        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: onSelectNotification,
      );

      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    }

    RemoteNotification? notification = message.notification;
    if (notification != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: json.encode(message.data),
      );
    }
    if (kDebugMode) {
      print(message.data);
    }
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      message.data['title'].toString(),
      message.data['message'].toString(),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: json.encode(message.data),
    );

    //? pindah page tidak bisa langsung dari background
    switch (message.data['module'].toString()) {
      case "force_logout":
        clearUserSession();
        if (navigatorKey.currentContext != null) {
          Navigator.pushAndRemoveUntil(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) => const PageLogin()), (route) => false);
        }
        break;
      default:
        log("default");
        break;
    }
  }

  //? Notification on click
  static Future<dynamic> onSelectNotification(payload) async {
    log(payload);
    var data = json.decode(payload);
    log(data['module'].toString());

    switch (data['module'].toString()) {
      case "force_logout":
        String tokenAuth = (await getPrefrence(TOKEN_AUTH)) ?? '';
        if (tokenAuth.isEmpty) {
          if (navigatorKey.currentContext != null) {
            Navigator.pushAndRemoveUntil(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) => const PageLogin()), (route) => false);
          }
        }
        break;

      default:
        log("default");
        break;
    }
  }

  // Future<void> subscribeToTopic(String topic) async {
  //   await FirebaseMessaging.instance.subscribeToTopic(topic);
  //   print('Subscribing to topic $topic successful.');
  // }

  // Future<void> unsubscribeToTopic(String topic) async {
  //   await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  //   print('Unsubscribing to topic $topic successful.');
  // }

  // Future<void> _requestPermissions() async {
  //   NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
  //     announcement: true,
  //     carPlay: true,
  //     criticalAlert: true,
  //   );

  //   // print(FirebasePermissionConstants.statusMap[settings.authorizationStatus]!);
  //   // if (defaultTargetPlatform == TargetPlatform.iOS) {
  //   //   print(FirebasePermissionConstants.settingsMap[settings.alert]!);
  //   //   print(FirebasePermissionConstants.settingsMap[settings.announcement]!);
  //   //   print(FirebasePermissionConstants.settingsMap[settings.badge]!);
  //   //   print(FirebasePermissionConstants.settingsMap[settings.carPlay]!);
  //   //   print(FirebasePermissionConstants.settingsMap[settings.lockScreen]!);
  //   //   print(
  //   //       FirebasePermissionConstants.settingsMap[settings.notificationCenter]!);
  //   //   print(FirebasePermissionConstants.previewMap[settings.showPreviews]!);
  //   //   print(FirebasePermissionConstants.settingsMap[settings.sound]!);
  //   // }
  // }
}
