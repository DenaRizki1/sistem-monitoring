import 'dart:io';
import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/page_home.dart';
import 'package:absentip/services/location_service.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/alert_dialog_confirm_widget.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/constants.dart';
import 'utils/helpers.dart';
import 'utils/sessions.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({Key? key}) : super(key: key);

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = true;
  bool _forceLogin = false;

  @override
  void initState() {
    initLogin();
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> initLogin() async {
    final position = await LocationService.instance.getCurrentLocation(context);
    final prefs = await SharedPreferences.getInstance();

    if (position != null) {
      prefs.setString(LAT_USER, position.latitude.toString());
      prefs.setString(LNG_USER, position.longitude.toString());
    }

    final tokenNotif = await FirebaseMessaging.instance.getToken();
    prefs.setString(TOKEN_NOTIF, tokenNotif ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("login", leading: null),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Image.asset(
                  AppImages.logoGold,
                  color: AppColor.biru,
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: textFieldDecoration(textHint: "Masukkan username / email"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Masukkan username / email";
                        } else {
                          _usernameController.text = value;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: textFieldDecoration(
                        textHint: "Masukkan Kata Sandi",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: AppColor.biru,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: _passwordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Masukkan Kata Sandi";
                        } else {
                          _passwordController.text = value;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            FocusScope.of(context).requestFocus(FocusNode());
                            loginUser(_usernameController.text, _passwordController.text, "normal");
                          }
                        },
                        child: const Text('Masuk'),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> loginUser(String email, String password, String loginMode) async {
    showLoading();

    String sumber = '', versionOs = '', model = '', branch = '';

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      sumber = 'android';
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      model = androidInfo.model.toString();
      branch = androidInfo.brand.toString();
      versionOs = "${androidInfo.version.release} (${androidInfo.version.sdkInt})";
    } else if (Platform.isIOS) {
      sumber = 'ios';
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      model = iosInfo.model.toString();
      branch = 'apple';
      versionOs = iosInfo.systemVersion.toString();
    }

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.login,
      params: {
        'lat_user': await getPrefrence(LAT_USER) ?? "",
        'lng_user': await getPrefrence(LNG_USER) ?? "",
        'email': email,
        'password': password,
        'token_notif': await getPrefrence(TOKEN_NOTIF) ?? "",
        'branch': branch,
        'model': model,
        'version_os': versionOs,
        'sumber': sumber,
        'force_login': _forceLogin.toString(),
        'version_number': await getPrefrence(BUILD_NUMBER) ?? "",
        'version_app': await getPrefrence(VERSION) ?? "",
      },
    );

    dismissLoading();

    if (response != null) {
      if (response['success']) {
        final data = response['data'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool(IS_LOGIN, true);
        prefs.setString(TOKEN_AUTH, data['token_auth'].toString());
        prefs.setString(HASH_USER, data['hash_user'].toString());
        prefs.setString(NAMA, data['nama_lengkap'].toString());
        prefs.setString(EMAIL, data['email'].toString());
        prefs.setString(NOTLP, data['notlp'].toString());
        prefs.setString(ALAMAT, data['alamat'].toString());
        prefs.setString(FOTO, data['foto'].toString());
        prefs.setString(ID_JABATAN, data['id_jabatan'].toString());
        prefs.setString(JABATAN, data['jabatan'].toString());
        prefs.setString(STATUS_PEGAWAI, data['status_pegawai'].toString());
        prefs.setString(PASSWORD, password);

        AppNavigator.instance.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const PageHome(),
          ),
          (p0) => false,
        );
      } else {
        if ((response['code']?.toString() ?? "0") == "1") {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialogConfirmWidget(message: response['message'].toString()),
          );

          if (result ?? false) {
            _forceLogin = true;
            loginUser(email, password, loginMode);
          }
        } else {
          clearUserSession();
          showToast(response['message'].toString());
        }
      }
    } else {
      clearUserSession();
      showToast("Terjadi keslahan");
    }
  }
}
