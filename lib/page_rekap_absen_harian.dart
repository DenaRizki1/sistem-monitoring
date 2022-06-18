import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

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

  List<RekapAbsen> listRekapAbsen = [];

  String filterTahun = "", filterBulan = "";
  DateTime? selectedDate;
  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filterTahun = DateTime.now().year.toString();
    filterBulan = DateTime.now().month.toString();
    getRekapAbsen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar.getAppBar("Rekap Absen Harian"),
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
              margin: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              child: Card(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded),
                        const SizedBox(width: 10,),
                        Text(Helpers.getBulan(filterBulan) + " " + filterTahun),
                      ],
                    ),
                    onTap: () async {
                      showMonthPicker(
                        context: context,
                        firstDate: DateTime(2022),
                        lastDate: DateTime.now(),
                        initialDate: selectedDate ?? DateTime.now(),
                      ).then((date) {
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                            filterTahun = date.year.toString();
                            filterBulan = date.month.toString();
                          });
                          getRekapAbsen();
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: Colors.black54,),
            Expanded(
              child: ListView.separated(
                itemCount: listRekapAbsen.length,
                itemBuilder: (context, index) => Container(
                  color: listRekapAbsen[index].jadwal=="1" ? Colors.white : Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: listRekapAbsen[index].jadwal=="1" ?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(listRekapAbsen[index].hari+",", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
                                Text(listRekapAbsen[index].tanggal + "-" + listRekapAbsen[index].bulan + "-" + listRekapAbsen[index].tahun, style: const TextStyle(fontSize: 12),),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Expanded(child: Text("Absen Masuk", style: TextStyle(fontSize: 12),)),
                                    const SizedBox(width: 5,),
                                    const Text(":", style: TextStyle(fontSize: 12),),
                                    const SizedBox(width: 5,),
                                    Expanded(child: Text(listRekapAbsen[index].absenMasuk.jamAbsen, style: const TextStyle(fontSize: 12),)),
                                  ],
                                ),
                                if(listRekapAbsen[index].absenMasuk.ketKeterangan!="") Text(listRekapAbsen[index].absenMasuk.ketKeterangan, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
                                const SizedBox(height: 5,),
                                Row(
                                  children: [
                                    const Expanded(child: Text("Absen Pulang", style: TextStyle(fontSize: 12),)),
                                    const SizedBox(width: 5,),
                                    const Text(":", style: TextStyle(fontSize: 12),),
                                    const SizedBox(width: 5,),
                                    Expanded(child: Text(listRekapAbsen[index].absenPulang.jamAbsen, style: const TextStyle(fontSize: 12),)),
                                  ],
                                ),
                                if(listRekapAbsen[index].absenPulang.ketKeterangan!="") Text(listRekapAbsen[index].absenPulang.ketKeterangan, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                      :
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(listRekapAbsen[index].hari + ",", style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),),
                            Text(listRekapAbsen[index].tanggal + "-" + listRekapAbsen[index].bulan + "-" + listRekapAbsen[index].tahun, style: const TextStyle(fontSize: 12.0),),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(listRekapAbsen[index].labelJadwal, style: const TextStyle(fontSize: 12,),),
                      ),
                    ],
                  ),
                ),
                separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
              ),
            )
          ],
        ),
      ),
    );
  }

  getRekapAbsen() async {

    setState(() {
      loading = true;
      listRekapAbsen.clear();
    });

    if(await Helpers.isNetworkAvailable()) {

      String tokenAuth = "", hashUser = "";
      tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
      hashUser = (await getPrefrence(HASH_USER))!;

      var param = {
        'token_auth': tokenAuth,
        'hash_user': hashUser,
        'tahun' : filterTahun,
        'bulan' : filterBulan,
      };

      http.Response response = await http.post(
        Uri.parse(urlGetRekapAbsen),
        headers: headers,
        body: param,
      );

      setState(() {
        loading = false;
      });

      log(response.body);
      try {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        log(jsonResponse.toString());
        if (jsonResponse.containsKey("error")) {
          Helpers.dialogErrorNetwork(context, jsonResponse["error"]);
        } else {

          bool success = jsonResponse['success'];
          // String message = jsonResponse['message'];
          if (success) {

            setState(() {
              listRekapAbsen.clear();
            });

            for(int i=0; i<jsonResponse["data"].length; i++){

              RekapAbsen rekapAbsen = RekapAbsen();
              rekapAbsen.hari = jsonResponse["data"][i]["hari"].toString();
              rekapAbsen.tanggal = jsonResponse["data"][i]["tanggal"].toString();
              rekapAbsen.bulan = jsonResponse["data"][i]["bulan"].toString();
              rekapAbsen.tahun = jsonResponse["data"][i]["tahun"].toString();
              rekapAbsen.label = jsonResponse["data"][i]["label"].toString();
              rekapAbsen.jadwal = jsonResponse["data"][i]["jadwal"].toString();
              rekapAbsen.labelJadwal = jsonResponse["data"][i]["label_jadwal"].toString();
              AbsenHarian absenMasuk = AbsenHarian();
              absenMasuk.kdAbsenHarian = jsonResponse["data"][i]["absen_masuk"]["kd_absen_harian"];
              absenMasuk.hashJadwal = jsonResponse["data"][i]["absen_masuk"]["hash_jadwal"];
              absenMasuk.tglAbsen = jsonResponse["data"][i]["absen_masuk"]["tgl_absen"];
              absenMasuk.tahunAbsen = jsonResponse["data"][i]["absen_masuk"]["tahun_absen"];
              absenMasuk.bulanAbsen = jsonResponse["data"][i]["absen_masuk"]["bulan_absen"];
              absenMasuk.tanggalAbsen = jsonResponse["data"][i]["absen_masuk"]["tanggal_absen"];
              absenMasuk.jamAbsen = jsonResponse["data"][i]["absen_masuk"]["jam_absen"];
              absenMasuk.lat = jsonResponse["data"][i]["absen_masuk"]["lat"];
              absenMasuk.long = jsonResponse["data"][i]["absen_masuk"]["long"];
              absenMasuk.statusAbsen = jsonResponse["data"][i]["absen_masuk"]["status_absen"];
              absenMasuk.ketStatusAbsen = jsonResponse["data"][i]["absen_masuk"]["ket_status_absen"];
              absenMasuk.metode = jsonResponse["data"][i]["absen_masuk"]["metode"];
              absenMasuk.ketMetode = jsonResponse["data"][i]["absen_masuk"]["ket_metode"];
              // absenMasuk.fotoAbsen = jsonResponse["data"][i]["absen_masuk"]["foto_absen"];
              absenMasuk.keterangan = jsonResponse["data"][i]["absen_masuk"]["keterangan"];
              absenMasuk.ketKeterangan = jsonResponse["data"][i]["absen_masuk"]["ket_keterangan"];
              rekapAbsen.absenMasuk = absenMasuk;

              AbsenHarian absenPulang = AbsenHarian();
              absenPulang.kdAbsenHarian = jsonResponse["data"][i]["absen_pulang"]["kd_absen_harian"];
              absenPulang.hashJadwal = jsonResponse["data"][i]["absen_pulang"]["hash_jadwal"];
              absenPulang.tglAbsen = jsonResponse["data"][i]["absen_pulang"]["tgl_absen"];
              absenPulang.tahunAbsen = jsonResponse["data"][i]["absen_pulang"]["tahun_absen"];
              absenPulang.bulanAbsen = jsonResponse["data"][i]["absen_pulang"]["bulan_absen"];
              absenPulang.tanggalAbsen = jsonResponse["data"][i]["absen_pulang"]["tanggal_absen"];
              absenPulang.jamAbsen = jsonResponse["data"][i]["absen_pulang"]["jam_absen"];
              absenPulang.lat = jsonResponse["data"][i]["absen_pulang"]["lat"];
              absenPulang.long = jsonResponse["data"][i]["absen_pulang"]["long"];
              absenPulang.statusAbsen = jsonResponse["data"][i]["absen_pulang"]["status_absen"];
              absenPulang.ketStatusAbsen = jsonResponse["data"][i]["absen_pulang"]["ket_status_absen"];
              absenPulang.metode = jsonResponse["data"][i]["absen_pulang"]["metode"];
              absenPulang.ketMetode = jsonResponse["data"][i]["absen_pulang"]["ket_metode"];
              // absenPulang.fotoAbsen = jsonResponse["data"][i]["absen_pulang"]["foto_absen"];
              absenPulang.keterangan = jsonResponse["data"][i]["absen_pulang"]["keterangan"];
              absenPulang.ketKeterangan = jsonResponse["data"][i]["absen_pulang"]["ket_keterangan"];
              rekapAbsen.absenPulang = absenPulang;

              setState(() {
                listRekapAbsen.add(rekapAbsen);
              });
            }

          } else {

          }
        }
      } catch (e, stacktrace) {
        log(e.toString());
        log(stacktrace.toString());
        String customMessage = "${Strings.TERJADI_KESALAHAN}.\n${e.runtimeType.toString()} ${response.statusCode}";
        Helpers.dialogErrorNetwork(context, customMessage);
      }

    } else {
      setState(() {
        loading = false;
      });
      Helpers.dialogErrorNetwork(context, 'Tidak ada koneksi internet');
    }
  }
}

class RekapAbsen {
  String hari = "", tanggal = "", bulan = "", tahun = "", label = "", jadwal = "", labelJadwal = "";
  AbsenHarian absenMasuk = AbsenHarian(), absenPulang = AbsenHarian();
}
