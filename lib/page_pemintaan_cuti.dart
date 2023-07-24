import 'dart:developer';
import 'dart:io';

import 'package:absentip/alert_dialog_confirm_widget.dart';
import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/my_colors.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/utils/text_montserrat.dart';
import 'package:absentip/wigets/alert_dialog_oke_widget.dart';
import 'package:absentip/wigets/label_form.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PagePermintaanCuti extends StatefulWidget {
  final Map data;
  final Position currentLocation;
  final String lokasi;
  PagePermintaanCuti({
    Key? key,
    required this.data,
    required this.currentLocation,
    required this.lokasi,
  }) : super(key: key);

  @override
  State<PagePermintaanCuti> createState() => _PagePermintaanCutiState();
}

class _PagePermintaanCutiState extends State<PagePermintaanCuti> {
  DateTime? selectedStartDate, selectedEndDate;
  final TextEditingController _cutiTC = TextEditingController();

  late bool _serviceEnabled;

  final TextEditingController _keteranganC = TextEditingController();

  FilePickerResult? resultFile;
  String dataFile = "", filePdfName = "", lokasi = "";
  bool fileImg = true;
  Map? _selectedJenisCuti;
  Position? _currentLocation;

  List items = [
    {'jenis': "Cuti Tahunan", 'index': 1},
    {'jenis': "Cuti Lahiran", 'index': 2},
    {'jenis': "Cuti Lainnya", 'index': 3},
  ];

