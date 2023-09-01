// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:absentip/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/api_response.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/wigets/appbar_widget.dart';

class PageJadwalDetail extends StatefulWidget {
  final String tglJadwal;

  const PageJadwalDetail({Key? key, required this.tglJadwal}) : super(key: key);

  @override
  State<PageJadwalDetail> createState() => _PageJadwalDetailState();
}

class _PageJadwalDetailState extends State<PageJadwalDetail> {
  final _apiResponse = ApiResponse();
  final _refreshC = RefreshController();

  @override
  void initState() {
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
    });

    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.jadwalPengajarDetail,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH) ?? "",
        'hash_user': pref.getString(HASH_USER) ?? "",
        'tgl_jadwal': widget.tglJadwal,
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
            _apiResponse.setData = response['data'];
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
      appBar: appBarWidget("Jadwal Pengajar"),
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
            physics: const BouncingScrollPhysics(),
            onRefresh: getKegiatan,
            child: Builder(
              builder: (context) {
                if (_apiResponse.getApiStatus == ApiStatus.success) {
                  Map jadwal = _apiResponse.getData;
                  return Card(
                    margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                AppImages.logoGold,
                                width: 40,
                                color: AppColor.biru2,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Detail Jadwal',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          itemDetail(true, "Jadwal", jadwal['nama_jadwal'].toString()),
                          itemDetail(false, "Tanggal", parseDateInd(jadwal['tgl_pegawai_jadwal'].toString(), "dd MMMM yyyy")),
                          itemDetail(true, "Jam Masuk", parseDateInd(jadwal['jam_masuk'].toString(), "HH:mm") + " WIB"),
                          itemDetail(false, "Jam Pulang", parseDateInd(jadwal['jam_pulang'].toString(), "HH:mm") + " WIB"),
                          itemDetail(true, "Lokasi", jadwal['nama_lokasi'].toString()),
                          itemDetail(false, "Deskripsi Lokasi", jadwal['deskripsi_lokasi'].toString()),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                String lat = jadwal['latitude'].toString();
                                String lng = jadwal['longitude'].toString();
                                final availableMaps = await MapLauncher.installedMaps;
                                if (availableMaps.isEmpty) {
                                  openUrl("'https://www.google.com/maps/search/?api=1&query=$lat,$lng'");
                                } else {
                                  await availableMaps.first.showMarker(
                                    coords: Coords(safetyParseDouble(lat), safetyParseDouble(lng)),
                                    title: "Ocean Beach",
                                  );
                                }
                              },
                              child: const Text('Lihat Lokasi Map'),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                } else if (_apiResponse.getApiStatus == ApiStatus.loading) {
                  return loadingWidget();
                } else {
                  return emptyWidget(_apiResponse.getMessage);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget itemDetail(bool isColor, String title, String value) {
    return Container(
      color: isColor ? AppColor.biru.withAlpha(50) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
