import 'dart:ui';

import 'package:absentip/my_colors.dart';
import 'package:absentip/session_helper.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'my_appbar.dart';
import 'utils/sessions.dart';

class PageProfilDetail extends StatefulWidget {
  const PageProfilDetail({Key? key}) : super(key: key);

  @override
  State<PageProfilDetail> createState() => _PageProfilDetailState();
}

class _PageProfilDetailState extends State<PageProfilDetail> {
  String nama = "", email = "", notlp = "", alamat = "", foto = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  init() async {
    String nm = "", em = "", nt = "", alm = "", ft = "";
    nm = (await getPrefrence(NAMA))!;
    em = (await getPrefrence(EMAIL))!;
    nt = (await getPrefrence(NOTLP))!;
    alm = (await getPrefrence(ALAMAT))!;
    ft = (await getPrefrence(FOTO))!;
    setState(() {
      nama = nm;
      email = em;
      notlp = nt;
      alamat = alm;
      foto = ft;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   centerTitle: true,
        //   // systemOverlayStyle: SystemUiOverlayStyle.dark,
        //   flexibleSpace: Image(
        //     image: AssetImage(AppImages.bg2),
        //     fit: BoxFit.cover,
        //   ),
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

        //   title: const SizedBox(
        //     // width: double.infinity,
        //     child: Text(
        //       "Rekap Absen Harian",
        //       textAlign: TextAlign.start,
        //       style: TextStyle(
        //         color: Colors.black,
        //         overflow: TextOverflow.ellipsis,
        //         fontSize: 18,
        //         fontWeight: FontWeight.w600,
        //       ),
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
        body: foto == ""
            ? CupertinoActivityIndicator()
            : Stack(
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
                                    "Profile Setting",
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        // color: Colors.red,
                      ),
                      Center(
                        child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(top: 16, bottom: 20, left: MediaQuery.of(context).size.width * 0.33, right: MediaQuery.of(context).size.width * 0.33),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  // Color(0xffc18e28).withOpacity(0.7),
                                  Color(0xffc18e28),
                                  Color(0xffc18e28).withOpacity(0.6),
                                  // Colors.white.withOpacity(0.5),
                                  Colors.white.withOpacity(0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Container(
                              height: 130,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                image: DecorationImage(image: NetworkImage(foto), fit: BoxFit.contain),
                              ),
                            )),
                      ),
                      const SizedBox(height: 30),
                      CardCustom(nama, "Nama"),
                      const SizedBox(height: 10),
                      CardCustom(email, "Email"),
                      const SizedBox(height: 10),
                      CardCustom(notlp, "No.telp"),
                      const SizedBox(height: 10),
                      CardCustom(alamat, "Alamat"),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget CardCustom(String? text, String? content) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      elevation: 5,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Text(
              content!,
              style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 16),
            )),
            Text(
              text!,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 16),
            Icon(
              MdiIcons.pencil,
              color: colorPrimary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
