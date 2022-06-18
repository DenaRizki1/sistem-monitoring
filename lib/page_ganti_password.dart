import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
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
    return Scaffold(
      appBar: MyAppBar.getAppBar("Ganti Password"),
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
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: controllerPasswordBaru,
                      decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 1.0)
                        ),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0)
                        ),
                        hintText: "Password baru",
                        hintStyle: const TextStyle(color: Colors.grey,),
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordBaruVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
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
                    const SizedBox(height: 16,),
                    TextFormField(
                      controller: controllerPasswordKonfirmasi,
                      decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 1.0)
                        ),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0)
                        ),
                        hintText: "Masukkan kembali password baru",
                        hintStyle: const TextStyle(color: Colors.grey,),
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordKonfirmasiVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
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
                        } else if(controllerPasswordBaru.text!=controllerPasswordKonfirmasi.text){
                          return "Password baru tidak sama";
                        } else {
                          controllerPasswordKonfirmasi.text = value;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16,),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          onPressed: (){
                            // Navigator.of(context).pop("refresh");
                            if (_formKey.currentState!.validate()) {
                              if(controllerPasswordBaru.text==controllerPasswordKonfirmasi.text) {
                                FocusScope.of(context).requestFocus(FocusNode());
                                simpanPasswordBaru(controllerPasswordBaru.text);
                              }
                            }
                          },
                          child: const Text("SIMPAN")
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  simpanPasswordBaru(String passwordBaru) async {

    EasyLoading.show(
      status: "Tunggu sebentar...",
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );

    if(await Helpers.isNetworkAvailable()) {

      try {

        String tokenAuth = "", hashUser = "";
        tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
        hashUser = (await getPrefrence(HASH_USER))!;

        var param = {
          'token_auth': tokenAuth,
          'hash_user': hashUser,
          'password_baru' : passwordBaru
        };

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
