import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/api_response.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/modules/kegiatan/page_kegiatan_foto.dart';
import 'package:absentip/modules/kegiatan/page_kegiatan_scan.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:absentip/wigets/label_form.dart';
import 'package:absentip/wigets/show_image_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageKegiatanDetail extends StatefulWidget {
  final String kdTryout;
  final String jenisKegiatan;

  const PageKegiatanDetail({Key? key, required this.jenisKegiatan, required this.kdTryout}) : super(key: key);

  @override
  State<PageKegiatanDetail> createState() => _PageKegiatanDetailState();
}

class _PageKegiatanDetailState extends State<PageKegiatanDetail> {
  final _refreshC = RefreshController();
  final _apiResponse = ApiResponse();
  Map _tryout = {};
  String _jenisKegiatan = "";
  String _kdTryout = "";

  @override
  void initState() {
    _jenisKegiatan = widget.jenisKegiatan;
    _kdTryout = widget.kdTryout;
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
      url: EndPoint.kegiatanDetail,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH) ?? "",
        'hash_user': pref.getString(HASH_USER) ?? "",
        'jenis_kegiatan': _jenisKegiatan,
        'kd_tryout': _kdTryout,
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
            _tryout = response['data'];
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

  Future<Map?> cekKegiatan() async {
    showLoading();

    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.cekKegiatan,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH) ?? "",
        'hash_user': pref.getString(HASH_USER) ?? "",
        'jenis_kegiatan': _jenisKegiatan,
        'kd_tryout': _kdTryout,
      },
    );

    dismissLoading();

    if (response != null) {
      if (response['success']) {
        return response['data'];
      } else {
        return null;
      }
    }
    return null;
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
          SmartRefresher(
            controller: _refreshC,
            onRefresh: getKegiatan,
            child: Builder(
              builder: (context) {
                if (_apiResponse.getApiStatus == ApiStatus.success) {
                  return ListView(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 12, right: 16, left: 16),
                    children: [
                      detailTryout(),
                      detailAbsen(),
                    ],
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

  Widget detailAbsen() {
    return Card(
      margin: const EdgeInsets.only(top: 12),
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
                const Text(
                  "Absensi",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(color: AppColor.hitam, height: 1),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                if (_tryout['absen'] == null) {
                  if (_tryout['status_absen'].toString() == "selesai") {
                    return SizedBox(
                      height: 100,
                      child: emptyWidget("Anda tidak melakukan absen"),
                    );
                  } else if (_tryout['status_absen'].toString() == "proses") {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 6),
                      child: ElevatedButton(
                        onPressed: () {
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
                                        Map? dataTryout = await cekKegiatan();
                                        if (dataTryout != null) {
                                          if (dataTryout['status_absen'].toString() == "proses") {
                                            dataTryout['jenis_kegiatan'] = _jenisKegiatan;
                                            AppNavigator.instance
                                                .push(MaterialPageRoute(
                                                  builder: (context) => PageKegiatanFoto(tryout: dataTryout),
                                                ))
                                                .then((value) => getKegiatan());
                                          } else if (dataTryout['status_absen'].toString() == "sudah_absen") {
                                            showToast("Anda sudah absen kegiatan ini");
                                          } else if (dataTryout['status_absen'].toString() == "belum") {
                                            showToast("Tryout belum dimulai");
                                          } else {
                                            showToast("Tryout sudah selesai");
                                          }
                                        }
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(MdiIcons.qrcode),
                                      title: const Text("QR Code"),
                                      onTap: () async {
                                        AppNavigator.instance.pop();
                                        Map? dataTryout = await cekKegiatan();
                                        if (dataTryout != null) {
                                          if (dataTryout['status_absen'].toString() == "proses") {
                                            dataTryout['jenis_kegiatan'] = _jenisKegiatan;
                                            AppNavigator.instance
                                                .push(MaterialPageRoute(
                                                  builder: (context) => PageKegiatanScan(tryout: dataTryout),
                                                ))
                                                .then((value) => getKegiatan());
                                          } else if (dataTryout['status_absen'].toString() == "sudah_absen") {
                                            showToast("Anda sudah absen kegiatan ini");
                                          } else if (dataTryout['status_absen'].toString() == "belum") {
                                            showToast("Tryout belum dimulai");
                                          } else {
                                            showToast("Tryout sudah selesai");
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Absen Sekarang',
                        ),
                      ),
                    );
                  } else {
                    return SizedBox(
                      height: 100,
                      child: emptyWidget("Tryout belum dimulai"),
                    );
                  }
                } else {
                  final absen = _tryout['absen'];
                  return Column(
                    children: [
                      itemDetail(true, "Waktu Absen", parseDateInd(absen['tanggal_jam'].toString(), "dd MMM yyyy | HH:mm")),
                      itemDetail(false, "Metode Absen", absen['ket_metode'].toString()),
                      itemDetail(true, "Status Verifikasi", absen['ket_status'].toString()),
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
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget detailTryout() {
    return Card(
      margin: const EdgeInsets.only(top: 12),
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
                const Text(
                  "Tryout",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(color: AppColor.hitam, height: 1),
            const SizedBox(height: 8),
            itemDetail(true, "Waktu Mulai", parseDateInd(_tryout['waktu_mulai'].toString(), "dd MMM yyyy | HH:mm")),
            itemDetail(false, "Waktu Selesai", parseDateInd(_tryout['waktu_selesai'].toString(), "dd MMM yyyy | HH:mm")),
            itemDetail(true, "Nama Tryout", _tryout['nama_tryout'].toString()),
            itemDetail(false, "Pendidikan", _tryout['nama_pendidikan'].toString()),
            itemDetail(true, "Mata Pelajaran", _tryout['nama_matapelajaran'].toString()),
            itemDetail(false, "Jumlah Soal", _tryout['jumlah_soal'].toString()),
            itemDetail(true, "Password", _tryout['password'].toString()),
            itemDetail(false, "Status", _tryout['ket_finish'].toString()),
          ],
        ),
      ),
    );
  }

  Widget itemDetail(bool isColor, String title, String value) {
    return Container(
      color: isColor ? AppColor.biru.withAlpha(50) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
