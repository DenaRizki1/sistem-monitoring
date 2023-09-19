import 'dart:developer';
import 'dart:io';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/model/key_value_model.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/alert_dialog_confirm_widget.dart';
import 'package:absentip/wigets/alert_dialog_ok_widget.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:absentip/wigets/label_form.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../wigets/show_image_page.dart';

class PagePermintaanIzin extends StatefulWidget {
  final Map cekAbsen;

  const PagePermintaanIzin({Key? key, required this.cekAbsen}) : super(key: key);

  @override
  State<PagePermintaanIzin> createState() => _PagePermintaanIzinState();
}

class _PagePermintaanIzinState extends State<PagePermintaanIzin> {
  final _keteranganC = TextEditingController();
  Map _cekAbsen = {};
  KeyValueModel? _selectedJenisIzin;
  String _filePath = "";
  String _fileName = "";

  @override
  void initState() {
    _cekAbsen = widget.cekAbsen;
    WidgetsBinding.instance.addPostFrameCallback((_) {});

    super.initState();
  }

  Future<Map<String, dynamic>?> simpanAbsenIzin() async {
    await showLoading();

    DateTime dateTime = DateTime.now();

    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.uploadFile(
      EndPoint.simpanAbsenIzin,
      "foto",
      _filePath,
      {
        'token_auth': pref.getString(TOKEN_AUTH).toString(),
        'hash_user': pref.getString(HASH_USER).toString(),
        'time_zone_name': dateTime.timeZoneName,
        'time_zone_offset': dateTime.timeZoneOffset.inHours.toString(),
        'kd_tanda': _cekAbsen['kd_tanda'].toString(),
        'lat': _cekAbsen['lat']?.toString() ?? '0',
        'long': _cekAbsen['lng']?.toString() ?? '0',
        'jenis_izin': _selectedJenisIzin?.key ?? "",
        'keterangan': _keteranganC.text.toString().trim(),
      },
    );

    dismissLoading();

    return response;
  }

  Future<void> filePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      if (mounted) {
        setState(() {
          _filePath = file.path.toString();
          _fileName = file.name;
        });
      }

      log(file.name);
      log(file.size.toString());
      log(file.extension.toString());
      log(file.path.toString());
    } else {
      log(" User canceled the picker");
    }
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
        setState(() {
          _filePath = imageFile?.path ?? "";
          _fileName = imageFile?.name ?? "foto_absen";
        });
      }
    } else {
      log("You have not taken image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Permintaan Izin"),
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
              const LabelForm(label: "Jenis Izin", isRequired: true),
              const SizedBox(height: 4),
              DropdownSearch<KeyValueModel>(
                items: [
                  KeyValueModel(key: "1", value: "Izin Sakit"),
                  KeyValueModel(key: "2", value: "Izin Dengan Keterangan"),
                  KeyValueModel(key: "3", value: "Izin Lainnya"),
                ],
                itemAsString: (KeyValueModel valueKeyValueModel) => valueKeyValueModel.value,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: textFieldDecoration(textHint: "Pilih jenis izin"),
                ),
                onChanged: (item) {
                  _selectedJenisIzin = item;
                },
              ),
              const SizedBox(height: 12),
              const LabelForm(label: "Pilih Berkas", isRequired: true),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Visibility(
                      visible: _filePath.isEmpty,
                      child: InkWell(
                        onTap: () {
                          showDialog(
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
                                        filePicker();
                                      },
                                      child: ListTile(
                                        leading: Icon(MdiIcons.filePdfBox),
                                        title: const Text("PDF"),
                                      ),
                                    ),
                                    const Divider(),
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
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload_file_outlined,
                              color: AppColor.biru,
                              size: 34,
                            ),
                            Text(
                              "Upload File",
                              style: TextStyle(color: AppColor.biru),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _filePath.isNotEmpty,
                      child: Builder(builder: (context) {
                        if (_filePath.contains("pdf")) {
                          //? PDF FILE
                          return InkWell(
                            onTap: () async {
                              // await OpenFile.open(_filePath);
                            },
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Icon(
                                      MdiIcons.filePdfBox,
                                      color: Colors.red.shade200,
                                      size: 70,
                                    ),
                                  ),
                                  Text(
                                    _fileName,
                                    style: TextStyle(color: Colors.red.shade400),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          //? IMAGE FILE
                          return InkWell(
                            onTap: () => AppNavigator.instance.push(
                              MaterialPageRoute(
                                builder: (context) => ShowImagePage(
                                  judul: "Foto Izin",
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
                          );
                        }
                      }),
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
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const LabelForm(label: "keterangan", isRequired: true),
              const SizedBox(height: 4),
              TextField(
                decoration: textFieldDecoration(textHint: "Tidak wajib"),
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  dismissKeyboard();
                },
                textCapitalization: TextCapitalization.words,
                minLines: 4,
                maxLines: 10,
                controller: _keteranganC,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedJenisIzin == null) {
                    showToast("Jenis izin tidak boleh kosong");
                  } else if (_filePath.isEmpty) {
                    showToast("Berkas izin tidak boleh kosong");
                  } else if (_keteranganC.text.isEmpty) {
                    showToast("Keterangan tidak boleh kosong");
                  } else {
                    dismissKeyboard();
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => const AlertDialogConfirmWidget(message: "Apakah data yang anda masukan sudah benar?"),
                    );

                    if (result ?? false) {
                      final response = await simpanAbsenIzin();
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
}
