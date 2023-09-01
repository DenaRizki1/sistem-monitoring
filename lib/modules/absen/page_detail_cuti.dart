// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:absentip/wigets/label_form.dart';
import 'package:absentip/wigets/pdf_view_page.dart';
import 'package:absentip/wigets/show_image_page.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/helpers.dart';

class PageDetailCuti extends StatefulWidget {
  final Map dataAbsen;

  const PageDetailCuti({Key? key, required this.dataAbsen}) : super(key: key);

  @override
  State<PageDetailCuti> createState() => _PageDetailCutiState();
}

class _PageDetailCutiState extends State<PageDetailCuti> {
  Map _dataAbsen = {};

  @override
  void initState() {
    _dataAbsen = widget.dataAbsen;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(parseDateInd(_dataAbsen['tgl_cuti'], "dd MMMM yyyy")),
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
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.biru2,
                  AppColor.biru2.withOpacity(0.6),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          ListView(
            padding: FxSpacing.fromLTRB(16, 0, 16, 16),
            children: [
              FxSpacing.height(16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: Colors.white,
                    child: Stack(
                      children: [
                        Image.asset(
                          AppImages.bgCard1,
                          height: 70,
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          width: double.infinity,
                          height: 70,
                          child: Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _dataAbsen['ket_jenis_cuti'].toString(),
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      FxSpacing.height(4),
                                      Text(
                                        parseDateInd("${_dataAbsen['tgl_cuti']} ${_dataAbsen['jam_cuti']}", "dd MMMM yyyy  HH:mm WIB"),
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                                FxContainer.bordered(
                                  borderRadiusAll: 12,
                                  height: 20,
                                  padding: FxSpacing.xy(8, 2),
                                  border: Border.all(color: AppColor.hitam),
                                  color: AppColor.biru2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FxText.bodySmall(_dataAbsen['ket_status_verifikasi'].toString(), color: Colors.white),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FxSpacing.height(16),
                  const LabelForm(label: "Dokumen Izin", fontSize: 14),
                  FxSpacing.height(4),
                  Builder(builder: (context) {
                    if (_dataAbsen['dokumen'].toString() == "null") {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey,
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 0.5,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Icon(
                                MdiIcons.imageBroken,
                                color: Colors.red.shade200,
                                size: 60,
                              ),
                            ),
                            FxText(
                              "Tidak ada file",
                              textAlign: TextAlign.center,
                              fontSize: 10,
                            ),
                          ],
                        ),
                      );
                    } else if (_dataAbsen['dokumen'].toString().contains("pdf")) {
                      return InkWell(
                        //? PDF FILE;
                        onTap: () {
                          AppNavigator.instance.push(
                            MaterialPageRoute(
                              builder: (context) => PdfViewPage(
                                url: _dataAbsen['dokumen'].toString(),
                                title: "Berkas Izin",
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey,
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width * 0.5,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Icon(
                                  MdiIcons.filePdfBox,
                                  color: Colors.red.shade200,
                                  size: 60,
                                ),
                              ),
                              FxText(
                                _dataAbsen['dokumen'].toString(),
                                textAlign: TextAlign.center,
                                fontSize: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return InkWell(
                        //? IMAGE FILE
                        onTap: () => AppNavigator.instance.push(
                          MaterialPageRoute(
                            builder: (context) => ShowImagePage(
                              judul: "Foto ${_dataAbsen['dokumen'].toString()}",
                              url: _dataAbsen['dokumen'].toString(),
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _dataAbsen['dokumen'].toString(),
                            fit: BoxFit.fill,
                            width: MediaQuery.of(context).size.width,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width * 0.5,
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
                              AppImages.noImage,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width * 0.5,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }
                  }),
                  FxSpacing.height(16),
                  const LabelForm(label: "Lokasi Absen", fontSize: 14),
                  FxSpacing.height(4),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blueGrey,
                    ),
                    padding: const EdgeInsets.all(1),
                    width: double.infinity,
                    height: 240,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GoogleMap(
                        scrollGesturesEnabled: false,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            safetyParseDouble(_dataAbsen['lat'].toString()),
                            safetyParseDouble(_dataAbsen['long'].toString()),
                          ),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('1'),
                            position: LatLng(
                              safetyParseDouble(_dataAbsen['lat'].toString()),
                              safetyParseDouble(_dataAbsen['long'].toString()),
                            ),
                          ),
                        },
                        onMapCreated: (GoogleMapController controller) {},
                      ),
                    ),
                  ),
                ],
              ),
              FxSpacing.height(20),
            ],
          ),
        ],
      ),
    );
  }
}
