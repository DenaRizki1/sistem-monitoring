import 'dart:convert';
import 'dart:developer';

import 'package:absentip/my_colors.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/text_montserrat.dart';
import 'package:absentip/wigets/label_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'my_appbar.dart';
import 'utils/api.dart';
import 'utils/constants.dart';
import 'utils/helpers.dart';
import 'utils/sessions.dart';
import 'utils/strings.dart';

class PageGantiPassword extends StatefulWidget {
  const PageGantiPassword({Key? key}) : super(key: key);

  @override
  State<PageGantiPassword> createState() => _PageGantiPasswordState();
}

class _PageGantiPasswordState extends State<PageGantiPassword> {
  final _formKey = GlobalKey<FormState>();
  final controllerPasswordBaru = TextEditingController(), controllerPasswordKonfirmasi = TextEditingController();
  bool _passwordBaruVisible = true, _passwordKonfirmasiVisible = true;

  @override
  void dispose() {
    controllerPasswordBaru.dispose();
    controllerPasswordKonfirmasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   flexibleSpace: const Image(
        //     image: AssetImage(AppImages.bg2),
        //     fit: BoxFit.fill,
        //   ),
        //   centerTitle: true,
        //   // systemOverlayStyle: SystemUiOverlayStyle.dark,
        //   backgroundColor: colorPrimary,
        //   leading: GestureDetector(
        //     // onTap: () => AppNavigator.instance.pop(),
        //     onTap: () => Navigator.of(context, rootNavigator: true).pop(),
        //     child: Container(
        //       margin: const EdgeInsets.all(10),
        //       padding: const EdgeInsets.all(2),
        //       decoration: BoxDecoration(
        //         color: Colors.white,
        //         borderRadius: BorderRadius.circular(6),
        //         boxShadow: const [
        //           BoxShadow(
        //             color: Colors.black26,
        //             offset: Offset(3, 3),
        //             blurRadius: 3,
        //           ),
        //         ],
        //       ),
        //       // decoration: BoxDecoration(
        //       //   color: Colors.white.withOpacity(0.2),
        //       //   borderRadius: BorderRadius.circular(6),
        //       // ),
        //       child: Container(
        //         width: 32,
        //         height: 32,
        //         decoration: BoxDecoration(
        //           color: colorPrimary,
        //           borderRadius: BorderRadius.circular(6),
        //         ),
        //         child: Center(
        //           child: Icon(
        //             MdiIcons.chevronLeft,
        //             color: Colors.white,
        //             size: 24,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        //   title: SizedBox(
        //     child: TextMontserrat(
        //       text: "Ganti Password",
        //       fontSize: 18,
        //       bold: true,
        //       color: Colors.black,
        //     ),
        //   ),
        //   actions: <Widget>[
        //     // IconButton(
        //     //   icon: const Icon(Icons.calendar_today_rounded),
        //     //   onPressed: () {
        //     //     Navigator.push(context, MaterialPageRoute(builder: (context) => const PageRekapAbsenHarian()));
        //     //   },
        //     // )
        //   ],
        // ),
        body: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Image.asset(
                'images/bg_doodle.jpg',
                fit: BoxFit.cover,
                // color: const Color.fromRGBO(255, 255, 255, 0.1),
                // colorBlendMode: BlendMode.modulate,
              ),
            ),
            Column(
              children: [
                Container(
                  // height: 70,
                  padding: EdgeInsets.symmetric(vertical: 6),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xffc18e28),
                    image: DecorationImage(
                      image: AssetImage(AppImages.bg2),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        // onTap: () => AppNavigator.instance.pop(),
                        onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(3, 3),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          // decoration: BoxDecoration(
                          //   color: Colors.white.withOpacity(0.2),
                          //   borderRadius: BorderRadius.circular(6),
                          // ),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: colorPrimary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Icon(
                                MdiIcons.chevronLeft,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: Center(
                            child: Text(
                              "Ganti Password",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  // color: Colors.red,
                ),
                SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xffc18e28),
                          Color(0xffc18e28).withOpacity(0.6),
                          // Colors.white.withOpacity(0.5),
                          Colors.white.withOpacity(0.1),
                        ],
                        end: Alignment.bottomCenter,
                        begin: Alignment.topCenter,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  LabelForm(label: "Password Baru", fontSize: 14),
                                  SizedBox(height: 5),
                                  TextFormField(
                                    controller: controllerPasswordBaru,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                      ),
                                      // focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 1.0)),
                                      // enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                                      hintText: "Password baru",
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          _passwordBaruVisible ? Icons.visibility : Icons.visibility_off,
                                          color: Theme.of(context).primaryColorDark,
                                        ),
                                        onPressed: () {
                                          // Update the state i.e. toogle the state of passwordVisible variable
                                          setState(() {
                                            _passwordBaruVisible = !_passwordBaruVisible;
                                          });
                                        },
                                      ),
                                    ),
                                    obscureText: _passwordBaruVisible,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Masukkan password baru";
                                      } else {
                                        controllerPasswordBaru.text = value;
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  LabelForm(
                                    label: "Konfirmasi Password",
                                    fontSize: 14,
                                  ),
                                  SizedBox(height: 5),
                                  TextFormField(
                                    controller: controllerPasswordKonfirmasi,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                      // focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 1.0)),
                                      // enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                                      hintText: "Konfirmasi Password",
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          _passwordKonfirmasiVisible ? Icons.visibility : Icons.visibility_off,
                                          color: Theme.of(context).primaryColorDark,
                                        ),
                                        onPressed: () {
                                          // Update the state i.e. toogle the state of passwordVisible variable
                                          setState(() {
                                            _passwordKonfirmasiVisible = !_passwordKonfirmasiVisible;
                                          });
                                        },
                                      ),
                                    ),
                                    obscureText: _passwordKonfirmasiVisible,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Masukkan kembali password baru";
                                      } else if (controllerPasswordBaru.text != controllerPasswordKonfirmasi.text) {
                                        return "Password baru tidak sama";
                                      } else {
                                        controllerPasswordKonfirmasi.text = value;
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                                onPressed: () {
                                  // Navigator.of(context).pop("refresh");
                                  if (_formKey.currentState!.validate()) {
                                    if (controllerPasswordBaru.text == controllerPasswordKonfirmasi.text) {
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      simpanPasswordBaru(controllerPasswordBaru.text);
                                    }
                                  }
                                },
                                child: const Text("SIMPAN")),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  simpanPasswordBaru(String passwordBaru) async {
    EasyLoading.show(
      status: "Tunggu sebentar...",
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );

    if (await Helpers.isNetworkAvailable()) {
      try {
        String tokenAuth = "", hashUser = "";
        tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
        hashUser = (await getPrefrence(HASH_USER))!;

        var param = {'token_auth': tokenAuth, 'hash_user': hashUser, 'password_baru': passwordBaru};

        http.Response response = await http.post(
          Uri.parse(urlUbahPassword),
          headers: headers,
          body: param,
        );

        log(response.body);

        Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        log(jsonResponse.toString());
        if (jsonResponse.containsKey("error")) {
          EasyLoading.showError(Strings.TERJADI_KESALAHAN);
        } else {
          bool success = jsonResponse['success'];
          String message = jsonResponse["message"];
          EasyLoading.showInfo(message);
          if (success) {
            Navigator.pop(context);
          }
        }
      } catch (e, stacktrace) {
        log(e.toString());
        log(stacktrace.toString());
        String customMessage = "${Strings.TERJADI_KESALAHAN}.\n${e.runtimeType.toString()}";
        EasyLoading.showError(customMessage);
      }
    } else {
      EasyLoading.showError("Tidak ada koneksi internet");
    }
  }
}
