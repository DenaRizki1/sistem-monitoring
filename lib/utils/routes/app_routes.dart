import 'dart:js';

import 'package:sistem_monitoring/modules/auth/login_page.dart';
import 'package:sistem_monitoring/modules/detail/detail_sensor_page.dart';
import 'package:sistem_monitoring/modules/history/history_page.dart';
import 'package:sistem_monitoring/modules/home/home_page.dart';

class AppRoutes {
  AppRoutes._();

  // ignore: constant_identifier_names
  static const INITIAL = HomePage.routeName;

  static final routes = {
    // SplashScreenPage.routeName: (context) => const SplashScreenPage(),
    // BerandaPage.routeName: (context) => const BerandaPage(),
    // LoginPage.routeName: (context) => const LoginPage(),
    // DaftarAkunPage.routeName: (context) => const DaftarAkunPage(),
    // ChatAiPage.routeName: (context) => const ChatAiPage(),
    LoginPage.routeName: (context) => const LoginPage(),
    HomePage.routeName: (context) => const HomePage(),
    DetailSensorPage.routeName: (context) => const DetailSensorPage(),
    HistoryPage.routeName: (context) => const HistoryPage(),
  };
}