  Map? dataCekAbsen;
  @override
  void initState() {
    // TODO: implement initState
    dataCekAbsen = widget.data;
    _currentLocation = widget.currentLocation;
    lokasi = widget.lokasi;
    log("Data");
    log(lokasi);
    log(dataCekAbsen.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          flexibleSpace: const Image(
            image: AssetImage(AppImages.bg2),
            fit: BoxFit.cover,
          ),
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
              "Permintaan Cuti",
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.black,
                overflow: TextOverflow.ellipsis,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextMontserrat(
                      text: "Tanggal Cuti",
                      fontSize: 14,
                      bold: true,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(DateTime.now().year, 12, 31),
                        ).then(
                          (value) {
                            if (value != null) {
                              setState(() {
                                selectedStartDate = value.start;
                                selectedEndDate = value.end;
                              });

                              DateTimeRange dateRange = DateTimeRange(start: selectedStartDate!, end: selectedEndDate!);
                              _cutiTC.text = (int.parse(dateRange.duration.toString().replaceAll(":00:00.000000", "")) / 24 + 1).toStringAsFixed(0) + " Hari";
                            }
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorPrimary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              TextMontserrat(
                                text: "Range Tanggal",
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextMontserrat(
                                    text: selectedStartDate == null
                                        ? "${parseDateInd(DateTime.now().toString(), "dd MMM yyyy")} sd ${parseDateInd(DateTime.now().toString(), "dd MMM yyyy")}"
                                        : "${parseDateInd(selectedStartDate!.toString(), "dd MMM yyyy")} sd ${parseDateInd(selectedEndDate!.toString(), "dd MMM yyyy")}",
                                    fontSize: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    MdiIcons.chevronDown,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextMontserrat(
                          text: "Jumlah Cuti",
                          fontSize: 14,
                          bold: true,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cutiTC,
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: "Jumlah Cuti (Hari)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextMontserrat(
                          text: "Jenis Cuti",
                          fontSize: 14,
                          bold: true,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              borderRadius: BorderRadius.circular(12),
                              hint: _selectedJenisCuti == null ? Text("Pilih Jenis Cuti") : Text(_selectedJenisCuti?['jenis'].toString() ?? ""),
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
                                  _selectedJenisCuti = val as Map?;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextMontserrat(
                      text: "Keterangan",
                      fontSize: 14,
                      bold: true,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 5 * 20.0,
                      child: TextField(
                        controller: _keteranganC,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Keterangan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextMontserrat(
                      text: "Berkas Cuti",
                      fontSize: 14,
                      bold: true,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 8),
                    fileImg && dataFile != ""
                        ? Stack(
                            children: [
                              Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 160,
                                    minWidth: double.infinity,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      pilihSumber();
                                    },
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                        height: 400,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                          image: DecorationImage(
                                              image: FileImage(
                                                File(dataFile),
                                              ),
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                    ),
                                  )
                                  // : ElevatedButton(
                                  //     onPressed: () {
                                  //       pilihSumber();
                                  //     },
                                  //     child: Row(
                                  //       mainAxisAlignment: MainAxisAlignment.center,
                                  //       children: [
                                  //         Icon(Icons.add_a_photo_outlined),
                                  //         SizedBox(width: 10),
                                  //         Text(
                                  //           "Tambah Foto",
                                  //           style: TextStyle(
                                  //             fontSize: 16,
                                  //             fontWeight: FontWeight.bold,
                                  //           ),
                                  //         )
                                  //       ],
                                  //     ),
                                  //     style: ElevatedButton.styleFrom(backgroundColor: AppColor.orange),
                                  //   ),
                                  ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    dataFile = "";
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorPrimary,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.red, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ) //tampil image
                        : !fileImg && dataFile != ""
                            ? Stack(
                                children: [
                                  Container(
                                      constraints: const BoxConstraints(
                                        minHeight: 160,
                                        minWidth: double.infinity,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          pilihSumber();
                                        },
                                        child: Center(
                                          child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                              width: double.infinity,
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.picture_as_pdf,
                                                    color: Colors.red,
                                                    size: 40,
                                                  ),
                                                  SizedBox(height: 5),
                                                  TextMontserrat(
                                                    text: filePdfName,
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    textAlign: TextAlign.center,
                                                  )
                                                ],
                                              )),
                                        ),
                                      )
                                      // : ElevatedButton(
                                      //     onPressed: () {
                                      //       pilihSumber();
                                      //     },
                                      //     child: Row(
                                      //       mainAxisAlignment: MainAxisAlignment.center,
                                      //       children: [
                                      //         Icon(Icons.add_a_photo_outlined),
                                      //         SizedBox(width: 10),
                                      //         Text(
                                      //           "Tambah Foto",
                                      //           style: TextStyle(
                                      //             fontSize: 16,
                                      //             fontWeight: FontWeight.bold,
                                      //           ),
                                      //         )
                                      //       ],
                                      //     ),
                                      //     style: ElevatedButton.styleFrom(backgroundColor: AppColor.orange),
                                      //   ),
                                      ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        dataFile = "";
                                        filePdfName = "";
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorPrimary,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.red, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                constraints: const BoxConstraints(
                                  minHeight: 160,
                                  minWidth: double.infinity,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    pilihSumber();
                                  },
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                      width: 140,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            MdiIcons.plus,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 5),
                                          TextMontserrat(
                                            text: "Tambah Foto",
                                            fontSize: 14,
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                // : ElevatedButton(
                                //     onPressed: () {
                                //       pilihSumber();
                                //     },
                                //     child: Row(
                                //       mainAxisAlignment: MainAxisAlignment.center,
                                //       children: [
                                //         Icon(Icons.add_a_photo_outlined),
                                //         SizedBox(width: 10),
                                //         Text(
                                //           "Tambah Foto",
                                //           style: TextStyle(
                                //             fontSize: 16,
                                //             fontWeight: FontWeight.bold,
                                //           ),
                                //         )
                                //       ],
                                //     ),
                                //     style: ElevatedButton.styleFrom(backgroundColor: AppColor.orange),
                                //   ),
                                ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (_selectedJenisCuti == null) {
                          showToast("Jenis Cuti Tidak Boleh Kosong");
                        } else if (dataFile.isEmpty) {
                          showToast("Berkas Cuti tidak boleh kosong");
                        } else if (_keteranganC.text.isEmpty) {
                          showToast("Keterangan tidak boleh kosong");
                        } else {
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (context) => const AlertDialogConfirmWidget(message: "Apakah data yang anda masukan sudah benar?"),
                          );

                          if (result ?? false) {
                            final response = await simpanAbsenCuti();
                            if (response != null) {
                              if (response['success']) {
                                final result = await showDialog<bool>(context: context, builder: (context) => AlertDialogOkWidget(message: response['message'].toString()));
                                if (result ?? false) {
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                  }
                                }
                                Navigator.of(context).pop();
                              } else {
                                showToast(response['message'].toString());
                              }
                            }
                          }
                        }
                      },
                      child: TextMontserrat(
                        text: "Simpan",
                        fontSize: 14,
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pilihSumber() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop("kamera");
              },
              child: const ListTile(
                leading: Icon(Icons.camera),
                title: Text("Kamera"),
              ),
            ),
            const Divider(),
            InkWell(
              onTap: () {
                Navigator.of(context).pop("galery");
              },
              child: const ListTile(
                leading: Icon(Icons.folder),
                title: Text("Galeri"),
              ),
            ),
            const Divider(),
            InkWell(
              onTap: () {
                Navigator.of(context).pop("pdf");
              },
              child: const ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text("PDF"),
              ),
            ),
          ],
        ),
      ),
    );

    XFile? imageFile;
    PlatformFile? pickedFile;
    String filePath = "";
    String? file;

    if (result == "galery") {
      //? open camera
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
    } else if (result == "kamera") {
      //? open galery
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
    } else if (result == "pdf") {
      log("PDF");
      if (Platform.isIOS) {
        try {
          // imageFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
          resultFile = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
          );

          if (resultFile != null) {
            file = resultFile!.files.first.name;
            PlatformFile pickedFile = resultFile!.files.first;

            log(file);
          } else {
            // User canceled the picker
          }
        } catch (e) {
          PermissionStatus permission = await Permission.storage.status;
          if (permission != PermissionStatus.granted) {
            alertOpenSetting(context);
          }
        }
      } else {
        // try {
        resultFile = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (resultFile != null) {
          file = resultFile!.files.first.name;
          pickedFile = resultFile!.files.first;

          filePath = pickedFile.path.toString();

          log(pickedFile.path.toString());
        } else {
          // User canceled the picker
        }
        // } catch (e) {
        //   PermissionStatus permission = await Permission.storage.status;
        //   if (permission == PermissionStatus.denied) {
        //     //? Requesting the permission
        //     PermissionStatus statusDenied = await Permission.storage.request();
        //     if (statusDenied.isPermanentlyDenied) {
        //       //? permission isPermanentlyDenied
        //       alertOpenSetting(context);
        //     }
        //   }
        // }
      }
    }

    if (imageFile != null && filePath == "") {
      setState(() {
        dataFile = imageFile!.path.toString();
        fileImg = true;
        filePdfName = "";
      });
    } else if (imageFile == null && pickedFile != null) {
      setState(() {
        dataFile = filePath;
        fileImg = false;
        filePdfName = file!;
      });

      // await uploadFoto(filePath);
    }
  }

  Future<Map<String, dynamic>?> simpanAbsenCuti() async {
    if (dataFile != null) {
      await showLoading();

      log(dataFile);

      final pref = await SharedPreferences.getInstance();

      DateTime dateTime = DateTime.now();

      final response = await ApiConnect.instance.uploadFile(
        EndPoint.urlSimpanAbsenCuti,
        'foto',
        dataFile,
        {
          'token_auth': pref.getString(TOKEN_AUTH)!,
          'hash_user': pref.getString(HASH_USER)!,
          'jenis_cuti': _selectedJenisCuti!['index'].toString(),
          'mulai_cuti': selectedStartDate.toString(),
          'selesai_cuti': selectedEndDate.toString(),
          'lat': _currentLocation!.latitude.toString(),
          'long': _currentLocation!.longitude.toString(),
          'keterangan': _keteranganC.text.toString().trim(),
          'kd_tanda': dataCekAbsen!['kd_tanda'],
        },
      );

      // final params = {
      //   'token_auth': pref.getString(TOKEN_AUTH)!,
      //   'hash_user': pref.getString(HASH_USER)!,
      //   'jenis_izin': _selectedJenisIzin!['index'].toString(),
      //   'time_zone_name': dateTime.timeZoneName,
      //   'time_zone_offset': dateTime.timeZoneOffset.inHours.toString(),
      //   'lat': _currentLocation!.latitude.toString(),
      //   'long': _currentLocation!.longitude.toString(),
      //   'keterangan': _keteranganC.text.toString().trim(),
      //   'kd_tanda': dataCekAbsen!['kd_tanda'],
      // };

      // log(params.toString());

      await dismissLoading();

      log(response.toString());

      return response;
    }
  }

  // Future<void> uploadFoto(XFile? imageFile) async {
  //   if (imageFile != null) {
  //     // log("You selected  image : ${imageFile.path}");
  //     //! upload file to server
  //     await showLoading();
  //     File compressedFile = await FlutterNativeImage.compressImage(imageFile.path);

  //     final pref = await SharedPreferences.getInstance();

  //     final response = await ApiConnect.instance.uploadFile(
  //       EndPoints.uploadFotoTransaksi,
  //       "foto_transaksi",
  //       compressedFile.path,
  //       {
  //         'hash_user': pref.getString(KeySession.HASH_USER) ?? "",
  //         'token_auth': pref.getString(KeySession.TOKEN_AUTH) ?? "",
  //       },
  //     );

  //     if (response != null) {
  //       if (response['success']) {
  //         final data = response['data'];
  //         setState(() {
  //           _urlFoto = data['url'];
  //           imageList.add(_urlFoto);
  //         });
  //       }
  //       showToast(response['message'].toString());
  //     }
  //   } else {
  //     log("You have not taken image");
  //   }

  //   for (int i = 0; i < imageList.length; i++) {
  //     log(imageList[i] + " Data File");
  //   }
  // }
}
