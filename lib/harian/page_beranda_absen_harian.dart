import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:absentip/model/absensi.dart';
import 'package:absentip/model/jadwal_absensi.dart';
import 'package:absentip/my_colors.dart';
import 'package:absentip/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:http/http.dart' as http;
import '../utils/api.dart';
import '../utils/helpers.dart';
import '../utils/sessions.dart';
import '../utils/strings.dart';

class PageBerandaAbsenHarian extends StatefulWidget {
  const PageBerandaAbsenHarian({Key? key}) : super(key: key);

  @override
  State<PageBerandaAbsenHarian> createState() => _PageBerandaAbsenHarianState();
}

class _PageBerandaAbsenHarianState extends State<PageBerandaAbsenHarian> {

  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};
  bool? jadwalAbsen;
  bool loading = true, statusBisaAbsen = false, statusTombolAbsen = false;
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
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

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
    today = Helpers.getDateTimeNow(true, true, true, true, false);
  }

  init() async {

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final c = await _controller.future;
    LocationData locationData = await location.getLocation();
    setState(() {
      latitude = locationData.latitude ?? 0.0;
      longitude = locationData.longitude ?? 0.0;
      if(latitude!=0.0 && longitude!=0.0) {
        setState(() {
          markers.addAll([
            Marker(
              markerId: const MarkerId('Lokasi'),
              position: LatLng(latitude, longitude),
            ),
          ]);
        });
        final p = CameraPosition(target: LatLng(latitude, longitude), zoom: 14.4746);
        c.animateCamera(CameraUpdate.newCameraPosition(p));
        setState(() {
          statusTombolAbsen = true;
        });
      } else {
        setState(() {
          statusTombolAbsen = false;
        });
      }
    });

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

    getAbsenHarian();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: colorPrimary,
        title: const SizedBox(
          width: double.infinity,
          child: Text("Absen Harian",
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.black, overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        actions: <Widget>[
          // IconButton(
          //   icon: const Icon(Icons.calendar_today_rounded),
          //   onPressed: () {
          //     Navigator.push(context, MaterialPageRoute(builder: (context) => const PageRekapAbsenHarian()));
          //   },
          // )
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              'images/bg_doodle.jpg',
              fit: BoxFit.cover,
              // color: const Color.fromRGBO(255, 255, 255, 0.1),
              // colorBlendMode: BlendMode.modulate,
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(10),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Card(
                                color: colorInfo,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text("Jadwal Hari Ini"),
                                      const SizedBox(height: 2,),
                                      Text(today, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold),),
                                      jadwalAbsen!=null ? (!jadwalAbsen! ? const Text("Tidak ada jadwal") : Text("${jadwalAbsensi.jamMasuk} - ${jadwalAbsensi.jamPulang}")) : const CupertinoActivityIndicator(),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 10, left: 6, right: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Expanded(child: Text("Masuk"),),
                                        !loading ? Text(
                                          absensiMasuk.jam_absen!="" ? absensiMasuk.jam_absen : "-",
                                          textAlign: TextAlign.end,
                                          style: GoogleFonts.ptMono(
                                            color: absensiMasuk.keterangan=="" || absensiMasuk.keterangan=="1" || absensiMasuk.keterangan=="2" ? Colors.red : Colors.green,
                                          ),
                                        ) : const CupertinoActivityIndicator(),
                                      ],
                                    ),
                                    const SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        const Expanded(child: Text("Pulang")),
                                        !loading ? Text(
                                          absensiPulang.jam_absen!="" ? absensiPulang.jam_absen : "-",
                                          textAlign: TextAlign.end,
                                          style: GoogleFonts.ptMono(
                                            color: absensiPulang.keterangan=="" || absensiPulang.keterangan=="1" || absensiPulang.keterangan=="2" ? Colors.red : Colors.green,
                                          ),
                                        ) : const CupertinoActivityIndicator(),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  color: Colors.grey,
                                  child: GoogleMap(
                                    mapType: MapType.normal,
                                    initialCameraPosition: CameraPosition(target: LatLng(latitude, longitude), zoom: 14.4746,),
                                    myLocationEnabled: true,
                                    myLocationButtonEnabled: true,
                                    zoomControlsEnabled: true,
                                    zoomGesturesEnabled: true,
                                    scrollGesturesEnabled: true,
                                    trafficEnabled: false,
                                    rotateGesturesEnabled: false,
                                    onMapCreated: (GoogleMapController controller) {
                                      if(!_controller.isCompleted) _controller.complete(controller);
                                    },
                                    markers: markers,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16,),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: loading ? const CupertinoActivityIndicator() : const SizedBox(),
                                      label: Text(
                                        absensiMasuk.status_absen=="" ? "Absen Masuk" : (absensiMasuk.status_absen!="" && absensiPulang.status_absen=="" ? "Absen Pulang" : "Absen"),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        primary: statusTombolAbsen ? Colors.blue : Colors.grey,
                                      ),
                                      onPressed: statusTombolAbsen ? () {
                                        showBarModalBottomSheet(
                                          context: context,
                                          builder: (context) => Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                title: const Text('Scan QR Code'),
                                                leading: const Icon(Icons.qr_code),
                                                onTap: (){
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
                                                                controller: MobileScannerController(facing: CameraFacing.back,),
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
                                                                padding: EdgeInsets.all(20),
                                                                child: Icon(Icons.close, color: Colors.red,),
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
                                                onTap: () async {
                                                  Navigator.of(context).pop();
                                                  setState(() async {
                                                    fileFoto = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50,);
                                                    if(fileFoto!=null) {
                                                      absen(jadwalAbsensi.hashJadwalPengajar);
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      } : null,
                                    ),
                                  ),
                                  const SizedBox(width: 10,),
                                  ElevatedButton(
                                    onPressed: () {
                                      getAbsenHarian();
                                    },
                                    child: const Icon(Icons.refresh),
                                  ),
                                ],
                              ),
                            ],
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
      )
    );
  }

  getAbsenHarian() async {

    setState(() {
      jadwalAbsen = null;
      loading = true;
      statusTombolAbsen = false;
    });

    if(await Helpers.isNetworkAvailable()) {

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

        setState(() {
          loading = false;
        });

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

              if(jsonResponse['absenMasuk'].toString().toLowerCase()=="null") {
                statusAbsen = "1";
                absensiMasuk.jam_absen = "-";
                statusTombolAbsen = true;
              } else {
                absensiMasuk.jam_absen = jsonResponse["absenMasuk"]["jam_absen"].toString();
                absensiMasuk.status_absen = jsonResponse["absenMasuk"]["status_absen"].toString();
                absensiMasuk.keterangan = jsonResponse["absenMasuk"]["keterangan"].toString();
              }

              if(jsonResponse['absenPulang'].toString().toLowerCase()=="null") {
                absensiPulang.jam_absen = "-";
                if(jsonResponse['absenMasuk'].toString().toLowerCase()!="null") statusAbsen = "2";
                statusTombolAbsen = true;
              } else {
                absensiPulang.jam_absen = jsonResponse["absenPulang"]["jam_absen"].toString();
                absensiPulang.status_absen = jsonResponse["absenPulang"]["status_absen"].toString();
                absensiPulang.keterangan = jsonResponse["absenPulang"]["keterangan"].toString();
              }

              if(absensiMasuk.status_absen!="" && absensiPulang.status_absen!="") statusTombolAbsen = false;

            });

          } else {
            setState(() {
              jadwalAbsen = false;
              jadwalAbsensi = JadwalAbsensi();
            });
          }
        }
      } catch (e, stacktrace) {
        setState(() {
          loading = false;
        });
        log(e.toString());
        log(stacktrace.toString());
      }

    } else {
      setState(() {
        loading = false;
      });
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
    if(fileFoto!=null) {
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
        if(jsonResponse["success"]) {

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
