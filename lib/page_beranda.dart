import 'dart:convert';
import 'dart:developer';

import 'package:absentip/page_rekap_absen_harian.dart';
import 'package:absentip/model/tryout.dart';
import 'package:absentip/page_profil.dart';
import 'package:absentip/widgets.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'harian/page_beranda_absen_harian.dart';
import 'page_list_tryout.dart';
import 'my_colors.dart';
import 'utils/api.dart';
import 'utils/constants.dart';
import 'utils/helpers.dart';
import 'utils/sessions.dart';

class PageBeranda extends StatefulWidget {
  const PageBeranda({Key? key}) : super(key: key);

  @override
  State<PageBeranda> createState() => _PageBerandaState();
}

class _PageBerandaState extends State<PageBeranda> {

  bool loadingJadwalTryOut = true, loadingAbsenHariIni = true, jadwalAbsen = false;
  List<Tryout> list = [];
  String nama = "", foto = "", jamAbsenMasuk = "", jamAbsenPulang = "", keteranganMasuk = "", keteranganPulang = "", pesanKosong = "";

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
    getAbsenHariIni();
    getListTryoutHariIni();
  }

  Future _onRefresh() async {
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: colorPrimary,
        title: const SizedBox(
          width: double.infinity,
          child: Text("Beranda",
            textAlign: TextAlign.start,
            style: TextStyle(color: Colors.black, overflow: TextOverflow.ellipsis),
          ),
        ),
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
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                        elevation: 6,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Selamat Datang,", style: TextStyle(color: Colors.black45),),
                                        Text(nama, style: const TextStyle(fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  ),
                                  foto!="" ? InkWell(
                                    child: CircleAvatar(
                                      child: Padding(
                                        padding: const EdgeInsets.all(1),
                                        child: ClipOval(child: Image.network(foto)),
                                      ),
                                      backgroundColor: Colors.black38,
                                    ),
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PageProfil()));
                                    },
                                  ) : const CupertinoActivityIndicator(),
                                ],
                              ),
                              const SizedBox(height: 16,),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              const Text("Absen Masuk", style: TextStyle(fontSize: 10),),
                                              const SizedBox(height: 2,),
                                              !loadingAbsenHariIni ? Text(jamAbsenMasuk,
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  color: keteranganMasuk=="1" || keteranganMasuk=="2" ? Colors.red : Colors.green,
                                                  fontSize: jadwalAbsen ? 16 : 12, fontWeight: FontWeight.bold,
                                                ),
                                              ) : const CupertinoActivityIndicator(),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10,),
                                        const VerticalDivider(width: 1, color: Colors.black,),
                                        const SizedBox(width: 10,),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text("Absen Pulang", style: TextStyle(fontSize: 10),),
                                              const SizedBox(height: 2,),
                                              !loadingAbsenHariIni ? Text(jamAbsenPulang,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: keteranganPulang=="1" || keteranganPulang=="2" ? Colors.red : Colors.green,
                                                  fontSize: jadwalAbsen ? 16 : 12, fontWeight: FontWeight.bold,
                                                ),
                                              ) : const CupertinoActivityIndicator(),
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Container(
                      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 5),
                      child: !loadingJadwalTryOut
                          ?
                      const Text("Jadwal Tryout Anda", style: TextStyle(fontWeight: FontWeight.bold),)
                          :
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Text("Jadwal Tryout Anda", style: TextStyle(fontWeight: FontWeight.bold),),
                          SizedBox(width: 5,),
                          CupertinoActivityIndicator(),
                          Expanded(
                            child: SizedBox(),
                          ),
                        ],
                      ),
                    ),
                    !loadingJadwalTryOut ? (list.isNotEmpty ? ExpandablePageView.builder(
                      controller: PageController(viewportFraction: 0.9),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return widgetItemTryout(context, list[index]);
                      },
                    ) : Container(
                      margin: const EdgeInsets.only(left: 16, right: 16),
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                        color: colorInfo,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(pesanKosong, style: const TextStyle(fontSize: 12),),
                        ),
                      ),
                    )) : const SizedBox(),
                    const SizedBox(height: 16,),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PageBerandaAbsenHarian()));
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/ic_absensi.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 10,),
                                      const Text("Absen Harian\n", maxLines: 2, textAlign: TextAlign.center,),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PageRekapAbsenHarian()));
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/ic_izin.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 10,),
                                      const Text("Rekap Absen\n", maxLines: 2, textAlign: TextAlign.center,),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PageListTryout(jenisTryout: JenisTryout.jasmani,)));
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/ic_jasmani.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 10,),
                                      const Text("Jasmani\n", maxLines: 2, textAlign: TextAlign.center,),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PageListTryout(jenisTryout: JenisTryout.akademik,)));
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/ic_akademik.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 10,),
                                      const Text("Akademik\n", maxLines: 2, textAlign: TextAlign.center,),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PageListTryout(jenisTryout: JenisTryout.psikologi,)));
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/ic_psikolog.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 10,),
                                      const Text("Psikologi\n", maxLines: 2, textAlign: TextAlign.center,),
                                    ],
                                  ),
                                ),
                              ),
                              const Expanded(flex: 3, child: SizedBox(),),
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

  Widget widgetMenuItem(String icon, String label) {

    return Column(
      children: [
        Image.asset(
          icon,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 10,),
        Text(label, maxLines: 2, textAlign: TextAlign.center,),
      ],
    );

  }

  getAbsenHariIni() async {

    setState(() {
      loadingAbsenHariIni = true;
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
          Uri.parse(urlGetAbsenHarian),
          headers: headers,
          body: param,
        );

        setState(() {
          loadingAbsenHariIni = false;
        });

        log(response.body);

        Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        log(jsonResponse.toString());
        if (jsonResponse.containsKey("error")) {

        } else {

          bool success = jsonResponse['success'];
          if (success) {
            setState(() {
              jadwalAbsen = true;
              if(jsonResponse['absenMasuk'].toString().toLowerCase()!="null") {
                jamAbsenMasuk = jsonResponse["absenMasuk"]["jam_absen"].toString();
                keteranganMasuk = jsonResponse["absenMasuk"]["keterangan"].toString();
              } else {
                jamAbsenMasuk = "-";
                keteranganMasuk = "";
              }
              if(jsonResponse['absenPulang'].toString().toLowerCase()!="null") {
                jamAbsenPulang = jsonResponse["absenPulang"]["jam_absen"].toString();
                keteranganPulang = jsonResponse["absenPulang"]["keterangan"].toString();
              } else {
                jamAbsenPulang = "-";
                keteranganPulang = "";
              }
            });
          } else {
            setState(() {
              jadwalAbsen = false;
              jamAbsenMasuk = "Tidak ada jadwal";
              jamAbsenPulang = "Tidak ada jadwal";
              keteranganMasuk = "";
              keteranganPulang = "";
            });
          }
        }
      } catch (e, stacktrace) {
        log(stacktrace.toString());
        setState(() {
          loadingAbsenHariIni = false;
        });
      }

    } else {

      setState(() {
        loadingAbsenHariIni = false;
      });
    }
  }

  getListTryoutHariIni() async {

    setState(() {
      loadingJadwalTryOut = true;
      list.clear();
    });

    if(await Helpers.isNetworkAvailable()) {

      try {

        String email = "", tokenAuth = "", hashUser = "";
        email = (await getPrefrence(EMAIL))!;
        tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
        hashUser = (await getPrefrence(HASH_USER))!;

        var param = {
          'username': email,
          'token_auth': tokenAuth,
          'hash_user': hashUser,
        };

        http.Response response = await http.post(
          Uri.parse(urlListTryoutHariIni),
          headers: headers,
          body: param,
        );

        setState(() {
          loadingJadwalTryOut = false;
        });

        log(response.body);

        Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        log(jsonResponse.toString());
        if (jsonResponse.containsKey("error")) {

        } else {

          bool success = jsonResponse['success'];
          String message = jsonResponse["message"];
          if (success) {

            setState(() {
              list.clear();
            });

            for(int i=0; i<jsonResponse["data"].length; i++){

              Tryout tryout = Tryout();
              tryout.jenisTryout = jsonResponse["data"][i]["jenis_tryout"].toString();
              tryout.idTryout = jsonResponse["data"][i]["id_tryout"].toString();
              tryout.kdTryout = jsonResponse["data"][i]["kd_tryout"].toString();
              tryout.namaTryout = jsonResponse["data"][i]["nama_tryout"].toString();
              tryout.keterangan = jsonResponse["data"][i]["keterangan"].toString();
              tryout.waktu = jsonResponse["data"][i]["waktu"].toString();
              tryout.waktuMulai = jsonResponse["data"][i]["waktu_mulai_formatted"].toString();
              tryout.waktuSelesai = jsonResponse["data"][i]["waktu_selesai_formatted"].toString();
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
            setState(() {
              pesanKosong = message;
            });
          }
        }
      } catch (e, stacktrace) {
        log(stacktrace.toString());
        setState(() {
          loadingJadwalTryOut = false;
          pesanKosong = e.toString();
        });
      }

    } else {

      setState(() {
        loadingJadwalTryOut = false;
        pesanKosong = "Tidak ada koneksi internet";
      });
    }
  }

}
