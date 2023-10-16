import 'package:absentip/data/provider/main_provider.dart';
import 'package:absentip/page_splashscreen.dart';
import 'package:absentip/services/dependency_injection.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependecyInjection.init();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => MainProvider(),
      ),
    ],
    child: const MyApp(),
  )
      // DevicePreview(
      //   enabled: !kReleaseMode,
      //   builder: (context) => MultiProvider(
      //     providers: [
      //       ChangeNotifierProvider(
      //         create: (context) => MainProvider(),
      //       ),
      //     ],
      //     child: const MyApp(), // Wrap your app
      //   ),
      // ),
      );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MaterialColor getMaterialColor(Color color) {
      final int red = color.red;
      final int green = color.green;
      final int blue = color.blue;

      final Map<int, Color> shades = {
        50: Color.fromRGBO(red, green, blue, .1),
        100: Color.fromRGBO(red, green, blue, .2),
        200: Color.fromRGBO(red, green, blue, .3),
        300: Color.fromRGBO(red, green, blue, .4),
        400: Color.fromRGBO(red, green, blue, .5),
        500: Color.fromRGBO(red, green, blue, .6),
        600: Color.fromRGBO(red, green, blue, .7),
        700: Color.fromRGBO(red, green, blue, .8),
        800: Color.fromRGBO(red, green, blue, .9),
        900: Color.fromRGBO(red, green, blue, 1),
      };

      return MaterialColor(color.value, shades);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.instance.navigatorKey,
      title: 'Pengajar TIP',
      theme: ThemeData(
        primarySwatch: getMaterialColor(AppColor.hitam),
        appBarTheme: AppBarTheme(
          color: AppColor.biru,
          foregroundColor: Colors.black,
          systemOverlayStyle: const SystemUiOverlayStyle(
            // statusBarColor: Colors.transparent,
            /* set Status bar color in Android devices. */
            statusBarIconBrightness: Brightness.light,
            /* set Status bar icons color in Android devices.*/
            statusBarBrightness: Brightness.light,
            /* set Status bar icon color in iOS. */
          ),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontSize: 20,
            fontFamily: 'PoppinsRegular',
          ),
          centerTitle: false,
          iconTheme: const IconThemeData(color: Colors.black),
          actionsIconTheme: const IconThemeData(color: Colors.black),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'PoppinsRegular',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.biru,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      builder: EasyLoading.init(),
      initialRoute: '/',
      routes: {
        '/': (context) => const PageSplashscreen(),
      },
    );
  }
}
