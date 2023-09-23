import 'dart:developer';
import 'dart:io';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageAjukanUlangLembur extends StatefulWidget {
  Map? data;
  PageAjukanUlangLembur({Key? key, required this.data}) : super(key: key);

  @override
  State<PageAjukanUlangLembur> createState() => _PageAjukanUlangLemburState();
}

class _PageAjukanUlangLemburState extends State<PageAjukanUlangLembur> {
  final _tglLemburC = TextEditingController();
  final _jamMulaiLemburC = TextEditingController();
  final _jamSelesaiLemburC = TextEditingController();
  final _sesiLemburC = TextEditingController();
  final _durasiLemburC = TextEditingController();
  final _keteranganC = TextEditingController();
  DateTime? _tglLemburDate;
  String _filePath = "";
  String _fileName = "";
  Map? selectedJenisLembur;
  Map? dataLembur;
  ApiStatus _apistatus = ApiStatus.success;

  List items = [
    {'jenis': "Lembur Jam", 'index': 1},
    {'jenis': "Lembur Sesi", 'index': 2},
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    dataLembur = widget.data;
    log(widget.data.toString());
    setTextField();
    super.initState();
  }

  void setTextField() {
    _tglLemburDate = DateTime.parse(dataLembur?['tgl_lembur']);
    _tglLemburC.text = parseDateInd(_tglLemburDate.toString(), "dd MMMM yyyy");
    selectedJenisLembur = items[safetyParseInt(dataLembur?['jenis_lembur']) - 1];
    _sesiLemburC.text = dataLembur?['lama_lembur'];
    _durasiLemburC.text = dataLembur?['lama_sesi'];
    _filePath = dataLembur?['foto_lembur'];
    _keteranganC.text = dataLembur?['keterangan'];
  }

  Future uploadFileLembur() async {
    setState(() {
      _apistatus = ApiStatus.loading;
    });
    final pref = await SharedPreferences.getInstance();

    final response = await ApiConnect.instance.uploadFile(
      EndPoint.uploadFileLembur,
      "file_lembur",
      _filePath,
      {
        'hash_user': pref.getString(HASH_USER)!,
        'token_auth': pref.getString(TOKEN_AUTH)!,
      },
    );

    if (response != null) {
      if (response['success']) {
        setState(() {
          _apistatus = ApiStatus.success;
          _filePath = response['data']['file_url'].toString();
        });
      } else {
        setState(() {
          _apistatus = ApiStatus.failed;
          showToast(response['message']);
        });
      }
    } else {
      setState(() {
        _apistatus = ApiStatus.empty;
        showToast(response?['message']);
      });
    }

    log(response.toString());
  }

  Future<Map<String, dynamic>?> simpanLembur() async {
    await showLoading();

    DateTime dateTime = DateTime.now();
    final pref = await SharedPreferences.getInstance();
    Map<String, String> params = {
      'token_auth': pref.getString(TOKEN_AUTH).toString(),
      'hash_user': pref.getString(HASH_USER).toString(),
      'time_zone_name': dateTime.timeZoneName,
      'time_zone_offset': dateTime.timeZoneOffset.inHours.toString(),
      'jenis_lembur': selectedJenisLembur?['index'].toString() ?? "",
      'file_lembur': _filePath,
      'sesi': _sesiLemburC.text,
      'tgl_lembur': parseDateInd(_tglLemburDate.toString(), "yyyy-MM-dd"),
      'jam_mulai': parseDateInd(_jamMulaiLemburC.text.toString(), "HH:mm:ss"),
      'jam_selesai': parseDateInd(_jamSelesaiLemburC.text.toString(), "HH:mm:ss"),
      'durasi_lembur': _durasiLemburC.text.toString().trim(),
      'keterangan': _keteranganC.text.toString().trim(),
    };

    Map<String, dynamic>? response;

    response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.ajukanUlangLembur,
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
        setState(() {
          _filePath = imageFile?.path ?? "";
          _fileName = imageFile?.name ?? "foto_absen";
        });
      }

