import 'dart:convert';
import 'dart:developer';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/ApiStatus.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/my_colors.dart';
import 'package:absentip/page_rekap_absen_harian.dart';
import 'package:absentip/page_rekap_cuti.dart';
import 'package:absentip/page_rekap_izin.dart';
import 'package:absentip/utils/api.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/sessions.dart';
import 'package:absentip/utils/text_montserrat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:month_picker_dialog_2/month_picker_dialog_2.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageDataAbsensi extends StatefulWidget {
  const PageDataAbsensi({Key? key}) : super(key: key);

  @override
  State<PageDataAbsensi> createState() => _PageDataAbsensiState();
}

class _PageDataAbsensiState extends State<PageDataAbsensi> {
  String filterBulan = "", filterTahun = "";
  DateTime? selectedDate;
  bool loading = true;

  double countAbsenMasuk = 0.4;
  double countAbsenIzin = 0.5;
  double countAbsenLembur = 0.2;
  double countAbsenSakit = 0.6;
  double countAbsenAlpa = 0.7;
  double countAbsenCuti = 0.4;
  double countAbsenTerlambat = 0.8;
  double countAbsenPulangCepat = 0.3;
  double countAbsenTidakAbsenPulang = 0.2;

  double dataAbsen = 0;

  @override
  void initState() {
    // TODO: implement initState
    filterTahun = parseDateInd(DateTime.now().toString(), "yyyy");
    filterBulan = parseDateInd(DateTime.now().toString(), "MM");
    getCountAbsen();
    super.initState();
  }

  Future _onRefresh() async {
    getCountAbsen();
  }

  ApiStatus _apiStatus = ApiStatus.loading;

  Map progressAbsen = {};

