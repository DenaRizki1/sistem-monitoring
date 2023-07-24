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
import 'package:google_fonts/google_fonts.dart';
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
  String nama = "", foto = "", email = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  init() async {
    String nm = "", ft = "", eml = "";
    nm = (await getPrefrence(NAMA))!;
    ft = (await getPrefrence(FOTO))!;
    eml = (await getPrefrence(EMAIL))!;
    setState(() {
      nama = nm;
      foto = ft;
      email = eml;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: MyAppBar.getAppBar("Profil"),
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
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 16, bottom: 40),
                    color: colorPrimary,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "Profile",
                        style: GoogleFonts.montserrat(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [colorPrimary, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 12),
                            child: Text(
                              "Account",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.grey.withOpacity(0.9),
                              ),
                            ),
                          ),
                          InkWell(
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              color: colorPrimary,
                              elevation: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: LinearGradient(
                                      colors: [
                                        colorPrimary,
                                        colorPrimary,
                                        Colors.white.withOpacity(0.4),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    )),
                                padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                                child: Row(
                                  children: [
                                    foto != ""
                                        ? Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(image: NetworkImage(foto), fit: BoxFit.fill),
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                          )
                                        : const CupertinoActivityIndicator(),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nama,
                                            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            email,
                                            style: const TextStyle(color: Colors.white, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      String.fromCharCode(Icons.keyboard_arrow_right.codePoint),
                                      style: TextStyle(
                                        color: colorPrimary,
                                        fontSize: 33,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: Icons.keyboard_arrow_right.fontFamily,
                                        package: Icons.keyboard_arrow_right.fontPackage,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const PageProfilDetail()));
                            },
                          ),
                          InkWell(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: Container(
                                padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.password,
                                        size: 30,
                                        color: colorPrimary,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: Text(
                                        "Ganti Password",
                                        style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold),
                                      )),
                                      Text(
                                        String.fromCharCode(Icons.keyboard_arrow_right.codePoint),
                                        style: TextStyle(
                                          color: colorPrimary,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: Icons.keyboard_arrow_right.fontFamily,
                                          package: Icons.keyboard_arrow_right.fontPackage,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const PageGantiPassword()));
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 6,
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 12),
                          child: Text(
                            "About",
                            style: GoogleFonts.heebo(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey.withOpacity(0.9),
                            ),
                          ),
                        ),
                        InkWell(
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: Container(
                              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "images/terms.png",
                                      scale: 3,
                                      color: colorPrimary,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                        child: Text(
                                      "Syarat & Ketentuan",
                                      style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold),
                                    )),
                                    Text(
                                      String.fromCharCode(Icons.keyboard_arrow_right.codePoint),
                                      style: TextStyle(
                                        color: colorPrimary,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: Icons.keyboard_arrow_right.fontFamily,
                                        package: Icons.keyboard_arrow_right.fontPackage,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const PageSyaratKetentuan()));
                          },
                        ),
                        InkWell(
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: Container(
                              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.privacy_tip,
                                      size: 30,
                                      color: colorPrimary,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(child: Text("Kebijakan Privasi", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold))),
                                    Text(
                                      String.fromCharCode(Icons.keyboard_arrow_right.codePoint),
                                      style: TextStyle(
                                        color: colorPrimary,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: Icons.keyboard_arrow_right.fontFamily,
                                        package: Icons.keyboard_arrow_right.fontPackage,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const PagePrivasi()));
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Center(
                    child: Container(
                      width: 150,
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                      child: ElevatedButton(
                        child: const Text("Logout"),
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
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        )),
                      ),
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

    if (await Helpers.isNetworkAvailable()) {
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
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const PageLogin()), (route) => false);
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
