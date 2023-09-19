import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/api_response.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/modules/tryout_jasmani/page_tryout_jasmani_foto.dart';
import 'package:absentip/modules/tryout_jasmani/page_tryout_jasmani_scan.dart';
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

class PageTryoutAkademikDetail extends StatefulWidget {
  final String kdTryout;

  const PageTryoutAkademikDetail({Key? key, required this.kdTryout}) : super(key: key);

  @override
  State<PageTryoutAkademikDetail> createState() => _PageTryoutAkademikDetailState();
}

class _PageTryoutAkademikDetailState extends State<PageTryoutAkademikDetail> {
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
      appBar: appBarWidget("Detail Kegiatan"),
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
                                  itemDetail(true, "Jadwal", kegiatan['nama_jadwal'].toString()),
                                  itemDetail(false, "Tanggal", parseDateInd(kegiatan['tgl_pegawai_jadwal'].toString(), "dd MMMM yyyy")),
                                  itemDetail(true, "Jam Masuk", parseDateInd(kegiatan['jam_masuk'].toString(), "HH:mm") + " WIB"),
                                  itemDetail(false, "Jam Pulang", parseDateInd(kegiatan['jam_pulang'].toString(), "HH:mm") + " WIB"),
                                  itemDetail(true, "Lokasi", kegiatan['nama_lokasi'].toString()),
                                  itemDetail(false, "Deskripsi Lokasi", kegiatan['deskripsi_lokasi'].toString()),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        String lat = kegiatan['latitude'].toString();
                                        String lng = kegiatan['longitude'].toString();
                                        final availableMaps = await MapLauncher.installedMaps;
                                        if (availableMaps.isEmpty) {
                                          openUrl("'https://www.google.com/maps/search/?api=1&query=$lat,$lng'");
                                        } else {
                                          await availableMaps.first.showMarker(
                                            coords: Coords(safetyParseDouble(lat), safetyParseDouble(lng)),
                                            title: kegiatan['nama_lokasi'].toString(),
                                          );
                                        }
                                      },
                                      child: const Text('Lihat Lokasi Map'),
                                    ),
                                  ),
                                  Visibility(
                                    visible: kegiatan['visible_absen'] ?? false,
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom().copyWith(
                                          backgroundColor: const MaterialStatePropertyAll(Colors.green),
                                        ),
                                        onPressed: () async {
                                          if (kegiatan['enable_absen'] ?? false) {
                                            pilihMetodeAbsen(kegiatan);
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialogOkWidget(message: kegiatan['text_status_absen'].toString()),
                                            );
                                          }
                                        },
                                        child: Text(kegiatan['text_absen'].toString()),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Builder(builder: (context) {
                            Map? absenMasuk = kegiatan['absen_masuk'];
                            Map? absenPulang = kegiatan['absen_pulang'];

                            if (absenMasuk != null && absenPulang != null) {
                              return Column(
                                children: [
                                  detailAbsen(absenMasuk),
                                  detailAbsen(absenPulang),
                                ],
                              );
                            } else if (absenMasuk != null) {
                              return detailAbsen(absenMasuk);
                            } else {
                              return const SizedBox.shrink();
                            }
                          })
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
                itemDetail(true, "Waktu Absen", parseDateInd(absen['tgl_absen'].toString() + " " + absen['jam_absen'].toString(), "dd MMM yyyy | HH:mm")),
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
