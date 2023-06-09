import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:absentip/services/dependency_injection.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;

import 'my_colors.dart';
import 'my_custom_timeago_messages.dart';
import 'page_beranda.dart';
import 'page_login.dart';
import 'utils/api.dart';
import 'utils/constants.dart';
import 'utils/helpers.dart';
import 'utils/sessions.dart';
import 'utils/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependecyInjection.init();
  timeago.setLocaleMessages('id', MyCustomTimeagoMessages());
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: colorPrimary,
      statusBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Absen Guru',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: colorPrimary,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 20, fontFamily: 'PoppinsRegular'),
          centerTitle: false,
          iconTheme: const IconThemeData(color: Colors.black),
          actionsIconTheme: const IconThemeData(color: Colors.black),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'PoppinsRegular',
      ),
      builder: EasyLoading.init(),
      initialRoute: '/',
      routes: {
        '/': (context) => const PageSplashscreen(),
      },
    );
  }
}

class PageSplashscreen extends StatefulWidget {
  const PageSplashscreen({Key? key}) : super(key: key);

  @override
  State<PageSplashscreen> createState() => _PageSplashscreenState();
}

class _PageSplashscreenState extends State<PageSplashscreen> {
  late PackageInfo packageInfo;
  late bool isLoggedIn;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    Future.delayed(const Duration(seconds: 4), () async {
      packageInfo = await PackageInfo.fromPlatform();
      isLoggedIn = await getPrefrenceBool(ISFIRSTTIME);
      log("isLoggedIn: $isLoggedIn");

      if (isLoggedIn) {
        if (await Helpers.isNetworkAvailable()) {
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          String sumber = '', model = '', token = '404', username = '', password = '', tokenAuth = '';

          if (Platform.isAndroid) {
            sumber = 'android';
            AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
            model = '${androidInfo.model}';
          } else if (Platform.isIOS) {
            sumber = 'ios';
            IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
            model = '${iosInfo.utsname.machine}';
          } else {
            sumber = 'web';
            WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
            model = '${webBrowserInfo.userAgent}';
          }

          token = (await getPrefrence(TOKEN)) ?? '';
          username = (await getPrefrence(EMAIL)) ?? '';
          password = (await getPrefrence(PASSWORD)) ?? '';
          tokenAuth = (await getPrefrence(TOKEN_AUTH)) ?? '';

          var param = {
            'email': username,
            'password': password,
            'token_auth': tokenAuth,
            'token_notif': token,
            'model': model,
            'imei': '404',
            'sumber': sumber,
          };

          if (username == '' || password == '') {
            // FlutterNativeSplash.remove();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const PageLogin(),
                ),
                (route) => false);
          } else {
            try {
              http.Response response = await http.post(
                Uri.parse(urlLogin),
                headers: headers,
                body: param,
              );

              // setState(() {
              //   loading = false;
              // });
              // FlutterNativeSplash.remove();
              log(response.body);

              Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
              log(jsonResponse.toString());
              if (jsonResponse.containsKey("error")) {
                Helpers.dialogErrorNetwork(context, jsonResponse["error"]);
              } else {
                bool success = jsonResponse['success'];
                String message = jsonResponse['message'];
                if (success) {
                  var data = jsonResponse['data'];
                  setPrefrenceBool(ISFIRSTTIME, true);
                  setPrefrence(HASH_USER, data['hash_user']);
                  setPrefrence(TOKEN_AUTH, data['token_auth']);
                  setPrefrence(NAMA, data['nama_lengkap']);
                  setPrefrence(EMAIL, data['email']);
                  setPrefrence(NOTLP, data['notlp']);
                  setPrefrence(ALAMAT, data['alamat']);
                  setPrefrence(FOTO, data['foto']);

                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PageBeranda(),
                      ),
                      (route) => false);
                } else {
                  clearUserSession();
                  ArtSweetAlert.show(
                      context: context,
                      artDialogArgs: ArtDialogArgs(
                          title: 'Gagal',
                          text: message,
                          type: ArtSweetAlertType.danger,
                          confirmButtonText: 'OK',
                          confirmButtonColor: Colors.red,
                          onConfirm: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PageLogin(),
                                ),
                                (route) => false);
                          }));
                }
              }
            } catch (e, stacktrace) {
              // FlutterNativeSplash.remove();
              log(e.toString());
              log(stacktrace.toString());
              String customMessage = "${Strings.TERJADI_KESALAHAN}.\n${e.runtimeType.toString()}";
              Helpers.dialogErrorNetwork(context, customMessage);
            }
          }
        } else {
          // setState(() {
          //   _loginLoading = false;
          // });
          Helpers.dialogErrorNetwork(context, 'Tidak ada koneksi internet');
        }
      } else {
        // FlutterNativeSplash.remove();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const PageLogin(),
            ),
            (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child:
                // Lottie.asset(
                //   'assets/images/splash.json',
                //   fit: BoxFit.fill,
                //   onLoaded: (composition) {
                //     init();
                //   },
                // ),
                Image.asset(
              'images/splash.gif',
              gaplessPlayback: true,
              fit: BoxFit.cover,
            )),
      ),
    );
  }
}
