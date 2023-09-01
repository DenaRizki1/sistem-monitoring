import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/alert_dialog_confirm_widget.dart';
import 'package:absentip/wigets/alert_dialog_ok_widget.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:absentip/wigets/label_form.dart';
import 'package:absentip/wigets/show_image_page.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image/image.dart' as image;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageTambahAktivitas extends StatefulWidget {
  const PageTambahAktivitas({Key? key}) : super(key: key);

  @override
  State<PageTambahAktivitas> createState() => _PageTambahAktivitasState();
}

class _PageTambahAktivitasState extends State<PageTambahAktivitas> {
  final _tglAktivitasC = TextEditingController();
  final _aktivitasC = TextEditingController();
  DateTime? _tglAktivitasDate;
  List _listFotoAktivitas = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {});

    super.initState();
  }

  Future<Map<String, dynamic>?> simpanAktivitas() async {
    await showLoading();

    DateTime dateTime = DateTime.now();
    final pref = await SharedPreferences.getInstance();
    Map<String, String> params = {
      'token_auth': pref.getString(TOKEN_AUTH).toString(),
      'hash_user': pref.getString(HASH_USER).toString(),
      'time_zone_name': dateTime.timeZoneName,
      'time_zone_offset': dateTime.timeZoneOffset.inHours.toString(),
      'tgl_aktivitas': parseDateInd(_tglAktivitasDate.toString(), "yyyy-MM-dd"),
      'aktivitas': _aktivitasC.text.toString().trim(),
      'list_foto_aktivitas': jsonEncode(_listFotoAktivitas),
    };

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.simpanAktivitas,
      params: params,
    );

    dismissLoading();

    return response;
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
              if (mounted) {
                alertOpenSetting(context);
              }
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
                if (mounted) {
                  alertOpenSetting(context);
                }
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
              if (mounted) {
                alertOpenSetting(context);
              }
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
                if (mounted) {
                  alertOpenSetting(context);
                }
              }
            }
          }
        }
        break;
    }

    if (imageFile != null) {
      log("You selected  image : ${imageFile.path}");
      if (mounted) {
        Future<int> getSizeImage(String filePath) async {
          File image = File(filePath);
          final bytes = (await image.readAsBytes()).lengthInBytes;
          final kb = (bytes / 1024).floor();
          // final mb = (kb / 1024).floor();
          return kb;
        }

        //? pasang watermark
        // final file = File(imageFile.path);
        // var decImg = image.decodeImage(file.readAsBytesSync());
        // if (decImg != null) {
        //   image.drawString(decImg, image.arial_48, 20, 20, DateTime.now().toString());
        //   image.drawString(decImg, image.arial_48, 20, 90, "${_cekAbsen['lat']?.toString() ?? '0'}, ${_cekAbsen['lng']?.toString() ?? '0'}");
        //   image.drawStringWrap(decImg, image.arial_48, 20, 160, _cekAbsen['lokasi']?.toString() ?? "");
        //   var encodeImage = image.encodeJpg(decImg, quality: 50);
        //   var finalImage = File(file.path)..writeAsBytesSync(encodeImage);

        //   int sizeImage = 0;
        //   int safeLooping = 10;
        //   File result = File(finalImage.path);
        //   do {
        //     result = await FlutterNativeImage.compressImage(result.path, percentage: 50, quality: 50);
        //     sizeImage = await getSizeImage(result.path);
        //     safeLooping--;
        //     log("resize: $sizeImage ---$safeLooping");
        //   } while (sizeImage > 64 && safeLooping != 0);

        //   if (mounted) {
        //     setState(() {
        //       _filePath = result.path;
        //       _fileName = imageFile?.name ?? "foto_absen";
        //     });
        //   }
        // } else {
        //   showToast("Terjadi kesalahan saat memuat foto");
        // }

        showLoading();

        int sizeImage = 0;
        int safeLooping = 10;
        File result = File(imageFile.path);
        do {
          result = await FlutterNativeImage.compressImage(result.path, percentage: 50, quality: 50);
          sizeImage = await getSizeImage(result.path);
          safeLooping--;
          log("resize: $sizeImage ---$safeLooping");
        } while (sizeImage > 64 && safeLooping != 0);

        final pref = await SharedPreferences.getInstance();
        final response = await ApiConnect.instance.uploadFile(
          EndPoint.uploadAktivitas,
          "foto",
          result.path,
          {
            'token_auth': pref.getString(TOKEN_AUTH).toString(),
            'hash_user': pref.getString(HASH_USER).toString(),
          },
        );

        dismissLoading();

        if (response != null) {
          if (response['success']) {
            final data = response['data'];
            if (mounted) {
              setState(() {
                _listFotoAktivitas.add(data['file_url'].toString());
              });
            }
          } else {
            showToast(response['message'].toString());
          }
        }
      }
    } else {
      log("You have not taken image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Tambah Aktivitas"),
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
              const LabelForm(label: "Tanggal Aktivitas", isRequired: true),
              const SizedBox(height: 4),
              TextField(
                decoration: textFieldDecoration(textHint: "Pilih Tanggal Aktivitas"),
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                controller: _tglAktivitasC,
                readOnly: true,
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
                    lastDate: DateTime.now(),
                  ).then((value) {
                    _tglAktivitasDate = value;
                    if (value != null) {
                      _tglAktivitasC.text = parseDateInd(_tglAktivitasDate.toString(), "dd MMMM yyyy");
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              const LabelForm(label: "Aktivitas", isRequired: true),
              const SizedBox(height: 4),
              TextField(
                decoration: textFieldDecoration(textHint: "Masukan Aktivitas"),
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  dismissKeyboard();
                },
                textCapitalization: TextCapitalization.sentences,
                minLines: 10,
                maxLines: 20,
                controller: _aktivitasC,
              ),
              const SizedBox(height: 12),
              const LabelForm(label: "Pilih Berkas", isRequired: false),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.hitam,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          dialogPilihBerkas(context);
                        },
                        child: const Text(
                          'Tambah Foto Aktivitas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _listFotoAktivitas.isNotEmpty,
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade400,
                          ),
                        ),
                        child: ListView.separated(
                          itemCount: _listFotoAktivitas.length,
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (context, index) {
                            return const VerticalDivider(width: 4);
                          },
                          itemBuilder: (context, index) {
                            final fotoAktivitas = _listFotoAktivitas[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      AppNavigator.instance.push(MaterialPageRoute(
                                        builder: (context) => ShowImagePage(
                                          judul: "Foto Aktivitas",
                                          url: fotoAktivitas,
                                          isFile: false,
                                        ),
                                      ));
                                    },
                                    child: Image.network(
                                      fotoAktivitas,
                                      fit: BoxFit.fill,
                                      width: 100,
                                      height: 100,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: Center(
                                            child: SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 0).toInt(),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) => Image.asset(
                                        AppImages.logoGold,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _listFotoAktivitas.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withAlpha(100),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Icon(
                                          MdiIcons.close,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_tglAktivitasDate == null) {
                    showToast("Tanggal aktivitas tidak boleh kosong");
                  } else if (_aktivitasC.text.toString().isEmpty) {
                    showToast("Aktivitas tidak boleh kosong");
                  } else {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => const AlertDialogConfirmWidget(message: "Apakah data yang anda masukan sudah benar?"),
                    );

                    if (result ?? false) {
                      final response = await simpanAktivitas();
                      if (response != null) {
                        if (response['success']) {
                          final result = await showDialog<bool>(context: context, builder: (context) => AlertDialogOkWidget(message: response['message'].toString()));
                          if (result ?? false) {
                            if (mounted) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          }
                        } else {
                          showToast(response['message'].toString());
                        }
                      }
                    }
                  }
                },
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }

  Future<dynamic> dialogPilihBerkas(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'Pilih Jenis Berkas',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  AppNavigator.instance.pop();
                  imageSelector(context, "camera");
                },
                child: ListTile(
                  leading: Icon(MdiIcons.camera),
                  title: const Text("Kamera"),
                ),
              ),
              const Divider(),
              InkWell(
                onTap: () {
                  AppNavigator.instance.pop();
                  imageSelector(context, "gallery");
                },
                child: ListTile(
                  leading: Icon(MdiIcons.image),
                  title: const Text("Galeri"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
