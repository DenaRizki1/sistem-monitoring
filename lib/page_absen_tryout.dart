import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:absentip/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:http/http.dart' as http;
import 'model/tryout.dart';
import 'my_colors.dart';
import 'utils/api.dart';
import 'utils/helpers.dart';
import 'utils/sessions.dart';
import 'utils/strings.dart';

class PageAbsenTryout extends StatefulWidget {

  final Tryout tryout;
  const PageAbsenTryout({Key? key, required this.tryout}) : super(key: key);

  @override
  State<PageAbsenTryout> createState() => _PageAbsenTryoutState();
}

class _PageAbsenTryoutState extends State<PageAbsenTryout> {

  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};
  Location location = Location();
  bool statusTombolAbsen = false;
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  double latitude = 0.0, longitude = 0.0;
  final ImagePicker _picker = ImagePicker();
  XFile? fileFoto;
  String fileFotoPath = "";
  Timer? timer;

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
  }

  init() async {
    getAbsen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: colorPrimary,
        title: SizedBox(
          width: double.infinity,
          child: Text("Absen Tryout ${toBeginningOfSentenceCase(widget.tryout.jenisTryout)}",
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: Colors.black, overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // actions: <Widget>[
        //   IconButton(
        //     icon: const Icon(Icons.calendar_today_rounded),
        //     onPressed: () {
        //       // Navigator.push(context, MaterialPageRoute(builder: (context) => const PageRekapAbsenTryout()));
        //     },
        //   )
        // ],
      ),
      body: Container(
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
                                  icon: !statusTombolAbsen ? const CupertinoActivityIndicator() : const SizedBox(),
                                  label: const Text("Absen",),
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
                                                                debugPrint('Barcode found! $code');
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
                                            }
                                          ),
                                          ListTile(
                                            title: const Text('Ambil Foto'),
                                            leading: const Icon(Icons.camera_alt_outlined),
                                            onTap: () async {
                                              Navigator.of(context).pop();
                                              setState(() async {
                                                fileFoto = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50,);
                                                if(fileFoto!=null) {
                                                  absen(widget.tryout.kdTryout);
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
                                  getAbsen();
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
    );
  }

  getAbsen() async {

    setState(() {
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
          'kd_tryout': widget.tryout.kdTryout
        };

        log("jenisTryout:${widget.tryout.jenisTryout}");
        log("jenisTryout:${JenisTryout.jasmani}");

        String url = "";
        switch(widget.tryout.jenisTryout) {
          case JenisTryout.jasmani:
            url = urlGetAbsenTryoutJasmani;
            break;
          case JenisTryout.akademik:
            url = urlGetAbsenTryoutAkademik;
            break;
          case JenisTryout.psikologi:
            url = urlGetAbsenTryoutPsikologi;
            break;
        }

        log(url);

        http.Response response = await http.post(
          Uri.parse(url),
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



            });

          } else {

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

          }
        }
      } catch (e, stacktrace) {
        log(e.toString());
        log(stacktrace.toString());
      }

    } else {

    }
  }

  absen(String kdTryout) async {

    EasyLoading.show(
      status: "Tunggu sebentar...",
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );

    String tokenAuth = "", hashUser = "";
    tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
    hashUser = (await getPrefrence(HASH_USER))!;

    String url = "";
    switch(widget.tryout.jenisTryout) {
      case JenisTryout.jasmani:
        url = urlSimpanAbsenTryoutJasmani;
        break;
      case JenisTryout.akademik:
        url = urlSimpanAbsenTryoutAkademik;
        break;
      case JenisTryout.psikologi:
        url = urlSimpanAbsenTryoutPsikologi;
        break;
    }

    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.headers.addAll(headers);
    request.fields["token_auth"] = tokenAuth;
    request.fields["hash_user"] = hashUser;
    request.fields["kd_tryout"] = kdTryout;
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
          Navigator.pop(context, true);

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
