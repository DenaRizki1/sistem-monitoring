import 'dart:developer';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/api_response.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/modules/tryout_jasmani/page_list_absen_jasmani.dart';
import 'package:absentip/modules/tryout_jasmani/page_tryout_jasmani_foto.dart';
import 'package:absentip/modules/tryout_jasmani/page_tryout_jasmani_scan.dart';
import 'package:absentip/modules/tryout_jasmani/page_tryout_jasmani_siswa.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/alert_dialog_ok_widget.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:absentip/wigets/label_form.dart';
import 'package:absentip/wigets/show_image_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageTryoutJasmaniDetail extends StatefulWidget {
  final String kdTryout;

  const PageTryoutJasmaniDetail({Key? key, required this.kdTryout}) : super(key: key);

  @override
  State<PageTryoutJasmaniDetail> createState() => _PageTryoutJasmaniDetailState();
}

class _PageTryoutJasmaniDetailState extends State<PageTryoutJasmaniDetail> {
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
      url: EndPoint.tryoutDetailJasmani,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH) ?? "",
        'hash_user': pref.getString(HASH_USER) ?? "",
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
      appBar: appBarWidget("Tryout Jasmani"),
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
                  Map kegiatan = _apiResponse.getData;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          Card(
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
                                  itemDetail(true, "Jadwal", kegiatan['nama_tryout'].toString()),
                                  itemDetail(false, "Mulai", parseDateInd(kegiatan['waktu_mulai'].toString(), "dd MMM yyyy | HH:mm") + " WIB"),
                                  itemDetail(true, "Selesai", parseDateInd(kegiatan['waktu_selesai'].toString(), "dd MMM yyyy | HH:mm") + " WIB"),
                                  itemDetail(false, "Nama Pendidikan", kegiatan['nama_pendidikan'].toString()),
                                  itemDetail(true, "Jumlah kegiatan", kegiatan['list_lokasi'].length.toString() + " Kegiatan"),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        log(kegiatan['qr_absen'].toString());
                                        AppNavigator.instance.push(
                                          MaterialPageRoute(
                                            builder: (context) => ShowImagePage(
                                              judul: "QR Absen",
                                              url: kegiatan['qr_absen'].toString(),
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Lihat QR Absen'),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        AppNavigator.instance.push(
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return const PageListAbsenJasmani();
                                            },
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: const Text('Lihat Absen Siswa'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: kegiatan['list_lokasi'].length,
                            itemBuilder: (context, index) {
                              Map itemKegiatan = kegiatan['list_lokasi'][index];
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
                                          Text(
                                            itemKegiatan['kegiatan_jasmani'].toString().toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 1),
                                      const SizedBox(height: 8),
                                      itemDetail(false, "Mulai", parseDateInd(itemKegiatan['waktu_mulai'].toString(), "dd MMM yyyy | HH:mm") + " WIB"),
                                      itemDetail(true, "Selesai", parseDateInd(itemKegiatan['waktu_selesai'].toString(), "dd MMM yyyy | HH:mm") + " WIB"),
                                      itemDetail(false, "Lokasi", itemKegiatan['nama_lokasi'].toString()),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            String lat = itemKegiatan['latitude'].toString();
                                            String lng = itemKegiatan['longitude'].toString();
                                            final availableMaps = await MapLauncher.installedMaps;
                                            if (availableMaps.isEmpty) {
                                              openUrl("'https://www.google.com/maps/search/?api=1&query=$lat,$lng'");
                                            } else {
                                              await availableMaps.first.showMarker(
                                                coords: Coords(safetyParseDouble(lat), safetyParseDouble(lng)),
                                                title: itemKegiatan['nama_lokasi'].toString(),
                                              );
                                            }
                                          },
                                          child: const Text('Lihat Lokasi Map'),
                                        ),
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            AppNavigator.instance.push(
                                              MaterialPageRoute(
                                                builder: (context) => PageTryoutJasmaniSiswa(
                                                  kdTryout: itemKegiatan['kd_tryout'].toString(),
                                                  kdLokasiAbsen: itemKegiatan['kd_lokasi_absen'].toString(),
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text('Daftar Siswa'),
                                        ),
                                      ),
                                      Visibility(
                                        visible: itemKegiatan['visible_absen'] ?? false,
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom().copyWith(
                                              backgroundColor: const MaterialStatePropertyAll(Colors.green),
                                            ),
                                            onPressed: () async {
                                              if (itemKegiatan['enable_absen'] ?? false) {
                                                pilihMetodeAbsen(itemKegiatan);
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialogOkWidget(message: itemKegiatan['text_status_absen'].toString()),
                                                );
                                              }
                                            },
                                            child: Text(itemKegiatan['text_absen'].toString()),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Builder(builder: (context) {
                                        Map? absenMasuk = itemKegiatan['absen_masuk'];
                                        Map? absenPulang = itemKegiatan['absen_pulang'];

                                        if (absenMasuk != null && absenPulang != null) {
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: ExpansionTile(
                                              collapsedBackgroundColor: Colors.grey.shade300,
                                              backgroundColor: Colors.grey.shade300,
                                              collapsedIconColor: Colors.blue,
                                              iconColor: Colors.blue,
                                              title: const Text(
                                                'Detail Absen',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              children: [
                                                detailAbsen(absenMasuk),
                                                detailAbsen(absenPulang),
                                              ],
                                            ),
                                          );
                                        } else if (absenMasuk != null) {
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: ExpansionTile(
                                              collapsedBackgroundColor: Colors.grey.shade300,
                                              backgroundColor: Colors.grey.shade300,
                                              collapsedIconColor: Colors.blue,
                                              iconColor: Colors.blue,
                                              title: const Text(
                                                'Detail Absen',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              children: [
                                                detailAbsen(absenMasuk),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      })
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
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

  void pilihMetodeAbsen(Map dataTryout) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pilih Metode Absen",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              ListTile(
                leading: Icon(MdiIcons.cameraEnhanceOutline),
                title: const Text("Foto Selfie"),
                onTap: () async {
                  AppNavigator.instance.pop();
                  AppNavigator.instance
                      .push(MaterialPageRoute(
                        builder: (context) => PageTryoutJasmaniFoto(tryout: dataTryout),
                      ))
                      .then(
                        (value) => getKegiatan(),
                      );
                },
              ),
              ListTile(
                leading: Icon(MdiIcons.qrcode),
                title: const Text("QR Code"),
                onTap: () async {
                  AppNavigator.instance.pop();
                  AppNavigator.instance
                      .push(MaterialPageRoute(
                        builder: (context) => PageTryoutJasmaniScan(tryout: dataTryout),
                      ))
                      .then(
                        (value) => getKegiatan(),
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget detailAbsen(Map absen) {
    return Card(
      margin: const EdgeInsets.only(top: 12, left: 0, right: 0),
      color: Colors.grey.shade300,
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
              ],
            )
          ],
        ),
      ),
    );
  }
}
