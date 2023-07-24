import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/harian/page_absen_photo.dart';
import 'package:absentip/model/absensi.dart';
import 'package:absentip/model/jadwal_absensi.dart';
import 'package:absentip/my_colors.dart';
import 'package:absentip/page_pemintaan_cuti.dart';
import 'package:absentip/page_permintaan_izin.dart';
import 'package:absentip/page_rekap_absen_harian.dart';
import 'package:absentip/services/location_service.dart';
import 'package:absentip/utils/api.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/sessions.dart';
import 'package:absentip/utils/strings.dart';
import 'package:absentip/utils/text_montserrat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutx/flutx.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_builder/timer_builder.dart';

class PageBerandaAbsenHarian extends StatefulWidget {
  const PageBerandaAbsenHarian({Key? key}) : super(key: key);

  @override
  State<PageBerandaAbsenHarian> createState() => _PageBerandaAbsenHarianState();
}

class _PageBerandaAbsenHarianState extends State<PageBerandaAbsenHarian> {
  Set<Marker> markers = {};
  bool? jadwalAbsen;
  bool loading = true;

  late bool _serviceEnabled;

  double latitude = 0.0, longitude = 0.0;
  final ImagePicker _picker = ImagePicker();
  XFile? fileFoto;
  String label = "", statusAbsen = "";
  String fileFotoPath = "";
  JadwalAbsensi jadwalAbsensi = JadwalAbsensi();
  Absensi absensiMasuk = Absensi();
  Absensi absensiPulang = Absensi();
  Timer? timer;
  String today = "";

  Position? _currentLocation;
  String _address = "";
  Map _cekAbsen = {};

