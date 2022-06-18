import 'dart:convert';
import 'dart:developer';

import 'package:absentip/page_ganti_password.dart';
import 'package:absentip/page_login.dart';
import 'package:absentip/page_privasi.dart';
import 'package:absentip/page_profil_detail.dart';
import 'package:absentip/page_syarat_ketentuan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import 'my_appbar.dart';
import 'my_colors.dart';
import 'utils/api.dart';
import 'utils/constants.dart';
import 'utils/helpers.dart';
import 'utils/sessions.dart';

class PageProfil extends StatefulWidget {
  const PageProfil({Key? key}) : super(key: key);

  @override
  State<PageProfil> createState() => _PageProfilState();
}

class _PageProfilState extends State<PageProfil> {

  bool loading = true;
  String nama = "", foto = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  init() async {
    String nm = "", ft = "";
    nm = (await getPrefrence(NAMA))!;
    ft = (await getPrefrence(FOTO))!;
    setState(() {
      nama = nm;
      foto = ft;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar.getAppBar("Profil"),
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
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 32, bottom: 16),
                    child: Center(
                      child: foto!="" ? InkWell(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          height: MediaQuery.of(context).size.width / 3,
                          child: CircleAvatar(
                            child: Padding(
                              padding: const EdgeInsets.all(1),
                              child: ClipOval(child: Image.network(foto)),
                            ),
                            backgroundColor: Colors.black38,
                          ),
                        ),
                        onTap: () {

                        },
                      ) : const CupertinoActivityIndicator(),
                    ),
                  ),
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                      child: Row(
                        children: const [
                          Icon(Icons.person),
                          SizedBox(width: 10,),
                          Expanded(child: Text("Info Pribadi")),
                          Icon(Icons.keyboard_arrow_right),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PageProfilDetail()));
                    },
                  ),
                  const Divider(height: 1, color: Colors.black26,),
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                      child: Row(
                        children: const [
                          Icon(Icons.password),
                          SizedBox(width: 10,),
                          Expanded(child: Text("Ganti Password")),
                          Icon(Icons.keyboard_arrow_right),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PageGantiPassword()));
                    },
                  ),
                  const Divider(height: 1, color: Colors.black26,),
                  Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                    child: InkWell(
                      child: Row(
                        children: const [
                          Icon(Icons.privacy_tip),
                          SizedBox(width: 10,),
                          Expanded(child: Text("Kebijakan Privasi")),
                          Icon(Icons.keyboard_arrow_right),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PagePrivasi()));
                      }
                    ),
                  ),
                  const Divider(height: 1, color: Colors.black26,),
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                      child: Row(
                        children: const [
                          Icon(Icons.privacy_tip),
                          SizedBox(width: 10,),
                          Expanded(child: Text("Syarat & Ketentuan")),
                          Icon(Icons.keyboard_arrow_right),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PageSyaratKetentuan()));
                    },
                  ),
                  const Divider(height: 1, color: Colors.black26,),
                  const SizedBox(height: 16,),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                    height: 50,
                    child: ElevatedButton(
                      child: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        primary: colorButtonRed,
                      ),
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Perhatian'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: const <Widget>[
                                    Text('Anda akan diminta kembali untuk memasukkan email dan password saat masuk kembali ke aplikasi'),
                                    Text('Keluar dari aplikasi sekarang?'),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Batal'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Keluar'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    logout();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  logout() async {

    EasyLoading.show(
      status: "Tunggu sebentar...",
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );
    setState(() {
      loading = true;
    });

    if(await Helpers.isNetworkAvailable()) {

      try {

        String tokenAuth = "", hashUser = "";
        tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
        hashUser = (await getPrefrence(HASH_USER))!;

        var param = {
          'token_auth': tokenAuth,
          'hash_user': hashUser,
        };

        http.Response response = await http.post(
          Uri.parse(urlLogout),
          headers: headers,
          body: param,
        );

        setState(() {
          loading = false;
        });

        log(response.body);

        Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        log(jsonResponse.toString());
        if (jsonResponse.containsKey("error")) {

        } else {

          bool success = jsonResponse['success'];
          String message = jsonResponse["message"];
          if (success) {
            EasyLoading.showSuccess(message);
            clearUserSession();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const PageLogin(),), (route) => false);
          } else {
            EasyLoading.showError(message);
          }
        }
      } catch (e, stacktrace) {
        log(stacktrace.toString());
        EasyLoading.showError(e.toString());
        setState(() {
          loading = false;
        });
      }

    } else {

      EasyLoading.showError("Tidak ada koneksi internet");
      setState(() {
        loading = false;
      });
    }
  }

}
