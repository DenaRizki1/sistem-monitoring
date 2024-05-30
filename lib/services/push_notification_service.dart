import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:sistem_monitoring/data/contants/module_notif.dart';
import 'package:sistem_monitoring/modules/auth/login_page.dart';
import 'package:sistem_monitoring/utils/constants.dart';
import 'package:sistem_monitoring/utils/routes/app_navigator.dart';
import 'package:sistem_monitoring/utils/sessions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  PushNotificationService() {
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
  }

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @pragma('vm:entry-point')
  Future initialise() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotificationAndroid,
      onDidReceiveBackgroundNotificationResponse: onSelectNotificationAndroid,
    );

    if (Platform.isIOS) {
      iospermission();
      final notificationSettings = await FirebaseMessaging.instance.requestPermission();
      if (notificationSettings.authorizationStatus == AuthorizationStatus.authorized) {
        log("grand permission ios");
      }
    }

    // FirebaseMessaging.instance.getToken().then((value) => log(value.toString()));
    // FirebaseMessaging.instance.getAPNSToken().then((value) => log(value.toString()));

    if (Platform.isAndroid) {
      androidPermission();
    }

    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    FirebaseMessaging.onMessage.listen(myForgroundMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(onSelectNotificationIos);
  }

  static void iospermission() {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static void androidPermission() {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
  }

  static Future<dynamic> myForgroundMessageHandler(RemoteMessage message) async {
    late AndroidNotificationChannel channel;

    if (kDebugMode) {
      print("myForgroundMessageHandler");
      print(message.data);
    }

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
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'ic_notification',
          ),
        ),
        payload: json.encode(message.data),
      );
    }

    switch (message.data['module']) {
      case ModuleNotif.FORCE_LOGOUT:
        await clearUserSession();
        AppNavigator.instance.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
          (p0) => false,
        );
        break;

      default:
        log("default");
        break;
    }
  }

  @pragma('vm:entry-point')
  static Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
    late AndroidNotificationChannel channel;

    if (kDebugMode) {
      print(message.data);
      print("myBackgroundMessageHandler");
    }

    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description: 'This channel is used for important notifications.', // description
        importance: Importance.high,
      );

      // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
      const InitializationSettings initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(),
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onSelectNotificationAndroid,
        onDidReceiveBackgroundNotificationResponse: onSelectNotificationAndroid,
      );

      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    }

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'ic_notification',
          ),
        ),
        payload: json.encode(message.data),
      );
    }

    //? pindah page tidak bisa langsung dari background
    switch (message.data['module'].toString()) {
      case ModuleNotif.FORCE_LOGOUT:
        await clearUserSession();
        break;

      default:
        log("default");
        break;
    }
  }

  @pragma('vm:entry-point')
  static Future<dynamic> onSelectNotificationIos(RemoteMessage message) async {
    if (kDebugMode) {
      print("Notification on click IOS");
    }
    await onClickNotification(message.data);
  }

  @pragma('vm:entry-point')
  static Future<dynamic> onSelectNotificationAndroid(NotificationResponse notificationResponse) async {
    if (kDebugMode) {
      print("Notification on click Android");
    }
    final payload = notificationResponse.payload;

    if (payload != null) {
      Map data = json.decode(payload);
      await onClickNotification(data);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onClickNotification(Map<dynamic, dynamic> data) async {
    if (kDebugMode) {
      print("Notification on click : $data");
    }
    switch (data['module'].toString()) {
      case ModuleNotif.FORCE_LOGOUT:
        bool isLoggedIn = await getPrefrenceBool(IS_LOGIN);
        if (!isLoggedIn) {
          AppNavigator.instance.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
            (p0) => false,
          );
        }
        break;

      case ModuleNotif.KEGIATAN:
        // AppNavigator.instance.push(
        //   MaterialPageRoute(
        //     builder: (context) => KlaimKomisiDetailPage(kdClaim: data['id'].toString()),
        //   ),
        // );
        break;

      case ModuleNotif.TRYOUT_JASMANI:
        // AppNavigator.instance.push(
        //   MaterialPageRoute(
        //     builder: (context) => KlaimKomisiDetailPage(kdClaim: data['id'].toString()),
        //   ),
        // );
        break;

      default:
        log("default");
        break;
    }
  }
}