  getCountAbsen() async {
    setState(() {
      loading = true;
      _apiStatus = ApiStatus.loading;
    });

    final pref = await SharedPreferences.getInstance();

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.urlGetProgresAbsen,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH)!,
        'hash_user': pref.getString(HASH_USER)!,
        'tahun': filterTahun,
        'bulan': filterBulan,
      },
    );

    if (response != null) {
      if (response['success']) {
        progressAbsen = response['data'];
      } else {
        return showToast("Data Tidak Ditemukann");
      }
    } else {
      return showToast(response!['message']);
    }

    log(progressAbsen['hadir']['progress'].toString());
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: loading
            ? Center(
                child: CupertinoActivityIndicator(
                radius: 10,
              ))
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
                  RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              // height: 70,
                              padding: EdgeInsets.symmetric(vertical: 6),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xffc18e28),
                                image: DecorationImage(
                                  image: AssetImage(AppImages.bg2),
                                  fit: BoxFit.fill,
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
                                  SizedBox(width: 12),
                                  Text(
                                    "Data Absensi",
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  )
                                ],
                              ),
                              // color: Colors.red,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xffc18e28),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                // color: Colors.red
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextMontserrat(
                                                text: "Rekap Absensi",
                                                fontSize: 16,
                                                bold: true,
                                                color: Colors.black,
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  showMonthPicker(
                                                    context: context,
                                                    firstDate: DateTime(2022),
                                                    lastDate: DateTime.now(),
                                                    initialDate: selectedDate ?? DateTime.now(),
                                                  ).then((date) {
                                                    if (date != null) {
                                                      setState(() {
                                                        selectedDate = date;
                                                        filterBulan = parseDateInd(date.toString(), "MM");
                                                        filterTahun = parseDateInd(date.toString(), "yyyy");
                                                      });
                                                      getCountAbsen();
                                                    }
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                  child: Column(
                                                    children: [
                                                      TextMontserrat(
                                                        text: "Bulan - Tahun",
                                                        fontSize: 11,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Center(
                                                            child: TextMontserrat(
                                                              text: "${parseDateInd("2023-${filterBulan}-19", "MMM")} - ${filterTahun}",
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                          Icon(
                                                            MdiIcons.chevronDown,
                                                            size: 17,
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          Divider(
                                            color: Colors.black.withOpacity(0.2),
                                          ),
                                          IntrinsicHeight(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      TextMontserrat(
                                                        text: "Hadir",
                                                        fontSize: 14,
                                                        bold: true,
                                                        color: Colors.black,
                                                      ),
                                                      TextMontserrat(
                                                        text: "${progressAbsen['hadir']['hari']}  Hari",
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                      // Container(
                                                      //   height: 10,
                                                      //   width: double.infinity,
                                                      //   decoration: BoxDecoration(
                                                      //     color: Colors.grey,
                                                      //     borderRadius: BorderRadius.circular(8),
                                                      //   ),
                                                      // )
                                                      LinearIndicator(safetyParseDouble(progressAbsen['hadir']['progress']), Colors.green)
                                                    ],
                                                  ),
                                                ),
                                                VerticalDivider(
                                                  color: Colors.black.withOpacity(0.3),
                                                  width: 20,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      TextMontserrat(
                                                        text: "Izin",
                                                        fontSize: 14,
                                                        bold: true,
                                                        color: Colors.black,
                                                      ),
                                                      TextMontserrat(
                                                        text: "${progressAbsen['izin']['hari']} Hari",
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                      // Container(
                                                      //   height: 10,
                                                      //   width: double.infinity,
                                                      //   decoration: BoxDecoration(
                                                      //     color: Colors.grey,
                                                      //     borderRadius: BorderRadius.circular(8),
                                                      //   ),
                                                      // )
                                                      LinearIndicator(safetyParseDouble(progressAbsen['izin']['progress']), Colors.red)
                                                    ],
                                                  ),
                                                ),
                                                VerticalDivider(
                                                  color: Colors.black.withOpacity(0.3),
                                                  width: 20,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      TextMontserrat(
                                                        text: "Sakit",
                                                        fontSize: 14,
                                                        bold: true,
                                                        color: Colors.black,
                                                      ),
                                                      TextMontserrat(
                                                        text: "${progressAbsen['sakit']['hari']} Hari",
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                      // Container(
                                                      //   height: 10,
                                                      //   width: double.infinity,
                                                      //   decoration: BoxDecoration(
                                                      //     color: Colors.grey,
                                                      //     borderRadius: BorderRadius.circular(8),
                                                      //   ),
                                                      // )
                                                      LinearIndicator(safetyParseDouble(progressAbsen['sakit']['progress']), Colors.red)
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(),
                                          IntrinsicHeight(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      TextMontserrat(
                                                        text: "Lembur",
                                                        fontSize: 14,
                                                        bold: true,
                                                        color: Colors.black,
                                                      ),
                                                      TextMontserrat(
                                                        text: "${countAbsenSakit}  Hari",
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                      // Container(
                                                      //   height: 10,
                                                      //   width: double.infinity,
                                                      //   decoration: BoxDecoration(
                                                      //     color: Colors.grey,
                                                      //     borderRadius: BorderRadius.circular(8),
                                                      //   ),
                                                      // )
                                                      LinearIndicator(countAbsenLembur, Colors.red)
                                                    ],
                                                  ),
                                                ),
                                                VerticalDivider(
                                                  color: Colors.black.withOpacity(0.3),
                                                  width: 32,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      TextMontserrat(
                                                        text: "Alpa",
                                                        fontSize: 14,
                                                        bold: true,
                                                        color: Colors.black,
                                                      ),
                                                      TextMontserrat(
                                                        text: "${progressAbsen['alpa']['hari']} Hari",
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                      // Container(
                                                      //   height: 10,
                                                      //   width: double.infinity,
                                                      //   decoration: BoxDecoration(
                                                      //     color: Colors.grey,
                                                      //     borderRadius: BorderRadius.circular(8),
                                                      //   ),
                                                      // )
                                                      LinearIndicator(safetyParseDouble(progressAbsen['alpa']['progress']), Colors.red)
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(),
                                          IntrinsicHeight(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      TextMontserrat(
                                                        text: "Cuti",
                                                        fontSize: 14,
                                                        bold: true,
                                                        color: Colors.black,
                                                      ),
                                                      TextMontserrat(
                                                        text: "${progressAbsen['cuti']['hari']}  Hari",
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                      // Container(
                                                      //   height: 10,
                                                      //   width: double.infinity,
                                                      //   decoration: BoxDecoration(
                                                      //     color: Colors.grey,
                                                      //     borderRadius: BorderRadius.circular(8),
                                                      //   ),
                                                      // )
                                                      LinearIndicator(safetyParseDouble(progressAbsen['cuti']['progress']), Colors.red)
                                                    ],
                                                  ),
                                                ),
                                                VerticalDivider(
                                                  color: Colors.black.withOpacity(0.3),
                                                  width: 32,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      TextMontserrat(
                                                        text: "Terlambat",
                                                        fontSize: 14,
                                                        bold: true,
                                                        color: Colors.black,
                                                      ),
                                                      TextMontserrat(
                                                        text: "${progressAbsen['izin']['progress']} Hari",
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                      // Container(
                                                      //   height: 10,
                                                      //   width: double.infinity,
                                                      //   decoration: BoxDecoration(
                                                      //     color: Colors.grey,
                                                      //     borderRadius: BorderRadius.circular(8),
                                                      //   ),
                                                      // )
                                                      LinearIndicator(countAbsenTerlambat, Colors.red)
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(),
                                          IntrinsicHeight(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      TextMontserrat(
                                                        text: "Pulang Cepat",
                                                        fontSize: 14,
                                                        bold: true,
                                                        color: Colors.black,
                                                      ),
                                                      TextMontserrat(
                                                        text: "${countAbsenPulangCepat}  Hari",
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                      // Container(
                                                      //   height: 10,
                                                      //   width: double.infinity,
                                                      //   decoration: BoxDecoration(
                                                      //     color: Colors.grey,
                                                      //     borderRadius: BorderRadius.circular(8),
                                                      //   ),
                                                      // )
                                                      LinearIndicator(countAbsenPulangCepat, Colors.red)
                                                    ],
                                                  ),
                                                ),
                                                VerticalDivider(
                                                  color: Colors.black.withOpacity(0.3),
                                                  width: 32,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      TextMontserrat(
                                                        text: "Tidak Absen Pulang",
                                                        fontSize: 14,
                                                        bold: true,
                                                        color: Colors.black,
                                                      ),
                                                      TextMontserrat(
                                                        text: "${countAbsenTidakAbsenPulang} Hari",
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                      // Container(
                                                      //   height: 10,
                                                      //   width: double.infinity,
                                                      //   decoration: BoxDecoration(
                                                      //     color: Colors.grey,
                                                      //     borderRadius: BorderRadius.circular(8),
                                                      //   ),
                                                      // )
                                                      LinearIndicator(countAbsenTidakAbsenPulang, Colors.red)
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PageRekapAbsenHarian(),
                                ));
                              },
                              child: Card(
                                margin: const EdgeInsets.only(right: 16, left: 16, top: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        MdiIcons.archiveRefreshOutline,
                                        size: 30,
                                        color: colorPrimary,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextMontserrat(
                                                text: "Data Absensi",
                                                bold: true,
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                              SizedBox(height: 5),
                                              TextMontserrat(
                                                text: "Data Absensi",
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ),
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
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const PageRekapIzin(),
                                ));
                              },
                              child: Card(
                                margin: const EdgeInsets.only(right: 16, left: 16, top: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Image(
                                        image: AssetImage("images/izin.png"),
                                        height: 35,
                                        color: colorPrimary,
                                        colorBlendMode: BlendMode.color,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextMontserrat(
                                                text: "Data Izin",
                                                bold: true,
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                              SizedBox(height: 5),
                                              TextMontserrat(
                                                text: "Data Izin yang sudah disetujui",
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ),
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
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const PageRekapCuti(),
                                ));
                              },
                              child: Card(
                                margin: const EdgeInsets.only(right: 16, left: 16, top: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 12, top: 12, bottom: 12),
                                  child: Row(
                                    children: [
                                      Image(
                                        image: AssetImage("images/sakit.png"),
                                        height: 25,
                                        color: colorPrimary,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextMontserrat(
                                                text: "Data Cuti",
                                                bold: true,
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                              SizedBox(height: 5),
                                              TextMontserrat(
                                                text: "Data Cuti yang sudah disetujui",
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ),
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
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Widget LinearIndicator(double? percent, Color? color) {
    return LinearPercentIndicator(
      padding: EdgeInsets.zero,
      lineHeight: 10,
      barRadius: const Radius.circular(8),
      animation: true,
      percent: percent!,
      progressColor: color,
    );
  }
}
