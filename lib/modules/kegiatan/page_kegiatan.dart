import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/api_response.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/modules/kegiatan/page_kegiatan_detail.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:month_picker_dialog_2/month_picker_dialog_2.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageKegiatan extends StatefulWidget {
  final String jenisKegiatan;

  const PageKegiatan({Key? key, required this.jenisKegiatan}) : super(key: key);

  @override
  State<PageKegiatan> createState() => _PageKegiatanState();
}

class _PageKegiatanState extends State<PageKegiatan> {
  final _apiResponse = ApiResponse();
  final _refreshC = RefreshController();
  final _listKegiatan = [];
  DateTime? _filterDate;
  String _jenisKegiatan = "";

  @override
  void initState() {
    _jenisKegiatan = widget.jenisKegiatan;
    getKegiatan();
    super.initState();
  }

  @override
  void dispose() {
    _refreshC.dispose();
    super.dispose();
  }

  Future<void> getKegiatan() async {
    setState(() {
      _apiResponse.setApiSatatus = ApiStatus.loading;
      _listKegiatan.clear();
    });

    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.kegiatan,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH) ?? "",
        'hash_user': pref.getString(HASH_USER) ?? "",
        'jenis_kegiatan': _jenisKegiatan,
        'tahun': _filterDate == null ? "" : parseDateInd(_filterDate.toString(), "yyyy"),
        'bulan': _filterDate == null ? "" : parseDateInd(_filterDate.toString(), "MM"),
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
            _listKegiatan.addAll(response['data']);
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
      appBar: appBarWidget("Kegiatan " + _jenisKegiatan.toCapitalized()),
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
          Column(
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
                      initialDate: DateTime.now(),
                    ).then((date) {
                      if (date != null) {
                        _filterDate = date;
                        getKegiatan();
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
                          _filterDate == null ? "Semua Kegiatan" : parseDateInd(_filterDate.toString(), "MMMM yyyy"),
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
                  onRefresh: getKegiatan,
                  child: Builder(
                    builder: (context) {
                      if (_apiResponse.getApiStatus == ApiStatus.success) {
                        return ListView.builder(
                          itemCount: _listKegiatan.length,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 12),
                          itemBuilder: (context, index) {
                            Map kegiatan = _listKegiatan[index];
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
                                      builder: (context) => PageKegiatanDetail(
                                        kdTryout: kegiatan['kd_tryout'].toString(),
                                        jenisKegiatan: _jenisKegiatan,
                                      ),
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
                                        parseDateInd(kegiatan['waktu_mulai'].toString(), "dd MMM yyyy"),
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            kegiatan['nama_tryout'].toString(),
                                            style: GoogleFonts.montserrat(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "Pukul " + parseDateInd(kegiatan['waktu_mulai'].toString(), "HH:mm") + " s/d " + parseDateInd(kegiatan['waktu_selesai'].toString(), "HH:mm") + " WIB",
                                            style: GoogleFonts.montserrat(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
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
        ],
      ),
    );
  }
}
