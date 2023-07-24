import 'dart:developer';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/ApiStatus.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/my_colors.dart';
import 'package:absentip/page_detail_izin.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/text_montserrat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:month_picker_dialog_2/month_picker_dialog_2.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageRekapCuti extends StatefulWidget {
  const PageRekapCuti({Key? key}) : super(key: key);

  @override
  State<PageRekapCuti> createState() => _PageRekapCutiState();
}

class _PageRekapCutiState extends State<PageRekapCuti> {
  String filterBulan = "", filterTahun = "";
  DateTime? selectedDate;
  ApiStatus _apistatus = ApiStatus.loading;

  List dataCuti = [];
  String jenisCuti = "";
  final _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    filterTahun = parseDateInd(DateTime.now().toString(), "yyyy");
    filterBulan = parseDateInd(DateTime.now().toString(), "MM");
    getRekapCuti();
    super.initState();
  }

  getRekapCuti() async {
    setState(() {
      dataCuti.clear();
      _apistatus = ApiStatus.loading;
    });
    final pref = await SharedPreferences.getInstance();

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.urlGetRekapCuti,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH)!,
        'hash_user': pref.getString(HASH_USER)!,
        'bulan': filterBulan.toString(),
        'tahun': filterTahun.toString(),
      },
    );

    log(response.toString());

    if (response != null) {
      if (response['success']) {
        for (int i = 0; i < response['data'].length; i++) {
          dataCuti.add(response['data'][i]);
        }
        if (mounted) {
          setState(() {
            _apistatus = ApiStatus.success;
          });
        }
      } else {
        showToast("Data Tidak Ditemukan");
        setState(() {
          _apistatus = ApiStatus.empty;
        });
      }
    } else {
      showToast("Terjadi Kesalahan");
      setState(() {
        _apistatus = ApiStatus.failed;
      });
    }

    if (_refreshController.isRefresh) {
      _refreshController.refreshCompleted();
    }

    log(_apistatus.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: const Image(
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
              "Rekap Cuti",
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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
                        getRekapCuti();
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
              const Divider(
                color: Colors.black,
              ),
              Expanded(
                child: SmartRefresher(
                    controller: _refreshController,
                    onRefresh: () => getRekapCuti(),
                    header: const ClassicHeader(),
                    physics: const BouncingScrollPhysics(),
                    child: Builder(
                      builder: (context) {
                        if (_apistatus == ApiStatus.success) {
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: dataCuti.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => PageDetailIzin(data: dataCuti[index], pageIzin: false),
                                  ));
                                },
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Container(
                                                margin: EdgeInsets.only(right: 20),
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Center(
                                                  child: TextMontserrat(
                                                    text: dataCuti[index]['ket_jenis_cuti'].toString(),
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // const SizedBox(width: ),
                                            Row(
                                              children: [
                                                dataCuti[index]['status_verifikasi'] == "1"
                                                    ? Icon(
                                                        MdiIcons.close,
                                                        color: Colors.red,
                                                      )
                                                    : Icon(
                                                        MdiIcons.check,
                                                        color: Colors.green,
                                                      ),
                                                TextMontserrat(
                                                  text: dataCuti[index]['status_verifikasi'] == "1" ? "Belum Disetujui" : "Disetujui",
                                                  fontSize: 14,
                                                  bold: true,
                                                  color: Colors.black,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        Divider(),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: TextMontserrat(
                                                text: "Tanggal Cuti",
                                                fontSize: 14,
                                                bold: true,
                                                color: Colors.green,
                                              ),
                                            ),
                                            Text(
                                              ": ",
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: TextMontserrat(
                                                text: parseDateInd(dataCuti[index]['tgl_cuti'].toString(), "EEE dd MMMM yyyy"),
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: TextMontserrat(
                                                text: "Keterangan",
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              ": ",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: TextMontserrat(
                                                text: dataCuti[index]['keterangan'],
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        } else if (_apistatus == ApiStatus.loading) {
                          return CupertinoActivityIndicator();
                        } else if (_apistatus == ApiStatus.empty) {
                          return const Center(child: Text("Halaman tidak ditemukan"));
                        } else {
                          return const Center(child: Text("Terjadi kesalahan"));
                        }
                      },
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
