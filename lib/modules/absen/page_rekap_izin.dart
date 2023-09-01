import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/api_response.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/modules/absen/page_detail_izin.dart';
import 'package:absentip/utils/my_colors.dart';
import 'package:absentip/utils/app_color.dart';
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

class PageRekapIzin extends StatefulWidget {
  const PageRekapIzin({Key? key}) : super(key: key);

  @override
  State<PageRekapIzin> createState() => _PageRekapIzinState();
}

class _PageRekapIzinState extends State<PageRekapIzin> {
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
      url: EndPoint.absenIzin,
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
      appBar: appBarWidget("Permintaan Izin"),
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
                                    AppNavigator.instance.push(
                                      MaterialPageRoute(
                                        builder: (context) => PageDetailIzin(dataAbsen: absen),
                                      ),
                                    );
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
                                          parseDateInd(absen['tgl_izin'].toString(), "EEEE, dd MMMM yyyy"),
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
                                        child: itemAbsen(absen),
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

  Column itemAbsen(Map detail) {
    Color colorIcon(String statusAbsen) {
      switch (statusAbsen) {
        case "1":
          return Colors.green;
        case "2":
          return Colors.red;
        default:
          return Colors.orange;
      }
    }

    Color colorKeteranganAbsen(String statusAbsen) {
      switch (statusAbsen) {
        case "1":
          return Colors.green;
        case "2":
          return Colors.red;
        default:
          return Colors.orange;
      }
    }

    return Column(
      children: [
        Container(
          margin: FxSpacing.x(16),
          child: Row(
            children: [
              Row(
                children: [
                  Container(
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(4),
                        bottomLeft: const Radius.circular(4),
                        topRight: detail['jenis_izin'].toString() == "1" ? const Radius.circular(0) : const Radius.circular(4),
                        bottomRight: detail['jenis_izin'].toString() == "1" ? const Radius.circular(0) : const Radius.circular(4),
                      ),
                      border: Border.all(color: Colors.orange),
                      color: detail['jenis_izin'].toString() == "1" ? colorKeteranganAbsen(detail['status_verifikasi'].toString()).withAlpha(50) : Colors.orange.withAlpha(50),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 16,
                          color: colorIcon(detail['jenis_izin'].toString()),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          detail['ket_jenis_izin'].toString(),
                          style: TextStyle(
                            fontFamily: GoogleFonts.zcoolQingKeHuangYou().fontFamily,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: const Color(0xFFf7f7f7),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    FxText.bodySmall(
                      detail['ket_status_verifikasi'].toString(),
                      fontWeight: 700,
                      color: Colors.black87,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