      uploadFileLembur();
    } else {
      log("You have not taken image");
    }
  }

  Future cekDurasiLembur() async {
    final pref = await SharedPreferences.getInstance();

    await showLoading();

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.cekDurasiLembur,
      params: {
        'hash_user': pref.getString(HASH_USER)!,
        'token_auth': pref.getString(TOKEN_AUTH)!,
        'jam_mulai': _jamMulaiLemburC.text,
        'jam_selsai': _jamSelesaiLemburC.text,
      },
    );

    await dismissLoading();

    if (response != null) {
      if (response['success']) {
        _durasiLemburC.text = response['data'].toString();
      } else {
        final result = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialogOkWidget(message: response['message']);
          },
        );
        if (result) {
          AppNavigator.instance.pop();
        }
      }
    } else {
      final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialogOkWidget(message: response?['message']);
        },
      );

      if (result) {
        AppNavigator.instance.pop();
      }
    }

    log(response.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Tambah Pengajuan Lembur"),
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
              const LabelForm(label: "Tanggal Lembur", isRequired: true),
              const SizedBox(height: 4),
              TextField(
                decoration: textFieldDecoration(textHint: "Pilih Tanggal Lembur"),
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.none,
                controller: _tglLemburC,
                readOnly: true,
              ),
              const SizedBox(height: 12),
              const LabelForm(label: "Jenis Lembur", isRequired: true),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    borderRadius: BorderRadius.circular(12),
                    hint: selectedJenisLembur == null ? const Text("Pilih Jenis Cuti") : Text(selectedJenisLembur?['jenis'].toString() ?? ""),
                    items: items.map(
                      (val) {
                        return DropdownMenuItem(
                          value: val,
                          child: Text(val['jenis'].toString()),
                        );
                      },
                    ).toList(),
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    onChanged: (val) {
                      log(val.toString());
                      setState(() {
                        selectedJenisLembur = val as Map?;
                        _jamMulaiLemburC.text = "";
                        _jamSelesaiLemburC.text = "";
                        _sesiLemburC.text = "";
                        _durasiLemburC.text = "";
                      });
                    },
                  ),
                ),
              ),
              Visibility(
                visible: selectedJenisLembur != null && selectedJenisLembur?['index'] == 1,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const LabelForm(label: "Jam Mulai Lembur", isRequired: true),
                    const SizedBox(height: 4),
                    TextField(
                      decoration: textFieldDecoration(textHint: "Masukan Jam Mulai Lembur"),
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.none,
                      controller: _jamMulaiLemburC,
                      readOnly: true,
                      onTap: () {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        ).then((value) {
                          if (value != null) {
                            _jamMulaiLemburC.text = parseDateInd(
                              DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                                value.hour,
                                value.minute,
                              ).toString(),
                              "HH:mm",
                            );

                            setState(() {});
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: selectedJenisLembur != null && selectedJenisLembur?['index'] == 1,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const LabelForm(label: "Jam Selesai Lembur", isRequired: true),
                    const SizedBox(height: 4),
                    TextField(
                      decoration: textFieldDecoration(textHint: "Masukan Jam Selesai Lembur"),
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.none,
                      controller: _jamSelesaiLemburC,
                      readOnly: true,
                      onTap: _jamMulaiLemburC.text != ""
                          ? () {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              ).then((value) {
                                if (value != null) {
                                  _jamSelesaiLemburC.text = parseDateInd(
                                    DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                      value.hour,
                                      value.minute,
                                    ).toString(),
                                    "HH:mm",
                                  );

                                  cekDurasiLembur();
                                }
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: selectedJenisLembur != null && selectedJenisLembur?['index'] == 2,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const LabelForm(label: "Sesi Lembur", isRequired: true),
                    const SizedBox(height: 4),
                    TextField(
                      decoration: textFieldDecoration(textHint: "Masukan Sesi Lembur"),
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.none,
                      controller: _sesiLemburC,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            _durasiLemburC.text = (safetyParseInt(value) * 90).toString();
                          });
                        } else {
                          _durasiLemburC.text = "";
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              selectedJenisLembur?['index'] == 1 ? const LabelForm(label: "Durasi Lembur ( Jam )", isRequired: true) : const LabelForm(label: "Durasi Lembur ( Menit )", isRequired: true),
              const SizedBox(height: 4),
              TextField(
                decoration: textFieldDecoration(textHint: "Masukan Durasi Lembur"),
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.none,
                controller: _durasiLemburC,
                keyboardType: TextInputType.number,
                readOnly: true,
              ),
              const SizedBox(height: 12),
              const LabelForm(label: "Pilih Berkas", isRequired: false),
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
                        if (_apistatus == ApiStatus.success) {
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
                                    judul: "Foto Lembur",
                                    url: _filePath,
                                  ),
                                ),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _filePath,
                                    fit: BoxFit.fill,
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
                        } else if (_apistatus == ApiStatus.loading) {
                          return Center(
                            child: loadingWidget(),
                          );
                        } else if (_apistatus == ApiStatus.empty) {
                          return const Center(
                            child: Text("Foto tidak di temukan"),
                          );
                        } else {
                          return const Center(
                            child: Text("Terjasi kesalahan"),
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
                decoration: textFieldDecoration(textHint: "Masukan keterangan Lembur"),
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  dismissKeyboard();
                },
                textCapitalization: TextCapitalization.sentences,
                minLines: 4,
                maxLines: 10,
                controller: _keteranganC,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  log(_tglLemburDate.toString());
                  if (_tglLemburDate == null) {
                    showToast("Tanggal lembur tidak boleh kosong");
                  } else if (selectedJenisLembur?['index'] == 1 && _jamMulaiLemburC.text.toString().isEmpty) {
                    showToast("Jam mulai lembur tidak boleh kosong");
                  } else if (selectedJenisLembur?['index'] == 1 && _jamSelesaiLemburC.text.toString().isEmpty) {
                    showToast("Jam Selsai lembur tidak boleh kosong");
                  } else if (selectedJenisLembur?['index'] == 2 && _sesiLemburC.text.toString().isEmpty) {
                    showToast("Sesi Lembur tidak boleh kosong");
                  } else if (_durasiLemburC.text.toString().isEmpty) {
                    showToast("Durasi lembur tidak boleh kosong");
                  } else if (_keteranganC.text.toString().isEmpty) {
                    showToast("Keterangan tidak boleh kosong");
                  } else {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => const AlertDialogConfirmWidget(message: "Apakah data yang anda masukan sudah benar?"),
                    );

                    if (result ?? false) {
                      final response = await simpanLembur();
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
