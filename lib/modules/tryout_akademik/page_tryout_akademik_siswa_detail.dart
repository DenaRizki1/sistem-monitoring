// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:absentip/wigets/alert_dialog_confirm_widget.dart';
import 'package:absentip/wigets/alert_dialog_verif_ket_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/api_response.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:absentip/wigets/label_form.dart';
import 'package:absentip/wigets/show_image_page.dart';

class PageTryoutAkademikSiswaDetail extends StatefulWidget {
  final String hashSiswa;
  final String namaSiswa;
  final String kdTryout;

  const PageTryoutAkademikSiswaDetail({
    Key? key,
    required this.hashSiswa,
    required this.namaSiswa,
    required this.kdTryout,
  }) : super(key: key);

  @override
  State<PageTryoutAkademikSiswaDetail> createState() => _PageTryoutAkademikSiswaDetailState();
}

class _PageTryoutAkademikSiswaDetailState extends State<PageTryoutAkademikSiswaDetail> {
  final _apiResponse = ApiResponse();
  final _refreshC = RefreshController();

  @override
  void initState() {
    getAbsenSiswa();
    super.initState();
  }

  @override
  void dispose() {
    _refreshC.dispose();
    super.dispose();
  }

  Future<void> getAbsenSiswa() async {
    setState(() {
      _apiResponse.setApiSatatus = ApiStatus.loading;
    });

    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.daftarSiswaDetailAkademik,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH) ?? "",
        'hash_user': pref.getString(HASH_USER) ?? "",
        'hash_siswa': widget.hashSiswa,
        'kd_tryout': widget.kdTryout,
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
      appBar: appBarWidget(widget.namaSiswa),
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
            onRefresh: getAbsenSiswa,
            child: Builder(
              builder: (context) {
                if (_apiResponse.getApiStatus == ApiStatus.success) {
                  Map kegiatan = _apiResponse.getData;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Column(
                        children: [
                          Builder(builder: (context) {
                            if (kegiatan['absen_masuk'].toString() != "null") {
                              kegiatan['absen_masuk']['ket_status_absen'] = "Absen Masuk";
                              return _detailAbsen(kegiatan['absen_masuk']);
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                          Builder(builder: (context) {
                            if (kegiatan['absen_pulang'].toString() != "null") {
                              kegiatan['absen_pulang']['ket_status_absen'] = "Absen Pulang";
                              return _detailAbsen(kegiatan['absen_pulang']);
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
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

  Widget _detailAbsen(Map absen) {
    log(absen['ket_status_absen'].toString());
    return Card(
      margin: const EdgeInsets.only(top: 12, left: 0, right: 0),
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
                ),
                const SizedBox(width: 12),
                Text(
                  absen['ket_status_absen'].toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(color: AppColor.hitam, height: 1),
            const SizedBox(height: 8),
            Column(
              children: [
                itemDetail(true, "Waktu Absen", parseDateInd(absen['tanggal_absen'].toString() + " " + absen['jam_absen'].toString(), "dd MMM yyyy | HH:mm")),
                itemDetail(false, "Metode Absen", absen['ket_metode'].toString()),
                itemDetail(true, "Status Verifikasi", absen['ket_status_verif'].toString()),
                itemDetail(false, "Keterangan Penolakan", absen['keterangan_tolak']?.toString() ?? "-"),
                Visibility(
                  visible: absen['metode'].toString() == "2",
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 6),
                    child: ElevatedButton(
                      onPressed: () {
                        AppNavigator.instance.push(
                          MaterialPageRoute(
                            builder: (context) => ShowImagePage(
                              judul: "Foto Absen",
                              url: absen['foto_absen'].toString(),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Lihat Foto Absen',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const LabelForm(label: "Lokasi Absen"),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColor.hitam,
                  ),
                  padding: const EdgeInsets.all(1),
                  width: double.infinity,
                  height: 240,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GoogleMap(
                      scrollGesturesEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          safetyParseDouble(absen['lat'].toString()),
                          safetyParseDouble(absen['long'].toString()),
                        ),
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('1'),
                          position: LatLng(
                            safetyParseDouble(absen['lat'].toString()),
                            safetyParseDouble(absen['long'].toString()),
                          ),
                        ),
                      },
                      onMapCreated: (GoogleMapController controller) {},
                    ),
                  ),
                ),
                Visibility(
                  visible: absen['status_verif'].toString() == "1",
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom().copyWith(
                              backgroundColor: const MaterialStatePropertyAll(Colors.red),
                            ),
                            onPressed: () async {
                              final resultPenolakan = await showDialog<Map>(context: context, builder: (context) => const AlertDialogVerifKetWidget());
                              if (resultPenolakan != null) {
                                if (resultPenolakan['status']) {
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => const AlertDialogConfirmWidget(message: "Apakah anda yakin memverifikasi absen ini?"),
                                  );
                                  if (result ?? false) {
                                    verifAbsenSiswa(absen['kd_absen'].toString(), "ditolak", resultPenolakan['keterangan'].toString());
                                  }
                                }
                              }
                            },
                            child: const Text("Tolak Absen"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom().copyWith(
                              backgroundColor: const MaterialStatePropertyAll(Colors.green),
                            ),
                            onPressed: () async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => const AlertDialogConfirmWidget(message: "Apakah anda yakin memverifikasi absen ini?"),
                              );
                              if (result ?? false) {
                                verifAbsenSiswa(absen['kd_absen'].toString(), "diterima", "");
                              }
                            },
                            child: const Text("Verifikasi Absen"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> verifAbsenSiswa(String kdAbsen, String statusVerif, String keterangan) async {
    await showLoading();

    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.verifAbsenSiswaAkademik,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH) ?? "",
        'hash_user': pref.getString(HASH_USER) ?? "",
        'kd_absen': kdAbsen,
        'status_verif': statusVerif,
        'ket_verif': keterangan,
      },
    );

    dismissLoading();

    if (response != null) {
      showToast(response['message'].toString());
      if (response['success']) {
        getAbsenSiswa();
      }
    }
  }
}
