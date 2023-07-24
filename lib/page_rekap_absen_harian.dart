import 'dart:convert';
import 'dart:developer';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/page_detail_absen.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/text_montserrat.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:month_picker_dialog_2/month_picker_dialog_2.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'my_appbar.dart';
import 'my_colors.dart';
import 'model/absen_harian.dart';
import 'utils/api.dart';
import 'utils/constants.dart';
import 'utils/helpers.dart';
import 'utils/sessions.dart';
import 'utils/strings.dart';

class PageRekapAbsenHarian extends StatefulWidget {
  const PageRekapAbsenHarian({Key? key}) : super(key: key);

  @override
  State<PageRekapAbsenHarian> createState() => _PageRekapAbsenHarianState();
}

class _PageRekapAbsenHarianState extends State<PageRekapAbsenHarian> {
  List listRekapAbsen = [];

  String filterTahun = "", filterBulan = "";
  DateTime? selectedDate;
  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filterTahun = parseDateInd(DateTime.now().toString(), "yyyy");
    filterBulan = parseDateInd(DateTime.now().toString(), "MM");
    getRekapAbsen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Image(
          image: AssetImage(AppImages.bg2),
          fit: BoxFit.cover,
        ),
        centerTitle: true,
        // systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: colorPrimary,
        leading: GestureDetector(
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
        title: const SizedBox(
          // width: double.infinity,
          child: Text(
            "Rekap Absen Harian",
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: <Widget>[
          // IconButton(
          //   icon: const Icon(Icons.calendar_today_rounded),
          //   onPressed: () {
          //     Navigator.push(context, MaterialPageRoute(builder: (context) => const PageRekapAbsenHarian()));
          //   },
          // )
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: colorBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 14, right: 10, top: 10, bottom: 10),
              child: Container(
                width: 150,
                child: ElevatedButton(
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
                        getRekapAbsen();
                      }
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(MdiIcons.calendar),
                      const SizedBox(width: 5),
                      Center(
                        child: TextMontserrat(
                          text: "${parseDateInd("2023-${filterBulan}-19", "MMMM")} - ${filterTahun}",
                          fontSize: 10,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(
              height: 1,
              color: Colors.black54,
            ),
            Expanded(
              child: ListView.separated(
                itemCount: listRekapAbsen.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () {
                      if (listRekapAbsen[index]['absen_masuk']['kd_absen_harian'] == "" && listRekapAbsen[index]['absen_pulang']['kd_absen_harian'] == "") {
                        if (safetyParseInt(listRekapAbsen[index]['tanggal']) > DateTime.now().day && safetyParseInt(listRekapAbsen[index]['bulan']) == DateTime.now().month) {
                          showToast(
                              "Anda Belum Melakukan Absen Untuk Tanggal ${listRekapAbsen[index]['tanggal']} ${parseDateInd("2023-" + listRekapAbsen[index]['bulan'].toString() + "-01", "MMMM")}");
                        } else {
                          showToast("Pada Tanggal ${listRekapAbsen[index]['tanggal']} ${parseDateInd("2023-" + listRekapAbsen[index]['bulan'].toString() + "-01", "MMMM")} Anda Tidak Melakukan Absen");
                        }
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PageDetailAbsen(dataAbsen: listRekapAbsen[index]),
                          ),
                        );
                      }
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.only(top: 12),
                      color: listRekapAbsen[index]['jadwal'] == "1" ? Colors.white : Colors.white,
                      // padding: const EdgeInsets.all(16),
                      child: listRekapAbsen[index]['jadwal'].toString() == "1"
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        MdiIcons.calendar,
                                      ),
                                      SizedBox(width: 12),
                                      TextMontserrat(
                                        text: parseDateInd((listRekapAbsen[index]['tahun'] + listRekapAbsen[index]['bulan'] + listRekapAbsen[index]['tanggal']).toString(), "EEEE dd MMMM yyyy"),
                                        fontSize: 14,
                                        color: Colors.black,
                                      )
                                    ],
                                  ),
                                  Divider(),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextMontserrat(
                                          text: "Absen Masuk ",
                                          fontSize: 14,
                                          color: Colors.green,
                                        ),
                                      ),
                                      TextMontserrat(
                                        text: ":",
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        flex: 3,
                                        child: TextMontserrat(
                                          text: listRekapAbsen[index]["absen_masuk"]["jam_absen"].toString().replaceAll("-", "Tidak Absen Masuk"),
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextMontserrat(
                                          text: "Keterangan",
                                          fontSize: 14,
                                          color: Colors.green,
                                        ),
                                      ),
                                      TextMontserrat(
                                        text: ":",
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        flex: 3,
                                        child: TextMontserrat(
                                          text: "${listRekapAbsen[index]["absen_masuk"]["ket_keterangan"]}",
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextMontserrat(
                                          text: "Absen Pulang",
                                          fontSize: 14,
                                          color: Colors.red,
                                        ),
                                      ),
                                      TextMontserrat(
                                        text: ":",
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        flex: 3,
                                        child: TextMontserrat(
                                          text: listRekapAbsen[index]["absen_pulang"]["jam_absen"].toString().replaceAll("-", "Tidak Absen Pulang"),
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextMontserrat(
                                          text: "Keterangan",
                                          fontSize: 14,
                                          color: Colors.red,
                                        ),
                                      ),
                                      TextMontserrat(
                                        text: ":",
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        flex: 3,
                                        child: TextMontserrat(
                                          text: "${listRekapAbsen[index]["absen_pulang"]["ket_keterangan"]}",
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(
                                              MdiIcons.calendar,
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: TextMontserrat(
                                                text: "${listRekapAbsen[index]["hari"]}, ${listRekapAbsen[index]["tanggal"]} ${listRekapAbsen[index]["bulan"]} ${listRekapAbsen[index]["tahun"]}",
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: TextMontserrat(
                                          text: "Tidak Ada Jadwal",
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )),
                    ),
                  ),
                ),
                separatorBuilder: (BuildContext context, int index) => const Divider(height: 0),
              ),
            )
          ],
        ),
      ),
    );
  }

  // getRekapAbsen() async {
  //   setState(() {
  //     loading = true;
  //     listRekapAbsen.clear();
  //   });

  //   if (await Helpers.isNetworkAvailable()) {
  //     String tokenAuth = "", hashUser = "";
  //     tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
  //     hashUser = (await getPrefrence(HASH_USER))!;

  //     var param = {
  //       'token_auth': tokenAuth,
  //       'hash_user': hashUser,
  //       'tahun': filterTahun,
  //       'bulan': filterBulan,
  //     };

  //     http.Response response = await http.post(
  //       Uri.parse(urlGetRekapAbsen),
  //       headers: headers,
  //       body: param,
  //     );

  //     setState(() {
  //       loading = false;
  //     });

  //     log(response.body);
  //     try {
  //       Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
  //       log(jsonResponse.toString());
  //       if (jsonResponse.containsKey("error")) {
  //         Helpers.dialogErrorNetwork(context, jsonResponse["error"]);
  //       } else {
  //         bool success = jsonResponse['success'];
  //         // String message = jsonResponse['message'];
  //         if (success) {
  //           setState(() {
  //             listRekapAbsen.clear();
  //           });

  //           for (int i = 0; i < jsonResponse["data"].length; i++) {
  //             RekapAbsen rekapAbsen = RekapAbsen();
  //             rekapAbsen.hari = jsonResponse["data"][i]["hari"].toString();
  //             rekapAbsen.tanggal = jsonResponse["data"][i]["tanggal"].toString();
  //             rekapAbsen.bulan = jsonResponse["data"][i]["bulan"].toString();
  //             rekapAbsen.tahun = jsonResponse["data"][i]["tahun"].toString();
  //             rekapAbsen.label = jsonResponse["data"][i]["label"].toString();
  //             rekapAbsen.jadwal = jsonResponse["data"][i]["jadwal"].toString();
  //             rekapAbsen.labelJadwal = jsonResponse["data"][i]["label_jadwal"].toString();
  //             AbsenHarian absenMasuk = AbsenHarian();
  //             absenMasuk.kdAbsenHarian = jsonResponse["data"][i]["absen_masuk"]["kd_absen_harian"];
  //             absenMasuk.hashJadwal = jsonResponse["data"][i]["absen_masuk"]["hash_jadwal"];
  //             absenMasuk.tglAbsen = jsonResponse["data"][i]["absen_masuk"]["tgl_absen"];
  //             absenMasuk.tahunAbsen = jsonResponse["data"][i]["absen_masuk"]["tahun_absen"];
  //             absenMasuk.bulanAbsen = jsonResponse["data"][i]["absen_masuk"]["bulan_absen"];
  //             absenMasuk.tanggalAbsen = jsonResponse["data"][i]["absen_masuk"]["tanggal_absen"];
  //             absenMasuk.jamAbsen = jsonResponse["data"][i]["absen_masuk"]["jam_absen"];
  //             absenMasuk.lat = jsonResponse["data"][i]["absen_masuk"]["lat"];
  //             absenMasuk.long = jsonResponse["data"][i]["absen_masuk"]["long"];
  //             absenMasuk.statusAbsen = jsonResponse["data"][i]["absen_masuk"]["status_absen"];
  //             absenMasuk.ketStatusAbsen = jsonResponse["data"][i]["absen_masuk"]["ket_status_absen"];
  //             absenMasuk.metode = jsonResponse["data"][i]["absen_masuk"]["metode"];
  //             absenMasuk.ketMetode = jsonResponse["data"][i]["absen_masuk"]["ket_metode"];
  //             // absenMasuk.fotoAbsen = jsonResponse["data"][i]["absen_masuk"]["foto_absen"];
  //             absenMasuk.keterangan = jsonResponse["data"][i]["absen_masuk"]["keterangan"];
  //             absenMasuk.ketKeterangan = jsonResponse["data"][i]["absen_masuk"]["ket_keterangan"];
  //             rekapAbsen.absenMasuk = absenMasuk;

  //             AbsenHarian absenPulang = AbsenHarian();
  //             absenPulang.kdAbsenHarian = jsonResponse["data"][i]["absen_pulang"]["kd_absen_harian"];
  //             absenPulang.hashJadwal = jsonResponse["data"][i]["absen_pulang"]["hash_jadwal"];
  //             absenPulang.tglAbsen = jsonResponse["data"][i]["absen_pulang"]["tgl_absen"];
  //             absenPulang.tahunAbsen = jsonResponse["data"][i]["absen_pulang"]["tahun_absen"];
  //             absenPulang.bulanAbsen = jsonResponse["data"][i]["absen_pulang"]["bulan_absen"];
  //             absenPulang.tanggalAbsen = jsonResponse["data"][i]["absen_pulang"]["tanggal_absen"];
  //             absenPulang.jamAbsen = jsonResponse["data"][i]["absen_pulang"]["jam_absen"];
  //             absenPulang.lat = jsonResponse["data"][i]["absen_pulang"]["lat"];
  //             absenPulang.long = jsonResponse["data"][i]["absen_pulang"]["long"];
  //             absenPulang.statusAbsen = jsonResponse["data"][i]["absen_pulang"]["status_absen"];
  //             absenPulang.ketStatusAbsen = jsonResponse["data"][i]["absen_pulang"]["ket_status_absen"];
  //             absenPulang.metode = jsonResponse["data"][i]["absen_pulang"]["metode"];
  //             absenPulang.ketMetode = jsonResponse["data"][i]["absen_pulang"]["ket_metode"];
  //             // absenPulang.fotoAbsen = jsonResponse["data"][i]["absen_pulang"]["foto_absen"];
  //             absenPulang.keterangan = jsonResponse["data"][i]["absen_pulang"]["keterangan"];
  //             absenPulang.ketKeterangan = jsonResponse["data"][i]["absen_pulang"]["ket_keterangan"];
  //             rekapAbsen.absenPulang = absenPulang;

  //             setState(() {
  //               listRekapAbsen.add(rekapAbsen);
  //             });
  //           }
  //         } else {}
  //       }
  //     } catch (e, stacktrace) {
  //       log(e.toString());
  //       log(stacktrace.toString());
  //       String customMessage = "${Strings.TERJADI_KESALAHAN}.\n${e.runtimeType.toString()} ${response.statusCode}";
  //       Helpers.dialogErrorNetwork(context, customMessage);
  //     }
  //   } else {
  //     setState(() {
  //       loading = false;
  //     });
  //     Helpers.dialogErrorNetwork(context, 'Tidak ada koneksi internet');
  //   }
  // }

  getRekapAbsen() async {
    setState(() {
      listRekapAbsen.clear();
    });
    final pref = await SharedPreferences.getInstance();

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.urlGetRekapAbsen,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH)!,
        'hash_user': pref.getString(HASH_USER)!,
        'tahun': filterTahun,
        'bulan': filterBulan,
      },
    );
    Map<String, dynamic> responseBody = response!;

    // listRekapAbsen = responseBody['data'];
    if (responseBody.isNotEmpty) {
      if (responseBody['success']) {
        for (int i = 0; i < responseBody['data'].length; i++) {
          setState(() {
            listRekapAbsen.add(responseBody['data'][i]);
          });
        }
      } else {
        return showToast("Data Tidak Ditemukann");
      }
    } else {
      return showToast(response['message']);
    }

    log("==============================================");
    log(listRekapAbsen.toString());
  }
}
