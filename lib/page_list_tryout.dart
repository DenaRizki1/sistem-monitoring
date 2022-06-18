import 'dart:convert';
import 'dart:developer';

import 'package:absentip/widgets.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
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

class PageListTryout extends StatefulWidget {

  final String jenisTryout;
  const PageListTryout({Key? key, required this.jenisTryout}) : super(key: key);

  @override
  State<PageListTryout> createState() => _PageListTryoutState();
}

class _PageListTryoutState extends State<PageListTryout> {

  bool loading = true;
  List<Tryout> list = [];
  String filterTanggal = "", valueTanggal = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final now = DateTime.now();
    filterTanggal = DateFormat('yyyy-MM-dd').format(now);
    valueTanggal = filterTanggal;
    getListTryout();
  }

  Future _onRefresh() async {
    getListTryout();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: colorPrimary,
        title: SizedBox(
          width: double.infinity,
          child: Text("Tryout ${toBeginningOfSentenceCase(widget.jenisTryout)}",
            textAlign: TextAlign.start,
            style: const TextStyle(
                color: Colors.black, overflow: TextOverflow.ellipsis),
          ),
        ),
        // actions: <Widget>[
        //   IconButton(
        //     icon: const Icon(Icons.search),
        //     onPressed: () {
        //
        //     },
        //   )
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Stack(
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
            !loading ? (list.isEmpty ? SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: Text("Data tidak ditemukan", textAlign: TextAlign.center,),
              ),
            ) : const SizedBox()) : const Center(child: CupertinoActivityIndicator(),),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_rounded),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: DateTimePicker(
                              type: DateTimePickerType.date,
                              initialValue: filterTanggal,
                              firstDate: DateTime(2022),
                              lastDate: DateTime.now(),
                              onChanged: (val) {
                                log("onChanged $val");
                                setState(() {
                                  filterTanggal = val;
                                });
                                getListTryout();
                              },
                              onSaved: (val) {
                                log("onSaved $val");
                                // setState(() {
                                //   filterTanggal = val!;
                                //   valueTanggal = val;
                                //   log(val);
                                // });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Colors.black54,),
                Expanded(
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, index) => Container(
                      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: widgetItemTryout(context, list[index]),
                    ),
                    separatorBuilder: (BuildContext context, int index) => const Divider(height: 0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  getListTryout() async {

    setState(() {
      loading = true;
      list.clear();
    });

    if(await Helpers.isNetworkAvailable()) {

      String email = "", tokenAuth = "", hashUser = "";
      email = (await getPrefrence(EMAIL))!;
      tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
      hashUser = (await getPrefrence(HASH_USER))!;

      var param = {
        'username': email,
        'token_auth': tokenAuth,
        'hash_user': hashUser,
        'filter[tanggal]' : filterTanggal,
      };

      String url = "";
      switch(widget.jenisTryout) {
        case JenisTryout.jasmani:
          url = urlListTryoutJasmaniByPengajar;
          break;
        case JenisTryout.akademik:
          url = urlListTryoutAkademikByPengajar;
          break;
        case JenisTryout.psikologi:
          url = urlListTryoutPsikologiByPengajar;
          break;
      }

      http.Response response = await http.post(
        Uri.parse(url),
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
              list.clear();
            });

            for(int i=0; i<jsonResponse["data"].length; i++){

              Tryout tryout = Tryout();
              tryout.jenisTryout = widget.jenisTryout;
              tryout.idTryout = jsonResponse["data"][i]["id_tryout"].toString();
              tryout.kdTryout = jsonResponse["data"][i]["kd_tryout"].toString();
              tryout.namaTryout = jsonResponse["data"][i]["nama_tryout"].toString();
              tryout.keterangan = jsonResponse["data"][i]["keterangan"].toString();
              tryout.waktu = jsonResponse["data"][i]["waktu"].toString();
              tryout.waktuMulai = jsonResponse["data"][i]["waktu_mulai"].toString();
              tryout.waktuSelesai = jsonResponse["data"][i]["waktu_selesai"].toString();
              tryout.jumlahSoal = jsonResponse["data"][i]["jumlah_soal"].toString();
              tryout.finish = jsonResponse["data"][i]["finish"].toString();
              tryout.kdPengajar = jsonResponse["data"][i]["kd_pengajar"].toString();
              tryout.createdAt = jsonResponse["data"][i]["created_at"].toString();
              tryout.absenTryout.bisaAbsen = jsonResponse["data"][i]["absen"]["bisa_absen"].toString();
              setState(() {
                list.add(tryout);
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
