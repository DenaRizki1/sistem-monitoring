import 'dart:async';
import 'dart:developer';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/modules/absen/page_absen_foto.dart';
import 'package:absentip/modules/absen/page_absen_scan.dart';
import 'package:absentip/modules/absen/page_pemintaan_cuti.dart';
import 'package:absentip/modules/absen/page_permintaan_izin.dart';
import 'package:absentip/modules/absen/page_rekap_absen_harian.dart';
import 'package:absentip/modules/absen/page_rekap_cuti.dart';
import 'package:absentip/modules/absen/page_rekap_izin.dart';
import 'package:absentip/utils/my_colors.dart';
import 'package:absentip/services/location_service.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/utils/sessions.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:timer_builder/timer_builder.dart';

class PageAbsen extends StatefulWidget {
  const PageAbsen({Key? key}) : super(key: key);

  @override
  State<PageAbsen> createState() => _PageAbsenState();
}

class _PageAbsenState extends State<PageAbsen> {
  final _refreshC = RefreshController();
  double latitude = 0.0, longitude = 0.0;
  String _address = "";
  String lokasiAbsen = "";
  Position? _currentLocation;
  Map _cekAbsen = {};

  @override
  void dispose() {
    _refreshC.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    cekAbsen("1");
    getCurrentLocation();
  }

  Future<void> cekAbsen(String jenisAbsen) async {
    showLoading(dismissOnTap: false);

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.cekAbsen,
      params: {
        'token_auth': await getPrefrence(TOKEN_AUTH) ?? "",
        'hash_user': await getPrefrence(HASH_USER) ?? "",
        'jenis_absen': jenisAbsen,
      },
    );

    dismissLoading();

    if (response != null) {
      if (response['success'] == true) {
        if (mounted) {
          setState(() {
            _cekAbsen = response['data'];
          });
        }

        if (_cekAbsen['text_jenis_absen'].toString().isNotEmpty) {
          showToast(_cekAbsen['text_jenis_absen'].toString());
        }
      } else {
        showToast(response['message'].toString());
      }
    } else {
      showToast("Terjadi kesalahan");
    }

