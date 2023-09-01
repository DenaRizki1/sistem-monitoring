import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/page_ganti_password.dart';
import 'package:absentip/page_login.dart';
import 'package:absentip/page_privasi.dart';
import 'package:absentip/page_profil_detail.dart';
import 'package:absentip/page_syarat_ketentuan.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/alert_dialog_confirm_widget.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'utils/my_colors.dart';
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
  String nama = "", foto = "", email = "", versionApp = "";

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    nama = (await getPrefrence(NAMA)) ?? "";
    foto = (await getPrefrence(FOTO)) ?? "";
    email = (await getPrefrence(EMAIL)) ?? "";
    versionApp = (await getPrefrence(VERSION)) ?? "";
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Profil", leading: null),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'images/bg_doodle.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.biru2,
                  AppColor.biru2.withOpacity(0.6),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
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
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PageProfilDetail(),
                            ),
                          ).then((value) => init());
                        },
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
                                  colorPrimary.withAlpha(200),
                                  Colors.white.withOpacity(0.4),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                            child: Row(
                              children: [
                                foto.isNotEmpty
                                    ? Container(
                                        padding: const EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColor.hitam,
                                        ),
                                        child: ClipOval(
                                          child: Image.network(
                                            foto,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return SizedBox(
                                                width: 50,
                                                height: 50,
                                                child: Center(
                                                  child: loadingWidget(),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) => Image.asset(
                                              AppImages.logoGold,
                                              width: 50,
                                              height: 50,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const CupertinoActivityIndicator(),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nama,
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        email,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PageGantiPassword()));
                        },
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
                                      style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                  ),
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
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 6,
                  margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 12),
                        child: Text(
                          "About",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PageSyaratKetentuan()));
                        },
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
                                    style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
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
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PagePrivasi()));
                        },
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
                                  Expanded(
                                    child: Text(
                                      "Kebijakan Privasi",
                                      style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                  ),
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
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#Pengajar TIP',
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "v$versionApp",
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 150,
                    height: 40,
                    margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                    child: ElevatedButton(
                      child: const Text("Logout"),
                      onPressed: () async {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => const AlertDialogConfirmWidget(
                            message: "'Anda akan diminta kembali untuk memasukkan email dan password saat masuk kembali ke aplikasi\nKeluar dari aplikasi sekarang?",
                          ),
                        );

                        if (result ?? false) {
                          logout();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    showLoading();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.logout,
      params: {
        'hash_user': await getPrefrence(HASH_USER) ?? "",
        'token_auth': await getPrefrence(TOKEN_AUTH) ?? "",
      },
    );

    dismissLoading();

    if (response != null) {
      if (response['success']) {
        await clearUserSession();
        AppNavigator.instance.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const PageLogin(),
          ),
          (p0) => false,
        );
      } else {
        showToast(response['message'].toString());
      }
    } else {
      showToast("Terjadi kesalahan");
    }
  }
}
