import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/ApiStatus.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/harian/page_beranda_absen_harian.dart';
import 'package:absentip/model/jadwal_absensi.dart';
import 'package:absentip/my_colors.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/alert_dialog_oke_widget.dart';
import 'package:absentip/wigets/label_form.dart';
import 'package:absentip/wigets/show_image_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';
import 'package:flutx/widgets/container/container.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as image;

class PageAbsenPhoto extends StatefulWidget {
  final Map data;
  final String jenisAbsen;
  final Position currentLocation;
  final String lokasi;
  const PageAbsenPhoto({
    Key? key,
    required this.data,
    required this.jenisAbsen,
    required this.currentLocation,
    required this.lokasi,
  }) : super(key: key);

  @override
  State<PageAbsenPhoto> createState() => _PageAbsenPhotoState();
}

class _PageAbsenPhotoState extends State<PageAbsenPhoto> {
  Map dataCekAbsen = {};
  Map dataAbsensi = {};
  String jenisAbsen = "";
  String _filePath = "";
  String _fileName = "";
  String lokasi = "";
  Position? _currentLocation;
  bool loading = false;

  XFile? fileFoto;
  JadwalAbsensi jadwalAbsensi = JadwalAbsensi();

  @override
  void initState() {
    // TODO: implement initState
    dataCekAbsen = widget.data;
    jenisAbsen = widget.jenisAbsen;
    _currentLocation = widget.currentLocation;
    lokasi = widget.lokasi;

    log(dataCekAbsen.toString());
    getAbsenHarian();
    super.initState();
  }

  Future<void> takePhoto() async {
    setState(() {
      loading = true;
    });
    XFile? imageFile;

    if (Platform.isIOS) {
      try {
        imageFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
      } catch (e) {
        PermissionStatus permission = await Permission.photos.status;
        if (permission != PermissionStatus.granted) {
          alertOpenSetting(context);
        }
      }
    } else {
      try {
        imageFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
      } catch (e) {
        PermissionStatus permission = await Permission.camera.status;
        if (permission == PermissionStatus.denied) {
          //? Requesting the permission
          PermissionStatus statusDenied = await Permission.camera.request();
          if (statusDenied.isPermanentlyDenied) {
            //? permission isPermanentlyDenied
            alertOpenSetting(context);
          }
        }
      }
    }
    setState(() {
      loading = true;
    });

    if (imageFile != null) {
      log("You selected  image : ${imageFile.path}");

      Future<int> getSizeImage(String filePath) async {
        File image = File(filePath);
        final bytes = (await image.readAsBytes()).lengthInBytes;
        final kb = (bytes / 1024).floor();

        return kb;
      }

      final file = File(imageFile.path);
      var decImg = image.decodeImage(file.readAsBytesSync());

      if (decImg != null) {
        image.drawString(decImg, image.arial_48, 20, 20, DateTime.now().toString());
        image.drawString(decImg, image.arial_48, 20, 90, "${_currentLocation!.latitude}, ${_currentLocation!.longitude}");
        image.drawString(decImg, image.arial_48, 20, 160, lokasi);
        var encodeImage = image.encodeJpg(decImg, quality: 50);
        var finalImage = File(file.path)..writeAsBytesSync(encodeImage);

        int sizeImage = 0;
        int safeLooping = 10;
        File result = File(finalImage.path);

        do {
          result = await FlutterNativeImage.compressImage(result.path, percentage: 50, quality: 50);
          sizeImage = await getSizeImage(result.path);
          safeLooping--;
          log("resize: $sizeImage ---$safeLooping");
        } while (sizeImage > 64 && safeLooping != 0);

        if (mounted) {
          setState(() {
            _fileName = imageFile?.name ?? "foto_absen";
            _filePath = result.path;
            loading = false;
          });
        }
      } else {
        showToast("Gagal decode foto");
      }
    } else {
      log("You have not taken image");
    }
  }

  Future<Map<String, dynamic>?> absen(String file) async {
    await showLoading();
    final pref = await SharedPreferences.getInstance();
    log(dataCekAbsen['kd_group'].toString());
    log(file);

    DateTime dateTime = DateTime.now();

    final response = await ApiConnect.instance.uploadFile(
      EndPoint.urlSimpanAbsenHarian,
      "foto",
      _filePath,
      {
        'token_auth': pref.getString(TOKEN_AUTH)!,
        'hash_user': pref.getString(HASH_USER)!,
        'jenis_absen': jenisAbsen,
        'time_zone_name': dateTime.timeZoneName,
        'time_zone_offset': dateTime.timeZoneOffset.inHours.toString(),
        'lat': _currentLocation!.latitude.toString(),
        'long': _currentLocation!.longitude.toString(),
        'status_absen': dataCekAbsen['status_absen'].toString(),
        'kd_tanda': dataCekAbsen['kd_tanda'].toString(),
      },
    );

    await dismissLoading();

    return response;
  }