  String lokasiAbsen = "";

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAbsenHarian();
    cekAbsen();
    getCurrentLocation();
    setState(() {});
    today = Helpers.getDateTimeNow(true, true, true, true, false);
  }

  int jenisA = 1;

  jenisAbsen(int value) {
    jenisA = value;
    setState(() {});
  }

  // init() async {
  //   _serviceEnabled = await location.serviceEnabled();
  //   if (!_serviceEnabled) {
  //     _serviceEnabled = await location.requestService();
  //     if (!_serviceEnabled) {
  //       return;
  //     }
  //   }

  //   _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //     if (_permissionGranted != PermissionStatus.granted) {
  //       return;
  //     }
  //   }

  //   LocationData locationData = await location.getLocation();
  //   setState(() {
  //     latitude = locationData.latitude ?? 0.0;
  //     longitude = locationData.longitude ?? 0.0;
  //     if (latitude != 0.0 && longitude != 0.0) {
  //       setState(() {
  //         markers.addAll([
  //           Marker(
  //             markerId: const MarkerId('Lokasi'),
  //             position: LatLng(latitude, longitude),
  //           ),
  //         ]);
  //       });
  //       final p = CameraPosition(target: LatLng(latitude, longitude), zoom: 14.4746);

  //       setState(() {
  //         statusTombolAbsen = true;
  //       });
  //     } else {
  //       setState(() {
  //         statusTombolAbsen = false;
  //       });
  //     }
  //   });

  // timer?.cancel();
  // timer = Timer.periodic(const Duration(seconds: 60), (timer) async {
  //   setState(() {
  //     statusTombolAbsen = false;
  //   });
  //   locationData = await location.getLocation();
  //   setState(() {
  //     log(latitude.toString());
  //     log(longitude.toString());
  //     latitude = locationData.latitude ?? 0.0;
  //     longitude = locationData.longitude ?? 0.0;
  //     if(latitude!=0.0 && longitude!=0.0) {
  //       setState(() {
  //         markers.addAll([
  //           Marker(
  //             markerId: const MarkerId('Lokasi'),
  //             position: LatLng(latitude, longitude),
  //           ),
  //         ]);
  //       });
  //       final p = CameraPosition(target: LatLng(latitude, longitude), zoom: 14.4746);
  //       c.animateCamera(CameraUpdate.newCameraPosition(p));
  //       setState(() {
  //         statusTombolAbsen = true;
  //       });
  //     } else {
  //       setState(() {
  //         statusTombolAbsen = false;
  //       });
  //     }
  //   });
  // });

  //   getAbsenHarian();
  // }

  Map<String, dynamic> data = {};

  bool btnAbsen = false, btnIzin = false, btnCuti = false;

  cekAbsen() async {
    setState(() {
      loading = true;
    });
    String tokenAuth = "", hashUser = "";

    tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
    hashUser = (await getPrefrence(HASH_USER))!;

    var param = {
      'token_auth': tokenAuth,
      'hash_user': hashUser,
      'jenis_absen': jenisA.toString(),
    };

    log(param.toString());

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.urlCekAbsen,
      params: param,
    );

    Map<String, dynamic> responseBody = response!;

    data = responseBody['data'];

    log(responseBody['data'].toString());

    if (responseBody['success'] == true) {
      if (responseBody['data'] != null) {
        btnAbsen = responseBody['data']['enable_btn'];
        btnIzin = responseBody['data']['enable_izin'];
        btnCuti = responseBody['data']['enable_cuti'];
        setState(() {
          loading = false;
        });
      }
    } else {
      showToast(responseBody['message'].toString());
    }
  }

  Future<void> getCurrentLocation() async {
    _address = "";
    _currentLocation = null;
    _currentLocation = await LocationService.instance.getCurrentLocation(context);

    if (_currentLocation != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentLocation?.latitude ?? 0.0,
        _currentLocation?.longitude ?? 0.0,
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

  Future _onRefresh() async {
    getAbsenHarian();
    getCurrentLocation();
    cekAbsen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: !loading
            ? RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  children: [
                    Stack(
                      children: [
                        Container(
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
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const PageRekapAbsenHarian(),
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
                                    children: const [
                                      Icon(
                                        Icons.watch_later_outlined,
                                        color: Color.fromRGBO(26, 176, 229, 1),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Riwayat Absen",
                                        style: TextStyle(
                                          color: Color.fromRGBO(26, 176, 229, 1),
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
                                const Color(0xffc18e28),
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
                        const SizedBox(height: 10),
                        data['informasi'].toString() == ""
                            ? Container()
                            : Container(
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: colorInfo,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: TextMontserrat(
                                    text: data['informasi'].toString(),
                                    fontSize: 14,
                                    bold: true,
                                    color: Colors.red,
                                    textAlign: TextAlign.center,
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
                                onTap: () {
                                  jenisAbsen(1);
                                },
                                child: jenisA == 1 ? selectedAbsen("Dalam Kelas") : unselectedAbsen("Dalam Kelas"),
                              ),
                              InkWell(
                                onTap: () {
                                  jenisAbsen(2);
                                },
                                child: jenisA == 2 ? selectedAbsen("Luar Kelas") : unselectedAbsen("Luar Kelas"),
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
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // DigitalClock(
                        //   digitAnimationStyle: Curves.elasticOut,
                        //   is24HourTimeFormat: true,
                        //   areaDecoration: const BoxDecoration(
                        //     color: Colors.transparent,
                        //   ),
                        //   hourMinuteDigitTextStyle: const TextStyle(
                        //     color: Colors.blueGrey,
                        //     fontSize: 40,
                        //   ),
                        //   secondDigitTextStyle: const TextStyle(
                        //     color: Colors.blueGrey,
                        //     fontSize: 20,
                        //   ),
                        // ),
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
                          onPressed: btnAbsen
                              ? () {
                                  showBarModalBottomSheet(
                                    context: context,
                                    builder: (context) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          title: const Text('Scan QR Code'),
                                          leading: const Icon(Icons.qr_code),
                                          onTap: () {
                                            Navigator.of(context).pop();

                                            // Navigator.push(context, MaterialPageRoute(builder: (context) => const PageAbsenScanQr()));
                                            showDialog<void>(
                                              context: context,
                                              barrierDismissible: false, // user must tap button!
                                              builder: (BuildContext context) {
                                                return Container(
                                                  height: MediaQuery.of(context).size.height,
                                                  width: MediaQuery.of(context).size.width,
                                                  color: Colors.white,
                                                  child: Column(
                                                    children: [
                                                      Expanded(
                                                        child: MobileScanner(
                                                          controller: MobileScannerController(
                                                            facing: CameraFacing.back,
                                                          ),
                                                          allowDuplicates: false,
                                                          onDetect: (barcode, args) {
                                                            Navigator.pop(context);
                                                            if (barcode.rawValue == null) {
                                                              debugPrint('Failed to scan Barcode');
                                                              Helpers.showToast("Gagal scan");
                                                            } else {
                                                              final String code = barcode.rawValue!;
                                                              absen(code);
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      InkWell(
                                                        child: Container(
                                                          padding: const EdgeInsets.all(20),
                                                          child: const Icon(
                                                            Icons.close,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          Navigator.pop(context);
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Ambil Foto'),
                                          leading: const Icon(Icons.camera_alt_outlined),
                                          onTap: () {
                                            // Navigator.of(context).pop();
                                            // setState(() async {
                                            //   fileFoto = await _picker.pickImage(
                                            //     source: ImageSource.camera,
                                            //     imageQuality: 50,
                                            //   );
                                            //   if (fileFoto != null) {
                                            //     absen(jadwalAbsensi.hashJadwalPengajar);
                                            //   }
                                            // });
                                            Navigator.of(context).pop();
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => PageAbsenPhoto(
                                                  data: data,
                                                  jenisAbsen: jenisA.toString(),
                                                  currentLocation: _currentLocation!,
                                                  lokasi: _address,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              : null,
                          disabledColor: Colors.grey,
                          color: const Color.fromRGBO(66, 174, 96, 1),
                          shape: CircleBorder(
                            side: BorderSide(
                              color: btnAbsen ? const Color.fromRGBO(104, 226, 138, 1) : colorPrimary,
                              width: 10,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(60),
                            child: Text(
                              data['text_btn'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: btnIzin
                                      ? () {
                                          _address != ""
                                              ? Navigator.of(context).push(MaterialPageRoute(
                                                  builder: (context) => PagePermintaanIzin(
                                                    data: data,
                                                    pageIzin: true,
                                                    currentLocation: _currentLocation!,
                                                    lokasi: _address,
                                                  ),
                                                ))
                                              : showToast("Lokasi Anda Belum Ditemukan");
                                        }
                                      : null,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: btnIzin ? null : Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: btnIzin ? colorPrimary : Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    side: BorderSide(
                                      width: 1.0,
                                      color: colorPrimary.withAlpha(100),
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Text(
                                    "Permintaan Izin",
                                    style: TextStyle(fontSize: 16, color: btnIzin ? colorPrimary : Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: btnCuti
                                      ? () {
                                          _address != ""
                                              ? Navigator.of(context).push(MaterialPageRoute(
                                                  builder: (context) => PagePermintaanCuti(
                                                    data: data,
                                                    currentLocation: _currentLocation!,
                                                    lokasi: _address,
                                                  ),
                                                ))
                                              : showToast("Lokasi Anda Belum Ditemukan");
                                        }
                                      : null,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: btnCuti ? null : Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: btnCuti ? colorPrimary : Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    side: BorderSide(
                                      width: 1.0,
                                      color: colorPrimary.withAlpha(100),
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Text(
                                    "Permintaan Cuti",
                                    style: TextStyle(fontSize: 16, color: btnCuti ? colorPrimary : Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            : const Center(child: CupertinoActivityIndicator()));
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
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
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
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  getAbsenHarian() async {
    setState(() {
      jadwalAbsen = null;

      // statusTombolAbsen = false;
    });

    if (await Helpers.isNetworkAvailable()) {
      try {
        String tokenAuth = "", hashUser = "";
        tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
        hashUser = (await getPrefrence(HASH_USER))!;

        var param = {
          'token_auth': tokenAuth,
          'hash_user': hashUser,
        };

        http.Response response = await http.post(
          Uri.parse(urlGetAbsenHarian),
          headers: headers,
          body: param,
        );

        log(response.body);

        Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        log(jsonResponse.toString());
        if (jsonResponse.containsKey("error")) {
        } else {
          bool success = jsonResponse['success'];
          if (success) {
            setState(() {
              jadwalAbsen = true;
              label = jsonResponse['jadwal']["tanggal"].toString();
              jadwalAbsensi.idJadwalPengajar = jsonResponse['jadwal']["id_jadwal_pengajar"].toString();
              jadwalAbsensi.hashJadwalPengajar = jsonResponse['jadwal']["hash_jadwal_pengajar"].toString();
              jadwalAbsensi.kdPengajar = jsonResponse['jadwal']["kd_pengajar"].toString();
              jadwalAbsensi.hari = jsonResponse['jadwal']["hari"].toString();
              jadwalAbsensi.jamMasuk = jsonResponse['jadwal']["jam_masuk"].toString();
              jadwalAbsensi.jamPulang = jsonResponse['jadwal']["jam_pulang"].toString();

              if (jsonResponse['absenMasuk'].toString().toLowerCase() == "null") {
                statusAbsen = "1";
                absensiMasuk.jam_absen = "-";
                // statusTombolAbsen = true;
              } else {
                absensiMasuk.jam_absen = jsonResponse["absenMasuk"]["jam_absen"].toString();
                absensiMasuk.status_absen = jsonResponse["absenMasuk"]["status_absen"].toString();
                absensiMasuk.keterangan = jsonResponse["absenMasuk"]["keterangan"].toString();
              }

              if (jsonResponse['absenPulang'].toString().toLowerCase() == "null") {
                absensiPulang.jam_absen = "-";
                if (jsonResponse['absenMasuk'].toString().toLowerCase() != "null") statusAbsen = "2";
                // statusTombolAbsen = true;
              } else {
                absensiPulang.jam_absen = jsonResponse["absenPulang"]["jam_absen"].toString();
                absensiPulang.status_absen = jsonResponse["absenPulang"]["status_absen"].toString();
                absensiPulang.keterangan = jsonResponse["absenPulang"]["keterangan"].toString();
              }

              // if (absensiMasuk.status_absen != "" && absensiPulang.status_absen != "") statusTombolAbsen = false;
            });
          } else {
            setState(() {
              jadwalAbsen = false;
              jadwalAbsensi = JadwalAbsensi();
            });
          }
        }
      } catch (e, stacktrace) {
        log(e.toString());
        log(stacktrace.toString());
      }
    }
  }

  absen(String hashJadwal) async {
    EasyLoading.show(
      status: "Tunggu sebentar...",
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );

    String tokenAuth = "", hashUser = "";
    tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
    hashUser = (await getPrefrence(HASH_USER))!;

    var now = DateTime.now();
    var request = http.MultipartRequest("POST", Uri.parse(urlSimpanAbsenHarian));
    request.headers.addAll(headers);
    request.fields["token_auth"] = tokenAuth;
    request.fields["hash_user"] = hashUser;
    request.fields["hash_jadwal"] = hashJadwal;
    request.fields["tgl_absen"] = DateFormat('yyyy-MM-dd').format(now);
    request.fields["jam_absen"] = DateFormat('HH:mm').format(now);
    request.fields["status_absen"] = statusAbsen;
    request.fields["lat"] = latitude.toString();
    request.fields["long"] = longitude.toString();
    if (fileFoto != null) {
      var pic = await http.MultipartFile.fromPath("foto", fileFoto!.path);
      request.files.add(pic);
    }
    http.Response response = await http.Response.fromStream(await request.send());
    log(response.body);
    try {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      log(jsonResponse.toString());
      if (jsonResponse.containsKey("error")) {
        // onError(Object, StackTrace.current, jsonResponse["error"]);
      } else {
        // onSuccess(jsonResponse);
        if (jsonResponse["success"]) {
          EasyLoading.showSuccess(jsonResponse["message"]);
          getAbsenHarian();
        } else {
          EasyLoading.showError(jsonResponse["message"]);
        }
      }
    } catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());
      String customMessage = "${Strings.TERJADI_KESALAHAN}.\n${e.runtimeType.toString()}";
      EasyLoading.showInfo(customMessage);
    }
  }
}
