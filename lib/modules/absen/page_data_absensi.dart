import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/api_response.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/modules/absen/page_rekap_absen_harian.dart';
import 'package:absentip/modules/absen/page_rekap_cuti.dart';
import 'package:absentip/modules/absen/page_rekap_izin.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:month_picker_dialog_2/month_picker_dialog_2.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageDataAbsensi extends StatefulWidget {
  const PageDataAbsensi({Key? key}) : super(key: key);

  @override
  State<PageDataAbsensi> createState() => _PageDataAbsensiState();
}

class _PageDataAbsensiState extends State<PageDataAbsensi> {
  final _refreshC = RefreshController();
  final _apiResponse = ApiResponse();
  DateTime _selectedDate = DateTime.now();
  Map _rekap = {};

  @override
  void initState() {
    getRecap();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    super.initState();
  }

  @override
  void dispose() {
    _refreshC.dispose();
    super.dispose();
  }

  Future<void> getRecap() async {
    setState(() {
      _apiResponse.setApiSatatus = ApiStatus.loading;
    });

    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.rekapAbsen,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH)?.toString() ?? "",
        'hash_user': pref.getString(HASH_USER)?.toString() ?? "",
        'tahun': _selectedDate.year.toString(),
        'bulan': _selectedDate.month.toString(),
      },
    );

    if (_refreshC.isRefresh) {
      _refreshC.refreshCompleted();
    }

    if (response != null) {
      if (response['success']) {
        if (mounted) {
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _apiResponse.setApiSatatus = ApiStatus.success;
              _rekap = response['data'];
            });
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
      appBar: appBarWidget("Rekap Absen"),
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
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.biru2,
                  AppColor.biru2.withOpacity(0.6),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SmartRefresher(
            controller: _refreshC,
            onRefresh: getRecap,
            physics: const BouncingScrollPhysics(),
            child: Builder(builder: (context) {
              if (_apiResponse.getApiStatus == ApiStatus.success) {
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Card(
                      elevation: 3,
                      color: Colors.white,
                      margin: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Rekap Absen',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () {
                                      showMonthPicker(
                                        context: context,
                                        firstDate: DateTime(DateTime.now().year - 1, DateTime.now().month),
                                        lastDate: DateTime(DateTime.now().year, DateTime.now().month),
                                        initialDate: _selectedDate,
                                      ).then((date) {
                                        if (date != null) {
                                          _selectedDate = date;
                                          getRecap();
                                        }
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: AppColor.biru,
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: FxText.bodyMedium(
                                              parseDateInd(_selectedDate.toString(), "MMM yyyy"),
                                              color: Colors.white,
                                              fontWeight: 600,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_drop_down_sharp,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Divider(color: Colors.grey.shade400, height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: itemRekap(
                                    "Hadir",
                                    "${safetyParseInt(_rekap['hadir']['hari'].toString())} Hari",
                                    _rekap['hadir']['progress'].toString(),
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                  child: VerticalDivider(color: Colors.grey.shade400, width: 24),
                                ),
                                Expanded(
                                  child: itemRekap(
                                    "Alpa",
                                    "${safetyParseInt(_rekap['alpa']['hari'].toString())} Hari",
                                    _rekap['alpa']['progress'].toString(),
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: Colors.grey.shade400, height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: itemRekap(
                                    "Sakit",
                                    "${safetyParseInt(_rekap['sakit']['hari'].toString())} Hari",
                                    _rekap['sakit']['progress'].toString(),
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                  child: VerticalDivider(color: Colors.grey.shade400, width: 24),
                                ),
                                Expanded(
                                  child: itemRekap(
                                    "Izin",
                                    "${safetyParseInt(_rekap['izin']['hari'].toString())} Hari",
                                    _rekap['izin']['progress'].toString(),
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                  child: VerticalDivider(color: Colors.grey.shade400, width: 24),
                                ),
                                Expanded(
                                  child: itemRekap(
                                    "Cuti",
                                    "${safetyParseInt(_rekap['cuti']['hari'].toString())} Hari",
                                    _rekap['cuti']['progress'].toString(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    itemAbsen(MdiIcons.calendarCheck, "Data Absensi", () {
                      AppNavigator.instance.push(MaterialPageRoute(
                        builder: (context) => const PageRekapAbsenHarian(),
                      ));
                    }),
                    const SizedBox(height: 10),
                    itemAbsen(MdiIcons.calendarPlus, "Permintaan Izin", () {
                      AppNavigator.instance.push(MaterialPageRoute(
                        builder: (context) => const PageRekapIzin(),
                      ));
                    }),
                    const SizedBox(height: 10),
                    itemAbsen(MdiIcons.calendarRemove, "Permintaan Cuti", () {
                      AppNavigator.instance.push(MaterialPageRoute(
                        builder: (context) => const PageRekapCuti(),
                      ));
                    }),
                  ],
                );
              } else if (_apiResponse.getApiStatus == ApiStatus.loading) {
                return loadingWidget();
              } else {
                return emptyWidget(_apiResponse.getMessage);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget itemAbsen(IconData iconData, String title, Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.all(0),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(iconData, size: 30, color: AppColor.biru),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(MdiIcons.chevronRight, size: 24, color: AppColor.biru),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemRekap(String title, String value, String progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.black54,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: LinearPercentIndicator(
              backgroundColor: Colors.grey,
              progressColor: AppColor.biru2,
              animation: true,
              percent: safetyParseDouble(progress),
              lineHeight: 10,
              padding: EdgeInsets.zero,
            ),
          ),
        )
      ],
    );
  }
}