    if (_refreshC.isRefresh) {
      _refreshC.refreshCompleted();
    }
  }

  Future<void> getCurrentLocation() async {
    _address = "";
    _currentLocation = null;
    _currentLocation = await LocationService.instance.getCurrentLocation(context);

    if (_currentLocation != null) {
      latitude = _currentLocation!.latitude;
      longitude = _currentLocation!.longitude;
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        localeIdentifier: "id_ID",
      );
      if (placemarks.isNotEmpty) {
        Placemark placeMark = placemarks[0];
        if (mounted) {
          setState(() {
            _address =
                "${placeMark.street}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.subAdministrativeArea}, ${placeMark.administrativeArea}, ${placeMark.country}, ${placeMark.postalCode}";
            log(_address);
          });
        }
      } else {
        _address = "Lokasi tidak ditemukan";
      }
    } else {
      _address = "Koordinat tidak ditemukan";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
        controller: _refreshC,
        onRefresh: () async {
          getCurrentLocation();
          cekAbsen("1");
        },
        child: ListView(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 32),
                  decoration: BoxDecoration(
                    image: const DecorationImage(image: AssetImage(AppImages.bg2), fit: BoxFit.fill),
                    color: colorPrimary,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Image.asset(
                            AppImages.bgAbsen,
                            scale: 2,
                            height: 180,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              contentPadding: const EdgeInsets.all(8),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      AppNavigator.instance.pop();
                                      AppNavigator.instance.push(
                                        MaterialPageRoute(
                                          builder: (context) => const PageRekapAbsenHarian(),
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      leading: Icon(MdiIcons.calendarCheck),
                                      title: const Text("Absen Harian"),
                                    ),
                                  ),
                                  const Divider(),
                                  InkWell(
                                    onTap: () {
                                      AppNavigator.instance.pop();
                                      AppNavigator.instance.push(
                                        MaterialPageRoute(
                                          builder: (context) => const PageRekapIzin(),
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      leading: Icon(MdiIcons.calendarPlus),
                                      title: const Text("Permintaan Izin"),
                                    ),
                                  ),
                                  const Divider(),
                                  InkWell(
                                    onTap: () {
                                      AppNavigator.instance.pop();
                                      AppNavigator.instance.push(
                                        MaterialPageRoute(
                                          builder: (context) => const PageRekapCuti(),
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      leading: Icon(MdiIcons.calendarRemove),
                                      title: const Text("Permintaan Cuti"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          margin: const EdgeInsets.only(top: 20, right: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.watch_later_outlined,
                                color: AppColor.biru2,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Riwayat Absen",
                                style: TextStyle(
                                  color: AppColor.biru2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.biru2,
                        Colors.white.withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: FxContainer(
                    padding: FxSpacing.xy(20, 8),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                    color: Colors.white,
                    child: FxContainer(
                      margin: FxSpacing.top(10),
                      padding: FxSpacing.all(8),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      color: Colors.grey.withAlpha(100),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FxText.bodySmall(
                            "Lokasi Anda: ",
                            fontWeight: 700,
                            color: Colors.black,
                          ),
                          FxSpacing.width(5),
                          Expanded(
                            child: SizedBox(
                              child: FxText.bodySmall(
                                _address.isEmpty ? "Loading..." : _address,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.black.withOpacity(0.7),
                                xMuted: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Visibility(
                        visible: _cekAbsen['informasi'].toString().isNotEmpty && _cekAbsen['informasi'].toString().toLowerCase() != "null",
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colorInfo,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              _cekAbsen['informasi'].toString(),
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Pilih Jenis Absen",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: colorPrimary,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () async {
                                await cekAbsen("1");
                              },
                              child: (_cekAbsen['jenis_absen']?.toString() ?? "1") == "1" ? selectedAbsen("Dalam Kelas") : unselectedAbsen("Dalam Kelas"),
                            ),
                            InkWell(
                              onTap: () async {
                                await cekAbsen("2");
                              },
                              child: (_cekAbsen['jenis_absen']?.toString() ?? "1") == "2" ? selectedAbsen("Luar Kelas") : unselectedAbsen("Luar Kelas"),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          parseDateInd(DateTime.now().toString(), "EEEE, dd MMMM yyyy "),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Center(
                        child: TimerBuilder.periodic(const Duration(seconds: 1), builder: (context) {
                          return Text(
                            parseDateInd(DateTime.now().toString(), "HH:mm:ss"),
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 30,
                              fontWeight: FontWeight.normal,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      MaterialButton(
                        onPressed: () {
                          if (_cekAbsen['enable_btn'] ?? false) {
                            if (_address.isNotEmpty) {
                              _cekAbsen['lat'] = latitude.toString();
                              _cekAbsen['lng'] = longitude.toString();
                              _cekAbsen['lokasi'] = _address;
                              showPilihanAbsen(context);
                            } else {
                              showToast("Lokasi Anda Belum Ditemukan");
                            }
                          } else {
                            switch (_cekAbsen['status_absen'].toString()) {
                              case "1":
                                showToast(_cekAbsen['text_absen_masuk'].toString());
                                break;
                              case "2":
                                showToast(_cekAbsen['text_absen_pulang'].toString());
                                break;
                              default:
                                showToast(_cekAbsen['informasi'].toString());
                            }
                          }
                        },
                        color: _cekAbsen['enable_btn'] ?? false ? Colors.green.withAlpha(140) : Colors.grey.withAlpha(100),
                        shape: CircleBorder(
                          side: BorderSide(
                            color: _cekAbsen['enable_btn'] ?? false ? Colors.green : Colors.grey,
                            width: 10,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(60),
                          child: Text(
                            _cekAbsen['text_btn']?.toString() ?? "Absen Masuk",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  if (_cekAbsen['enable_izin'] ?? false) {
                                    if (_address.isNotEmpty) {
                                      _cekAbsen['lat'] = latitude.toString();
                                      _cekAbsen['lng'] = longitude.toString();
                                      _cekAbsen['lokasi'] = _address;
                                      Navigator.of(context)
                                          .push(
                                            MaterialPageRoute(
                                              builder: (context) => PagePermintaanIzin(cekAbsen: _cekAbsen),
                                            ),
                                          )
                                          .then((value) => cekAbsen("1"));
                                    } else {
                                      showToast("Lokasi Anda Belum Ditemukan");
                                    }
                                  } else {
                                    showToast(_cekAbsen['text_izin'].toString());
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: colorPrimary,
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  side: BorderSide(
                                    width: 2.0,
                                    color: colorPrimary,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Text(
                                  "Permintaan Izin",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: colorPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  if (_cekAbsen['enable_cuti'] ?? false) {
                                    if (_address.isNotEmpty) {
                                      _cekAbsen['lat'] = latitude.toString();
                                      _cekAbsen['lng'] = longitude.toString();
                                      _cekAbsen['lokasi'] = _address;
                                      Navigator.of(context)
                                          .push(
                                            MaterialPageRoute(
                                              builder: (context) => PagePermintaanCuti(cekAbsen: _cekAbsen),
                                            ),
                                          )
                                          .then((value) => cekAbsen("1"));
                                    } else {
                                      showToast("Lokasi Anda Belum Ditemukan");
                                    }
                                  } else {
                                    showToast(_cekAbsen['text_cuti'].toString());
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: colorPrimary,
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  side: BorderSide(
                                    width: 2,
                                    color: colorPrimary,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Text(
                                  "Permintaan Cuti",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: colorPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> showPilihanAbsen(BuildContext context) {
    return showBarModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Scan QR Code'),
            leading: const Icon(Icons.qr_code),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => PageAbsenScan(cekAbsen: _cekAbsen),
                    ),
                  )
                  .then((value) => cekAbsen("1"));
            },
          ),
          ListTile(
            title: const Text('Ambil Foto'),
            leading: const Icon(Icons.camera_alt_outlined),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => PageAbsenFoto(cekAbsen: _cekAbsen),
                    ),
                  )
                  .then((value) => cekAbsen("1"));
            },
          ),
        ],
      ),
    );
  }

  Widget unselectedAbsen(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorPrimary,
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
      ),
    );
  }

  Widget selectedAbsen(String title) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: colorPrimary,
            ),
            padding: const EdgeInsets.all(2),
            child: Icon(
              MdiIcons.check,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
