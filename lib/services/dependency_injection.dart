import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../firebase_options.dart';
import 'push_notification_service.dart';

class DependecyInjection {
  static Future<void> init() async {
    // firebase init
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // String version = packageInfo.version;
    // String buildNumber = packageInfo.buildNumber;

    // await box.write(KeySession.VERSION, version);
    // await box.write(KeySession.BUILD_NUMBER, buildNumber);

    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    final pushNotificationService = PushNotificationService(firebaseMessaging);
    pushNotificationService.initialise();
  }
}
