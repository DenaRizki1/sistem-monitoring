import 'dart:convert';
import 'dart:developer';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/ApiStatus.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/utils/api.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/sessions.dart';
import 'package:absentip/utils/text_montserrat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:month_picker_dialog_2/month_picker_dialog_2.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageJadwal extends StatefulWidget {
  const PageJadwal({Key? key}) : super(key: key);

  @override
  State<PageJadwal> createState() => _PageJadwalState();
}

class _PageJadwalState extends State<PageJadwal> {
  String filterTahun = "", filterBulan = "", filterTgl = "";
  List rekapJadwal = [];

  DateTime? selectedDate;

  @override
  void initState() {
    // TODO: implement initState
    filterTahun = DateTime.now().year.toString();
    filterBulan = DateTime.now().month.toString();
    filterTgl = DateTime.now().day.toString();
    getJadwal();
    super.initState();
  }

  // getJadwal() async {
  //   if (mounted) {
  //     setState(() {
  //       rekapJadwal.clear();
  //     });
  //   }
  //   if (await Helpers.isNetworkAvailable()) {
  //     String tokenAuth = "", hashUser = "";
  //     tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
  //     hashUser = (await getPrefrence(HASH_USER))!;

  //     var params = {
  //       'token_auth': tokenAuth,
  //       'hash_user': hashUser,
  //       'tahun': filterTahun,
  //       'bulan': filterBulan,
  //     };

  //     http.Response response = await http.post(
  //       Uri.parse(urlGetRekapAbsen),
  //       headers: headers,
  //       body: params,
  //     );
  //     Map<String, dynamic> jadwal = json.decode(response.body);

  //     for (int i = 0; i < jadwal['data'].length; i++) {
  //       if (jadwal['data'][i]['label_jadwal'] == "Ada jadwal") {
  //         log(jadwal['data'][i]['label_jadwal'] + " " + jadwal['data'][i]['tanggal']);
  //         rekapJadwal.add(jadwal['data'][i]);
  //         if (mounted) {
  //           setState(() {});
  //         }
  //         log(rekapJadwal.toString());
  //       }
  //     }
  //     log(filterTgl);
  //     log(filterBulan);
  //     log(jadwal['data'][6]['tanggal'].toString());
  //   }
  // }

  ApiStatus _apiStatus = ApiStatus.loading;
  final _refreshController = RefreshController(initialRefresh: false);

  Future<void> getJadwal() async {
    setState(() {
      _apiStatus = ApiStatus.loading;
      rekapJadwal.clear();
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

    final jadwal = response;

    if (response != null) {
      if (response['success']) {
        for (int i = 0; i < jadwal!['data'].length; i++) {
          if (jadwal['data'][i]['label_jadwal'] == "Ada jadwal") {
            log(jadwal['data'][i]['label_jadwal'] + " " + jadwal['data'][i]['tanggal']);
            rekapJadwal.add(jadwal['data'][i]);
            if (mounted) {
              setState(() {
                _apiStatus = ApiStatus.success;
              });
            }
            log(rekapJadwal.toString());
          }
        }
      } else {
        showToast(response['message'].toString());
        if (mounted) {
          setState(() {
            _apiStatus = ApiStatus.empty;
          });
        }
      }
    } else {
      setState(() {
        _apiStatus = ApiStatus.failed;
      });
    }

    if (_refreshController.isRefresh) {
      _refreshController.refreshCompleted();
    }

    log(response.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              width: 110,
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
                        filterBulan = date.month.toString();
                        filterTahun = date.year.toString();
                      });
                      getJadwal();
                    }
                  });
                },
                child: Row(
                  children: [
                    Icon(MdiIcons.calendar),
                    const SizedBox(width: 5),
                    TextMontserrat(
                      text: "${filterBulan}-${filterTahun}",
                      fontSize: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(),
          // Expanded(
          //   child: ListView.separated(
          //     shrinkWrap: true,
          //     physics: AlwaysScrollableScrollPhysics(),
          //     padding: const EdgeInsets.all(12),
          //     itemCount: rekapJadwal.length,
          //     itemBuilder: (context, index) {

          //     },
          //     separatorBuilder: (BuildContext context, int index) => const Divider(height: 0),
          //   ),
          // ),
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              header: const ClassicHeader(),
              physics: const BouncingScrollPhysics(),
              onRefresh: getJadwal,
              child: Builder(
                builder: (context) {
                  if (_apiStatus == ApiStatus.success) {
                    return ListView.builder(
                      itemCount: rekapJadwal.length,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: 12),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 5,
                          color: filterBulan == DateTime.now().month.toString() && filterTgl == rekapJadwal[index]['tanggal'].toString().replaceAll("0", "") ? AppColor.kuning : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextMontserrat(
                                      text: rekapJadwal[index]['hari'].toString(),
                                      fontSize: 18,
                                      color: filterBulan == DateTime.now().month.toString() && filterTgl == rekapJadwal[index]['tanggal'].toString().replaceAll("0", "") ? Colors.white : Colors.black,
                                    ),
                                    TextMontserrat(
                                      text: (rekapJadwal[index]['tanggal'] + "-" + rekapJadwal[index]['bulan'] + "-" + rekapJadwal[index]['tahun']).toString(),
                                      fontSize: 14,
                                      color: filterBulan == DateTime.now().month.toString() && filterTgl == rekapJadwal[index]['tanggal'].toString().replaceAll("0", "")
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.grey,
                                    )
                                  ],
                                )),
                                Expanded(
                                    child: TextMontserrat(
                                  text: "Jadwal",
                                  fontSize: 18,
                                  color: Colors.black,
                                )),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (_apiStatus == ApiStatus.loading) {
                    if (_refreshController.isRefresh) {
                      return Container();
                    } else {
                      return const Center(child: CupertinoActivityIndicator());
                    }
                  } else if (_apiStatus == ApiStatus.empty) {
                    return const Center(child: Text("Halaman tidak ditemukan"));
                  } else {
                    return const Center(child: Text("Terjadi kesalahan"));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
