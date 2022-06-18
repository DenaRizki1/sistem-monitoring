import 'dart:convert';
import 'dart:developer';

import 'package:absentip/page_absen_tryout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'model/tryout.dart';
import 'my_colors.dart';
import 'utils/api.dart';
import 'utils/constants.dart';
import 'utils/helpers.dart';
import 'utils/sessions.dart';
import 'utils/strings.dart';

class PageDetailTryout extends StatefulWidget {

  final Tryout tryout;
  const PageDetailTryout({Key? key, required this.tryout}) : super(key: key);

  @override
  State<PageDetailTryout> createState() => _PageDetailTryoutState();
}

class _PageDetailTryoutState extends State<PageDetailTryout> {

  bool loading = true;
  Tryout tryout = Tryout();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetailTryoutJasmani(widget.tryout.kdTryout);
  }

  Future _onRefresh() async {
    getDetailTryoutJasmani(widget.tryout.kdTryout);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: colorPrimary,
        title: SizedBox(
          width: double.infinity,
          child: Text("Jadwal Tryout ${toBeginningOfSentenceCase(widget.tryout.jenisTryout)}",
            textAlign: TextAlign.start,
            style: const TextStyle(
                color: Colors.black, overflow: TextOverflow.ellipsis),
          ),
        ),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.search),
        //     onPressed: () {
        //
        //     },
        //   )
        // ],
      ),
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
          Container(
            padding: const EdgeInsets.all(16),
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(tryout.namaTryout, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          const SizedBox(height: 10,),
                          widgetRow("Pendidikan", tryout.namaPendidikan),
                          tryout.jenisTryout!=JenisTryout.psikologi ? widgetRow("Mata Pelajaran", tryout.namaMataPelajaran) : const SizedBox(),
                          widgetRow("Jumlah Soal", tryout.jumlahSoal),
                          widgetRow("Waktu", tryout.waktu),
                          widgetRow("Waktu Mulai", tryout.waktuMulai),
                          widgetRow("Waktu Selesai", tryout.waktuSelesai),
                          const SizedBox(height: 5,),
                          tryout.absenTryout.tanggalJam == ""
                              ?
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    flex: 2,
                                    child: Text("Status Absen"),
                                  ),
                                  const SizedBox(width: 3,),
                                  const Text(":"),
                                  const SizedBox(width: 3,),
                                  Expanded(
                                    flex: 3,
                                    child: !loading ? Text(tryout.absenTryout.bisaAbsen) : const SizedBox(),
                                  ),
                                ],
                              ),
                              tryout.absenTryout.statusBisaAbsen!=null ? tryout.absenTryout.statusBisaAbsen! ? SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => PageAbsenTryout(tryout: tryout,)));
                                      if(result!=null) {
                                        getDetailTryoutJasmani(widget.tryout.kdTryout);
                                      }
                                    },
                                    child: const Text("Absen")),
                              ) : const SizedBox() : const SizedBox(),
                            ],
                          ) : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widgetRow("Status Absen", "Sudah Absen"),
                              widgetRow("Tanggal Absen", tryout.absenTryout.tanggalJam),
                              // widgetRow("Status", tryout.absenTryout.statusKet),
                              // widgetRow("Lat", tryout.absenTryout.lat),
                              // widgetRow("Long", tryout.absenTryout.long),
                              // widgetRow("Metode", tryout.absenTryout.metode),
                              // widgetRow("Foto", tryout.absenTryout.fotoAbsen),
                            ],
                          ),
                        ],
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

  getDetailTryoutJasmani(String kdTryout) async {

    setState(() {
      loading = true;
    });

    if(await Helpers.isNetworkAvailable()) {

      String tokenAuth = "", hashUser = "";
      tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
      hashUser = (await getPrefrence(HASH_USER))!;

      var param = {
        'kd_tryout': kdTryout,
        'token_auth': tokenAuth,
        'hash_user': hashUser,
      };

      String url = "";
      switch(widget.tryout.jenisTryout) {
        case JenisTryout.jasmani:
          url = urlDetailTryoutJasmani;
          break;
        case JenisTryout.akademik:
          url = urlDetailTryoutAkademik;
          break;
        case JenisTryout.psikologi:
          url = urlDetailTryoutPsikologi;
          break;
      }

      setState(() {
        loading = false;
      });

      try {
        http.Response response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: param,

        );
        log(response.body);
        Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        log(jsonResponse.toString());
        if (jsonResponse.containsKey("error")) {
          Helpers.dialogErrorNetwork(context, jsonResponse["error"]);
        } else {

          bool success = jsonResponse['success'];
          // String message = jsonResponse['message'];
          if (success) {

            setState(() {
              tryout.jenisTryout = widget.tryout.jenisTryout;
              tryout.kdTryout = jsonResponse['data']["kd_tryout"].toString();
              tryout.namaTryout = jsonResponse['data']["nama_tryout"].toString();
              tryout.jumlahSoal = jsonResponse['data']["jumlah_soal"].toString();
              tryout.waktu = jsonResponse['data']["waktu"].toString();
              tryout.waktuMulai = jsonResponse['data']["waktu_mulai"].toString();
              tryout.waktuSelesai = jsonResponse['data']["waktu_selesai"].toString();
              tryout.createdAt = jsonResponse['data']["created_at"].toString();
              tryout.keterangan = jsonResponse['data']["keterangan"].toString();
              tryout.kdPengajar = jsonResponse['data']["kd_pengajar"].toString();
              tryout.namaMataPelajaran = jsonResponse['data']["nama_matapelajaran"].toString();
              tryout.namaPendidikan = jsonResponse['data']["nama_pendidikan"].toString();
              tryout.absenTryout.bisaAbsen = jsonResponse["data"]["absen"]["bisa_absen"].toString();
              tryout.absenTryout.statusBisaAbsen = jsonResponse["data"]["absen"]["status_bisa_absen"];
              tryout.absenTryout.tanggalJam = jsonResponse["data"]["absen"]["tanggal_jam"].toString();
              tryout.absenTryout.lat = jsonResponse["data"]["absen"]["lat"].toString();
              tryout.absenTryout.long = jsonResponse["data"]["absen"]["long"].toString();
              tryout.absenTryout.status = jsonResponse["data"]["absen"]["status"].toString();
              tryout.absenTryout.metode = jsonResponse["data"]["absen"]["metode"].toString();
              tryout.absenTryout.fotoAbsen = jsonResponse["data"]["absen"]["foto_absen"].toString();
            });

          } else {

          }
        }
      } catch (e, stacktrace) {
        log(e.toString());
        log(stacktrace.toString());
        String customMessage = "${Strings.TERJADI_KESALAHAN}.\n${e.runtimeType.toString()}";
        Helpers.dialogErrorNetwork(context, customMessage);
      }

    } else {
      setState(() {
        loading = false;
      });
      Helpers.dialogErrorNetwork(context, 'Tidak ada koneksi internet');
    }
  }

  Widget widgetRow(String label, String data){

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label),
        ),
        const SizedBox(width: 3,),
        const Text(":"),
        const SizedBox(width: 3,),
        Expanded(
          flex: 3,
          child: !loading ? Text(data) : const SizedBox(),
        ),
      ],
    );

  }
}
