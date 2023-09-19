import 'dart:developer';
import 'dart:io';

import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/model/key_value_model.dart';
import 'package:absentip/modules/absen/dialog_konfirmasi_absen.dart';
import 'package:absentip/services/location_service.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/utils/sessions.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutx/flutx.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/wigets/alert_dialog_ok_widget.dart';
import 'package:absentip/wigets/label_form.dart';
import 'package:absentip/wigets/show_image_page.dart';

class PageAbsenFoto extends StatefulWidget {
  final Map cekAbsen;

  const PageAbsenFoto({Key? key, required this.cekAbsen}) : super(key: key);

  @override
  State<PageAbsenFoto> createState() => _PageAbsenFotoState();
}

class _PageAbsenFotoState extends State<PageAbsenFoto> {
  KeyValueModel? _selectedJadwal;
  Map _cekAbsen = {};
  String _filePath = "";
  // ignore: unused_field
  String _fileName = "";
  String _title = "";

  @override
  void initState() {
    _cekAbsen = widget.cekAbsen;

    log(_cekAbsen.toString());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _title = _cekAbsen['text_btn']?.toString() ?? "";
      });
    });

    super.initState();
  }

  Future<List<KeyValueModel>> getJadwalHarian() async {
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.jadwalAbsenHarian,
      params: {
        'token_auth': await getPrefrence(TOKEN_AUTH) ?? "",
        'hash_user': await getPrefrence(HASH_USER) ?? "",
      },
    );

    if (response != null) {
      if (response['success'] == true) {
        List data = response['data'];
        return data.map((e) => KeyValueModel(key: e['kd_jadwal_absen'].toString(), value: e['nama_jadwal'].toString())).toList();
      } else {
        showToast(response['message'].toString());
      }
    }

    return [];
  }

  Future<void> imageSelector(BuildContext context, String pickerType) async {
    XFile? imageFile;
    switch (pickerType) {
      case "gallery":
        if (Platform.isIOS) {
          try {
            imageFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
          } catch (e) {
            PermissionStatus permission = await Permission.photos.status;
            if (permission != PermissionStatus.granted) {
              alertOpenSetting(context);
            }
          }
        } else {
          try {
            imageFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
          } catch (e) {
            PermissionStatus permission = await Permission.storage.status;
            if (permission == PermissionStatus.denied) {
              //? Requesting the permission
              PermissionStatus statusDenied = await Permission.storage.request();
              if (statusDenied.isPermanentlyDenied) {
                //? permission isPermanentlyDenied
                alertOpenSetting(context);
              }
            }
          }
        }
        break;

      case "camera":
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
        break;
    }

    if (imageFile != null) {
      log("You selected  image : ${imageFile.path}");

      setState(() {
        _filePath = imageFile!.path;
        _fileName = imageFile.name;
      });
    } else {
      log("You have not taken image");
    }
  }

  Future<String?> insertWatermark(String pathInput, String lat, String lng, String lokasi) async {
    Future<int> getSizeImage(String filePath) async {
      File image = File(filePath);
      final bytes = (await image.readAsBytes()).lengthInBytes;
      final kb = (bytes / 1024).floor();
      // final mb = (kb / 1024).floor();
      return kb;
    }

    //? pasang watermark
    final file = File(pathInput);
    var decImg = image.decodeImage(file.readAsBytesSync());
    if (decImg != null) {
      image.drawString(decImg, image.arial_48, 20, 20, DateTime.now().toString());
      image.drawString(decImg, image.arial_48, 20, 90, "$lat, $lng");
      image.drawStringWrap(decImg, image.arial_48, 20, 160, lokasi);
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

      return result.path;
    } else {
      showToast("Terjadi kesalahan saat memuat foto");
      return null;
    }
  }

  Future<void> lokasiAbsenLuarKelas() async {
    await showLoading();

    final dateTime = DateTime.now();
    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.lokasiAbsenLuarKelas,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH).toString(),
        'hash_user': pref.getString(HASH_USER).toString(),
        'time_zone_name': dateTime.timeZoneName,
        'time_zone_offset': dateTime.timeZoneOffset.inHours.toString(),
        'lat': _cekAbsen['lat']?.toString() ?? '0',
        'long': _cekAbsen['lng']?.toString() ?? '0',
      },
    );

    dismissLoading();

    if (response != null) {
      if (response['success']) {
        List listLokasi = response['data'];
        if (listLokasi.length > 1) {
          final idLokasi = await showDialog<String>(context: context, builder: (context) => DialogKonfirmasiAbsen(listLokasi: response['data']));
          if (idLokasi != null) {
            simpanAbsen(idLokasi);
          }
        } else {
          simpanAbsen(listLokasi.first['id_branch'].toString());
        }
      } else {
        showDialog(context: context, builder: (context) => AlertDialogOkWidget(message: response['message'].toString()));
      }
    }
  }

  Future<void> simpanAbsen(String idLokasi) async {
    await showLoading();

    double latitude = 0.0;
    double longitude = 0.0;
    String address = "";

    final _currentLocation = await LocationService.instance.getCurrentLocation(context);
    if (_currentLocation != null) {
      latitude = _currentLocation.latitude;
      longitude = _currentLocation.longitude;
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentLocation.latitude,
        _currentLocation.longitude,
        localeIdentifier: "id_ID",
      );
      if (placemarks.isNotEmpty) {
        Placemark placeMark = placemarks[0];
        if (mounted) {
          setState(() {
            address =
                "${placeMark.street}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.subAdministrativeArea}, ${placeMark.administrativeArea}, ${placeMark.country}, ${placeMark.postalCode}";
          });
        }
      } else {
        dismissLoading();
        showToast("Lokasi tidak ditemukan");
        return;
      }
    } else {
      dismissLoading();
      showToast("Koordinat tidak ditemukan");
      return;
    }

    final resultPath = await insertWatermark(_filePath, latitude.toString(), longitude.toString(), address);
    if (resultPath == null) {
      dismissLoading();
      return;
    }

    DateTime dateTime = DateTime.now();

    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.uploadFile(
      _cekAbsen['jenis_absen'].toString() == "1" ? EndPoint.simpanAbsen : EndPoint.simpanAbsenLuarkelas,
      "foto",
      resultPath,
      {
        'token_auth': pref.getString(TOKEN_AUTH).toString(),
        'hash_user': pref.getString(HASH_USER).toString(),
        'time_zone_name': dateTime.timeZoneName,
        'time_zone_offset': dateTime.timeZoneOffset.inHours.toString(),
        'status_absen': _cekAbsen['status_absen'].toString(), // 1 = Masuk | 2 = Pulang
        'jenis_absen': _cekAbsen['jenis_absen'].toString(), // 1 = kelas |  2 = Luar Kelas
        'id_lokasi': idLokasi,
        'kd_jadwal': _selectedJadwal!.key.toString(),
        'kd_tanda': _cekAbsen['kd_tanda']?.toString() ?? "",
        'lat': _cekAbsen['lat']?.toString() ?? '0',
        'long': _cekAbsen['lng']?.toString() ?? '0',
      },
    );

    dismissLoading();

    if (response != null) {
      if (response['success']) {
        final result = await showDialog<bool>(context: context, builder: (context) => AlertDialogOkWidget(message: response['message'].toString()));
        if (result ?? false) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      } else {
        switch (response['code']?.toString() ?? "0") {
          case "0":
            showToast(response['message'].toString());
            break;
          case "1":
            showDialog(context: context, builder: (context) => AlertDialogOkWidget(message: response['message'].toString()));
            break;
          default:
            showToast(response['message'].toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log("PageAbsenFotoTetap");
    return Scaffold(
      appBar: appBarWidget(_title),
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
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 12),
              const LabelForm(label: "Foto Selfie", isRequired: true),
              const SizedBox(height: 4),
              FxContainer.bordered(
                width: double.infinity,
                padding: FxSpacing.zero,
                color: Colors.grey,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Visibility(
                      visible: _filePath.isEmpty,
                      child: InkWell(
                        onTap: () {
                          imageSelector(context, "camera");
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera,
                              color: AppColor.biru,
                              size: 34,
                            ),
                            Text(
                              "Ambil Foto Selfie",
                              style: TextStyle(color: AppColor.biru),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _filePath.isNotEmpty,
                      child: InkWell(
                        onTap: () => AppNavigator.instance.push(
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
              const SizedBox(height: 12),
              const LabelForm(label: "Shift", isRequired: true),
              const SizedBox(height: 4),
              DropdownSearch<KeyValueModel>(
                asyncItems: (text) => getJadwalHarian(),
                itemAsString: (item) => item.value,
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  menuProps: const MenuProps(),
                  searchFieldProps: TextFieldProps(
                    decoration: textFieldDecoration(
                      textHint: "Cari Shift",
                    ),
                  ),
                  loadingBuilder: (context, searchEntry) => loadingWidget(),
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: textFieldDecoration(
                    textHint: "Pilih Shift",
                  ),
                ),
                selectedItem: _selectedJadwal,
                onChanged: (item) {
                  _selectedJadwal = item;
                },
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_filePath.isEmpty) {
                      showToast("Foto tidak boleh kosong");
                    } else if (_selectedJadwal == null) {
                      showToast("Shitf tidak boleh kosong");
                    } else {
                      if (_cekAbsen['jenis_absen'].toString() == "1") {
                        simpanAbsen("");
                      } else {
                        lokasiAbsenLuarKelas();
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
        ],
      ),
    );
  }
}
