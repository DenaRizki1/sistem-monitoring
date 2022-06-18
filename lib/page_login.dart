import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:http/http.dart' as http;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'my_colors.dart';
import 'page_beranda.dart';
import 'utils/api.dart';
import 'utils/constants.dart';
import 'utils/helpers.dart';
import 'utils/sessions.dart';
import 'utils/strings.dart';


class PageLogin extends StatefulWidget {
  const PageLogin({Key? key}) : super(key: key);

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {

  PackageInfo _packageInfo = PackageInfo(appName: "Unknown", buildNumber: "Unknown", packageName: "Unknown", version: "Unknown", buildSignature: "Unknown");
  late SharedPreferences sharedPreferences;
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _passwordVisible = true, _loginLoading = false;
  String? _jalur = "sd";
  String? sDeviceInfo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getSession();
    _getDeviceInfo();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _getSession() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  void _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      sDeviceInfo = jsonEncode(androidInfo.toMap());
      debugPrint('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      sDeviceInfo = jsonEncode(iosInfo.toMap());
      debugPrint('Running on ${iosInfo.model}'); // e.g. "iPod7,1"
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: colorPrimary,
        title: const SizedBox(
          width: double.infinity,
          child: Text("Login",
            textAlign: TextAlign.start,
            style: TextStyle(color: Colors.black, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
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
                child: Image.asset('images/logo_gold.png'),
              ),
              const SizedBox(
                height: 16,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange, width: 1.0)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange, width: 1.0)),
                            hintText: "Masukkan username / email",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            )),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Masukkan username / email";
                          } else {
                            usernameController.text = value;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange, width: 1.0)),
                          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange, width: 1.0)),
                          hintText: "Masukkan Kata Sandi",
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.orange,
                            ),
                            onPressed: () {
                              // Update the state i.e. toogle the state of passwordVisible variable
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
                            passwordController.text = value;
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
                      !_loginLoading
                          ? SizedBox(
                        width: double.infinity,
                        height: 50,
                        child:
                        // ElevatedButton(
                        //     onPressed: () {
                        //       if (_formKey.currentState!.validate()) {
                        //         FocusScope.of(context).requestFocus(FocusNode());
                        //         _login(usernameController.text, passwordController.text);
                        //       }
                        //     },
                        //     child: const Text("Masuk")),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                FocusScope.of(context).requestFocus(FocusNode());
                                _login(usernameController.text, passwordController.text);
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                const Text('Masuk', style: TextStyle(color: Colors.white, fontSize: 16),),
                                const SizedBox(width: 10,),
                                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16,),
                              ],
                            )),
                      )
                          : Container(
                        width: double.infinity,
                        height: 50,
                        // color: getColorFromHex("#CCCCCC"),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CupertinoActivityIndicator(),
                          ),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> _login(String user, String pass) async {

    setState(() {
      _loginLoading = true;
    });

    if(await Helpers.isNetworkAvailable()) {

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String sumber = '', model = '', token = '404';

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

      var param = {
        'email': user,
        'password': pass,
        'token_auth': '',
        'token_notif': token,
        'model': model,
        'imei': '404',
        'sumber': sumber,
      };

      http.Response response = await http.post(
        Uri.parse(urlLogin),
        headers: headers,
        body: param,

      );

      setState(() {
        _loginLoading = false;
      });

      log(response.body);
      try {
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
            // setPrefrence(NIK, data['nik']);
            setPrefrence(PASSWORD, passwordController.text);
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
            ArtSweetAlert.show(
                context: context,
                artDialogArgs: ArtDialogArgs(
                  title: 'Gagal',
                  text: message,
                  type: ArtSweetAlertType.danger,
                  confirmButtonText: 'OK',
                  confirmButtonColor: Colors.red,
                ));
          }

        }
      } catch (e, stacktrace) {
        log(e.toString());
        log(stacktrace.toString());
        String customMessage = "${Strings.TERJADI_KESALAHAN}.\n${e.runtimeType.toString()} ${response.statusCode}";
        // Helpers.dialogErrorNetwork(context, customMessage);
      }

    } else {
      setState(() {
        _loginLoading = false;
      });
      Helpers.dialogErrorNetwork(context, 'Tidak ada koneksi internet');
    }
  }
}
