import 'dart:developer';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/api_response.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/modules/absen/page_detail_absen.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:month_picker_dialog_2/month_picker_dialog_2.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageRekapAbsenHarian extends StatefulWidget {
  const PageRekapAbsenHarian({Key? key}) : super(key: key);

  @override
  State<PageRekapAbsenHarian> createState() => _PageRekapAbsenHarianState();
}

class _PageRekapAbsenHarianState extends State<PageRekapAbsenHarian> {
  final _apiResponse = ApiResponse();
  final _refreshC = RefreshController();
  final _listRekapAbsen = [];
  DateTime _filterDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    getRekapAbsen();
  }

  @override
  void dispose() {
    _refreshC.dispose();
    super.dispose();
  }

  Future<void> getRekapAbsen() async {
    setState(() {
      _apiResponse.setApiSatatus = ApiStatus.loading;
      _listRekapAbsen.clear();
    });

    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.absenHarian,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH)!,
        'hash_user': pref.getString(HASH_USER)!,
        'tahun': parseDateInd(_filterDate.toString(), "yyyy"),
        'bulan': parseDateInd(_filterDate.toString(), "MM"),
      },
    );

    if (_refreshC.isRefresh) {
      _refreshC.refreshCompleted();
    }

    if (response != null) {
      if (response['success']) {
        if (mounted) {
          setState(() {
            _apiResponse.setApiSatatus = ApiStatus.success;
            _listRekapAbsen.addAll(response['data']);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _apiResponse.setApiSatatus = ApiStatus.empty;
            _apiResponse.setMessage = response['message'].toString();
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _apiResponse.setApiSatatus = ApiStatus.failed;
          _apiResponse.setMessage = "Terjadi kesalahan";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Rekap Absen Harian"),
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
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ElevatedButton(
                    onPressed: () {
                      showMonthPicker(
                        headerColor: AppColor.biru2,
                        selectedMonthBackgroundColor: AppColor.biru,
                        unselectedMonthTextColor: AppColor.biru,
                        context: context,
                        firstDate: DateTime(2022),
                        lastDate: DateTime.now(),
                        initialDate: _filterDate,
                      ).then((date) {
                        if (date != null) {
                          _filterDate = date;
                          getRekapAbsen();
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(MdiIcons.calendar, color: Colors.white, size: 16),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            parseDateInd(_filterDate.toString(), "MMMM yyyy"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                  color: Colors.black54,
                ),
                Expanded(
                  child: SmartRefresher(
                    controller: _refreshC,
                    physics: const BouncingScrollPhysics(),
                    onRefresh: getRekapAbsen,
                    child: Builder(
                      builder: (context) {
                        if (_apiResponse.getApiStatus == ApiStatus.success) {
                          return ListView.builder(
                            itemCount: _listRekapAbsen.length,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 12),
                            itemBuilder: (context, index) {
                              Map absen = _listRekapAbsen[index];
                              return Card(
                                color: Colors.white,
                                elevation: 2,
                                margin: const EdgeInsets.only(left: 16, right: 16, top: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    if ((absen['item_absen'] as List).isEmpty) {
                                      showToast("Detail absen tidak tersedia");
                                    } else {
                                      AppNavigator.instance.push(
                                        MaterialPageRoute(
                                          builder: (context) => PageDetailAbsen(tglAbsen: absen['tgl_absen'].toString()),
                                        ),
                                      );
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: AppColor.hitam.withAlpha(200),
                                        ),
                                        child: Text(
                                          parseDateInd(absen['tgl_absen'].toString(), "EEEE, dd MMMM yyyy"),
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: (absen['item_absen'] as List).isEmpty
                                            ? Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    absen['ket_status_absen'].toString(),
                                                    style: GoogleFonts.montserrat(
                                                      color: Colors.black54,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Column(
                                                children: (absen['item_absen'] as List).map((e) => childItemAbsenHarian(e)).toList(),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else if (_apiResponse.getApiStatus == ApiStatus.loading) {
                          return loadingWidget();
                        } else {
                          return emptyWidget(_apiResponse.getMessage);
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column childItemAbsenHarian(Map<String, dynamic> detail) {
    Color colorIcon(String statusAbsen) {
      switch (statusAbsen) {
        case "1":
          return Colors.green;
        case "2":
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    String iconStatus(String statusAbsen) {
      switch (statusAbsen) {
        case "1":
          return AppImages.masukIcon;
        case "2":
          return AppImages.pulangIcon;
        default:
          return AppImages.logoGold;
      }
    }

    return Column(
      children: [
        Visibility(
          visible: detail['status_absen'].toString() == "2",
          child: const Divider(),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  FxText.bodySmall(
                    detail['status_absen'].toString() == "2" ? "Pulang" : "Masuk",
                    xMuted: true,
                    color: Colors.black,
                  ),
                  FxSpacing.height(6),
                  FxContainer.bordered(
                    padding: FxSpacing.xy(6, 4),
                    border: Border.all(color: colorIcon(detail['status_absen'].toString())),
                    borderRadiusAll: 5,
                    color: colorIcon(detail['status_absen'].toString()).withAlpha(50),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          iconStatus(detail['status_absen'].toString()),
                          width: 16,
                          height: 16,
                        ),
                        FxSpacing.width(6),
                        Expanded(
                          child: Text(
                            detail['jam_absen'].toString(),
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  FxText.bodySmall(
                    "Lokasi",
                    xMuted: true,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 6),
                  FxContainer.bordered(
                    padding: FxSpacing.xy(6, 4),
                    border: Border.all(color: Colors.grey),
                    borderRadiusAll: 5,
                    color: Colors.grey.withAlpha(50),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          MdiIcons.store,
                          size: 16,
                          color: AppColor.biru,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            detail['nama_lokasi'].toString(),
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