  @override
  Widget build(BuildContext context) {
    log("build AbsenFotoPage");
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const Image(
          image: AssetImage(AppImages.bg2),
          fit: BoxFit.cover,
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: colorPrimary,
        leading: GestureDetector(
          // onTap: () => AppNavigator.instance.pop(),
          onTap: () => Navigator.of(context, rootNavigator: true).pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(3, 3),
                  blurRadius: 3,
                ),
              ],
            ),
            // decoration: BoxDecoration(
            //   color: Colors.white.withOpacity(0.2),
            //   borderRadius: BorderRadius.circular(6),
            // ),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorPrimary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Icon(
                  MdiIcons.chevronLeft,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        title: const SizedBox(
          // width: double.infinity,
          child: Text(
            "Absen Photo",
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
              fontSize: 18,
              fontWeight: FontWeight.w600,
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 12),
          const LabelForm(label: "Foto Selfie", fontSize: 14, isRequired: true),
          const SizedBox(height: 4),
          FxContainer.bordered(
            width: double.infinity,
            padding: FxSpacing.zero,
            height: 200,
            child: loading
                ? CupertinoActivityIndicator()
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Visibility(
                        visible: _filePath.isEmpty,
                        child: InkWell(
                          onTap: () {
                            takePhoto();
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera,
                                color: colorPrimary,
                                size: 34,
                              ),
                              Text(
                                "Ambil Foto Selfie",
                                style: TextStyle(color: colorPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _filePath.isNotEmpty,
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ShowImagePage(
                                judul: "Foto Selfie",
                                url: _filePath,
                                isFile: true,
                              ),
                            ),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_filePath),
                                fit: BoxFit.cover,
                                errorBuilder: (context, urlImage, error) {
                                  return Image.asset(
                                    AppImages.noImage,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Visibility(
                          visible: _filePath.isNotEmpty,
                          child: IconButton(
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  _fileName = "";
                                  _filePath = "";
                                });
                              }
                            },
                            icon: Icon(
                              MdiIcons.closeCircle,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
            child: ElevatedButton(
              onPressed: () async {
                if (_filePath.isEmpty) {
                  showToast("Foto tidak boleh kosong");
                } else {
                  final response = await absen(_filePath);

                  if (response != null) {
                    if (response['success']) {
                      final result = await showDialog<bool>(context: context, builder: (context) => AlertDialogOkWidget(message: response['message'].toString()));
                      Navigator.of(context).pop();
                      if (result ?? false) {
                        Navigator.of(context).pop();
                      }
                    } else {
                      if (response['code'].toString() == "0") {
                        showToast(response['message'].toString());
                      } else if (response['code'].toString() == "1") {
                        showDialog<bool>(context: context, builder: (context) => AlertDialogOkWidget(message: response['message'].toString()));
                      } else {
                        showToast(response['message'].toString());
                      }
                    }
                  }
                }
              },
              child: const Text(
                'SIMPAN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // absen(String hashJadwal) async {
  //   EasyLoading.show(
  //     status: "Tunggu sebentar...",
  //     dismissOnTap: false,
  //     maskType: EasyLoadingMaskType.black,
  //   );

  //   String tokenAuth = "", hashUser = "";
  //   tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
  //   hashUser = (await getPrefrence(HASH_USER))!;

  //   var now = DateTime.now();
  //   var request = http.MultipartRequest("POST", Uri.parse(EndPoint.urlSimpanAbsenHarian));
  //   request.headers.addAll(headers);
  //   request.fields["token_auth"] = tokenAuth;
  //   request.fields["hash_user"] = hashUser;
  //   request.fields["hash_jadwal"] = hashJadwal;
  //   request.fields["tgl_absen"] = DateFormat('yyyy-MM-dd').format(now);
  //   request.fields["jam_absen"] = DateFormat('HH:mm').format(now);
  //   request.fields["status_absen"] = "2 ";
  //   request.fields["lat"] = (0).toString();
  //   request.fields["long"] = (0).toString();
  //   if (fileFoto != null) {
  //     var pic = await http.MultipartFile.fromPath("foto", fileFoto!.path);
  //     request.files.add(pic);
  //   }
  //   http.Response response = await http.Response.fromStream(await request.send());
  //   log(response.body);
  //   try {
  //     Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
  //     log(jsonResponse.toString());
  //     if (jsonResponse.containsKey("error")) {
  //       // onError(Object, StackTrace.current, jsonResponse["error"]);
  //     } else {
  //       // onSuccess(jsonResponse);
  //       if (jsonResponse["success"]) {
  //         EasyLoading.showSuccess(jsonResponse["message"]);
  //         getAbsenHarian();
  //       } else {
  //         EasyLoading.showError(jsonResponse["message"]);
  //       }
  //     }
  //   } catch (e, stacktrace) {
  //     log(e.toString());
  //     log(stacktrace.toString());
  //     String customMessage = "${Strings.TERJADI_KESALAHAN}.\n${e.runtimeType.toString()}";
  //     EasyLoading.showInfo(customMessage);
  //   }
  // }

  ApiStatus _apiStatus = ApiStatus.loading;

  getAbsenHarian() async {
    setState(() {
      _apiStatus = ApiStatus.loading;
    });

    final pref = await SharedPreferences.getInstance();

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.urlGetAbsenHarian,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH)!,
        'hash_user': pref.getString(HASH_USER)!,
      },
    );

    Map responseBody = response!;

    dataAbsensi = responseBody['jadwal'];

    log(response.toString());
  }
}
