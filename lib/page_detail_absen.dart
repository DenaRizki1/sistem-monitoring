import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/model/absen_harian.dart';
import 'package:absentip/my_colors.dart';
import 'package:absentip/utils/api.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/sessions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PageDetailAbsen extends StatefulWidget {
  final Map dataAbsen;
  const PageDetailAbsen({Key? key, required this.dataAbsen}) : super(key: key);

  @override
  State<PageDetailAbsen> createState() => PageDetailAbsenState();
}

class PageDetailAbsenState extends State<PageDetailAbsen> {
  final Completer<GoogleMapController> _controller = Completer();
  bool loading = true;
  Set<Marker> markers = {};
  String nama = "", foto = "";

  AbsenHarian absenHarian = AbsenHarian();

  int index = 0;

  double latitude = 0, longitude = 0;
  // Location location = Location();
  // late PermissionStatus _permissionGranted;

  Map jadwalAbsenMasuk = {};
  Map jadwalAbsenPulang = {};
  Map dataAbsen = {};
  bool jadwal = false;
  bool absen = false;

  @override
  void initState() {
    // TODO: implement initState
    dataAbsen = widget.dataAbsen;
    super.initState();
    getAbsen();
    init();
  }

  @override
  void dispose() {
    // timer?.cancel();
    super.dispose();
  }

  getAbsen() async {
    setState(() {});

    if (dataAbsen.isNotEmpty) {
      if (dataAbsen['jadwal'] != null) {
        jadwal = true;
      }
      if (dataAbsen['absen_masuk']['kd_absen_harian'] != null) {
        log("message");
        jadwalAbsenMasuk = dataAbsen['absen_masuk'];
        setState(() {
          absen = true;
        });
        if (dataAbsen['absen_pulang']['kd_absen_harian'] != null) {
          jadwalAbsenPulang = dataAbsen['absen_pulang'];
        }
      }
    }

    setState(() {
      loading = false;
    });
    log("awnfanfanwkfnawk");
    log(jadwalAbsenMasuk['foto_absen'].toString());

    log(jadwalAbsenMasuk.toString());

    // log(response['absen_masuk'].toString());
  }

  init() async {
    String nm = "", ft = "";
    nm = (await getPrefrence(NAMA))!;
    ft = (await getPrefrence(FOTO))!;

    setState(() {
      nama = nm;
      foto = ft;
    });

    // _permissionGranted = await location.hasPermission();
    // if (_permissionGranted == PermissionStatus.denied) {
    //   _permissionGranted = await location.requestPermission();
    //   if (_permissionGranted != PermissionStatus.granted) {
    //     return;
    //   }
    // }

    final c = await _controller.future;
    // LocationData locationData = await location.getLocation();
    setState(() {
      // latitude = locationData.latitude ?? 0.0;
      // longitude = locationData.longitude ?? 0.0;
      latitude = 0.0;
      longitude = 0.0;
      if (latitude != 0.0 && longitude != 0.0) {
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
      }
    });
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
              "Detail Absen Harian",
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
        body: loading
            ? const Center(child: CupertinoActivityIndicator())
            : !jadwal
                ? const Center(child: Text("Tidak Ada Jadwal"))
                : !absen
                    ? const Center(
                        child: Text("Anda Belum Melakukan Absen Masuk"),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.zero,
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          index = 0;
                                          setState(() {});
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: index == 0 ? AppColor.kuning.withOpacity(0.7) : Colors.white,
                                            border: Border.all(
                                              color: index == 0 ? AppColor.kuning : Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text("Absen Masuk"),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: InkWell(
                                        onTap: jadwalAbsenPulang['kd_absen_harian'] != ""
                                            ? () {
                                                index = 1;
                                                setState(() {});
                                              }
                                            : () {
                                                showToast("Anda Belum Melakukan Absen Pulang");
                                              },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: index == 1
                                                ? AppColor.kuning.withOpacity(0.7)
                                                : jadwalAbsenPulang['kd_absen_harian'] != ""
                                                    ? Colors.white
                                                    : Colors.grey.withOpacity(0.3),
                                            border: Border.all(
                                              color: index == 1 ? AppColor.kuning : Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text("Absen Pulang"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  index == 0 ? absenMasuk() : absenPulang(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget absenMasuk() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(12),
        // color: AppColor.hitam,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(image: NetworkImage(jadwalAbsenMasuk['foto_absen'].toString()), fit: BoxFit.fill),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: jadwalAbsenMasuk['keterangan'] == "1" ? Colors.red.withOpacity(0.4) : Colors.green.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: 160,
                      child: Center(
                        child: Text(
                          jadwalAbsenMasuk['ket_keterangan'],
                          style: TextStyle(color: jadwalAbsenMasuk['keterangan'] == "1" ? Colors.red : Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Lokasi Absen",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      jadwalAbsenMasuk['ket_jenis_absen'],
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Jam Absen",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      jadwalAbsenMasuk['jam_absen'].toString(),
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tanggal Absen",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      parseDateInd(jadwalAbsenMasuk['tgl_absen'].toString(), " EEEE, dd MMMM yyyy"),
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Lokasi Absen",
              style: TextStyle(color: Colors.grey),
            ),
            Container(
              height: 400,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GoogleMap(
                  scrollGesturesEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      safetyParseDouble(jadwalAbsenMasuk['lat'].toString()),
                      safetyParseDouble(jadwalAbsenMasuk['long'].toString()),
                    ),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('1'),
                      position: LatLng(
                        safetyParseDouble(jadwalAbsenMasuk['lat'].toString()),
                        safetyParseDouble(jadwalAbsenMasuk['long'].toString()),
                      ),
                    ),
                  },
                  onMapCreated: (GoogleMapController controller) {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget absenPulang() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(12),
        // color: AppColor.hitam,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(image: NetworkImage(jadwalAbsenPulang['foto_absen'].toString()), fit: BoxFit.fill),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: 160,
                      child: Center(
                        child: Text(
                          jadwalAbsenPulang['ket_keterangan'].toString(),
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Lokasi Absen",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      jadwalAbsenPulang['ket_jenis_absen'].toString(),
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Jam Absen",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      jadwalAbsenPulang['jam_absen'].toString(),
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tanggal Absen",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      parseDateInd(jadwalAbsenPulang['tgl_absen'].toString(), "dd MMMM yyyy"),
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Lokasi Absen",
              style: TextStyle(color: Colors.grey),
            ),
            Container(
              height: 400,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GoogleMap(
                  scrollGesturesEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      safetyParseDouble(jadwalAbsenPulang['lat'].toString()),
                      safetyParseDouble(jadwalAbsenPulang['long'].toString()),
                    ),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('1'),
                      position: LatLng(
                        safetyParseDouble(jadwalAbsenPulang['lat'].toString()),
                        safetyParseDouble(jadwalAbsenPulang['long'].toString()),
                      ),
                    ),
                  },
                  onMapCreated: (GoogleMapController controller) {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
