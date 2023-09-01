import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForegroundService {
  ForegroundService() {
    if (Platform.isIOS) {
      iospermission();
    }

    if (Platform.isAndroid) {
      androidPermission();
    }
  }

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    final service = FlutterBackgroundService();

    /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'MY FOREGROUND SERVICE', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
    );

    if (Platform.isIOS || Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          // android: AndroidInitializationSettings('ic_bg_service_small'),
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: onSelectNotificationAndroid,
        onDidReceiveBackgroundNotificationResponse: onSelectNotificationAndroid,
      );
    }

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,

        // auto start service
        autoStart: true,
        isForegroundMode: true,

        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'AWESOME SERVICE',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,

        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,

        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );

    service.startService();
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

  @pragma('vm:entry-point')
  Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    final log = preferences.getStringList('log') ?? <String>[];
    log.add(DateTime.now().toIso8601String());
    await preferences.setStringList('log', log);

    return true;
  }

  @pragma('vm:entry-point')
  void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    // For flutter prior to version 3.0.0
    // We have to register the plugin manually

    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // await preferences.setString("hello", "world");

    /// OPTIONAL when use custom notification
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // bring to foreground
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          /// OPTIONAL for use custom notification
          /// the notification id must be equals with AndroidConfiguration when you call configure() method.
          flutterLocalNotificationsPlugin.show(
            888,
            'COOL SERVICE',
            'Awesome ${DateTime.now()}',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'my_foreground',
                'MY FOREGROUND SERVICE',
                icon: '@mipmap/ic_launcher',
                ongoing: true,
                actions: [
                  AndroidNotificationAction(
                    "stop_lokasi",
                    "Stop Lokasi",
                    cancelNotification: false,
                  ),
                ],
              ),
            ),
          );

          getNotifikasi();

          /// if you don't using custom notification, uncomment this
          // service.setForegroundNotificationInfo(
          //   title: "My App Service",
          //   content: "Updated at ${DateTime.now()}",
          // );
        }
      }

      /// you can see this log in logcat
      if (kDebugMode) {
        print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
      }

      // test using external plugin
      final deviceInfo = DeviceInfoPlugin();
      String? device;
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        device = androidInfo.model;
      }

      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        device = iosInfo.model;
      }

      service.invoke(
        'update',
        {
          "current_date": DateTime.now().toIso8601String(),
          "device": device,
        },
      );
    });
  }

  @pragma('vm:entry-point')
  Future<dynamic> onSelectNotificationAndroid(NotificationResponse notificationResponse) async {
    if (kDebugMode) {
      print("Notification on click Android");
      print(notificationResponse.actionId.toString());
    }

    if (notificationResponse.actionId.toString() == "stop_lokasi") {
      final service = FlutterBackgroundService();
      var isRunning = await service.isRunning();
      if (isRunning) {
        service.invoke("stopService");
        exitApp();
      }
    }
  }

  getNotifikasi() async {
    final pref = await SharedPreferences.getInstance();
    ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.notif,
      params: {
        'hash_user': pref.getString(HASH_USER) ?? "",
        'token_auth': pref.getString(TOKEN_AUTH) ?? "",
      },
    );
  }
}


// Column(
//   children: [
//     StreamBuilder<Map<String, dynamic>?>(
//       stream: FlutterBackgroundService().on('update'),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         final data = snapshot.data!;
//         String? device = data["device"];
//         DateTime? date = DateTime.tryParse(data["current_date"]);
//         return Column(
//           children: [
//             Text(device ?? 'Unknown'),
//             Text(date.toString()),
//           ],
//         );
//       },
//     ),
//     ElevatedButton(
//       child: const Text("Foreground Mode"),
//       onPressed: () {
//         FlutterBackgroundService().invoke("setAsForeground");
//       },
//     ),
//     ElevatedButton(
//       child: const Text("Background Mode"),
//       onPressed: () {
//         FlutterBackgroundService().invoke("setAsBackground");
//       },
//     ),
//     ElevatedButton(
//       child: Text(text),
//       onPressed: () async {
//         final service = FlutterBackgroundService();
//         var isRunning = await service.isRunning();
//         if (isRunning) {
//           service.invoke("stopService");
//         } else {
//           service.startService();
//         }

//         if (!isRunning) {
//           text = 'Stop Service';
//         } else {
//           text = 'Start Service';
//         }
//         setState(() {});
//       },
//     ),
//   ],
// )