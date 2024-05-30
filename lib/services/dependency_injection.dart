import 'dart:isolate';

import 'package:sistem_monitoring/utils/my_custom_timeago_messages.dart';
import 'package:sistem_monitoring/utils/constants.dart';
import 'package:sistem_monitoring/utils/sessions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../firebase_options.dart';
import 'push_notification_service.dart';

import 'package:timeago/timeago.dart' as timeago;

class DependecyInjection {
  static Future<void> init() async {
    // firebase init
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    timeago.setLocaleMessages('id', MyCustomTimeagoMessages());

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    setPrefrence(VERSION, version);
    setPrefrence(BUILD_NUMBER, buildNumber);

    final pushNotificationService = PushNotificationService();
    pushNotificationService.initialise();

    // Plugin must be initialized before using
    await FlutterDownloader.initialize(
      debug: true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl: true, // option: set to false to disable working with http links (default: false)
    );

    await FlutterDownloader.registerCallback(downloadCallback);
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String taskId, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([taskId, status, progress]);
  }
}
