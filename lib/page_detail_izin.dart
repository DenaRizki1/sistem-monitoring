import 'dart:developer';

import 'package:absentip/my_colors.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/text_montserrat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as ext;
// import 'package:url_launcher/url_launcher.dart';

class PageDetailIzin extends StatefulWidget {
  final bool pageIzin;
  final Map data;
  const PageDetailIzin({Key? key, required this.data, required this.pageIzin}) : super(key: key);

  @override
  State<PageDetailIzin> createState() => _PageDetailIzinState();
}

class _PageDetailIzinState extends State<PageDetailIzin> {
  Map? data;
  bool pageIzin = true;
  String nama = "", image = "", extension = "";

  @override
  void initState() {
    // TODO: implement initState
    getNama();
    data = widget.data;
    pageIzin = widget.pageIzin;
    super.initState();
    log(data.toString());
  }

  getNama() async {
    final pref = await SharedPreferences.getInstance();

    setState(() {
      nama = pref.getString(NAMA)!;
    });
    final _extension = ext.extension(data!['dokumen'].toString());
    extension = _extension;
    log(extension);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: const Image(
            image: AssetImage(AppImages.bg2),
            fit: BoxFit.cover,
          ),
          centerTitle: true,
          // systemOverlayStyle: SystemUiOverlayStyle.dark,
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
          title: SizedBox(
            // width: double.infinity,
            child: Text(
              pageIzin ? parseDateInd(data!['tgl_izin'].toString(), "EEE dd MMMM yyyy") : parseDateInd(data!['tgl_cuti'].toString(), "EEE dd MMMM yyyy"),
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
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 100,
                        width: double.infinity,
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextMontserrat(
                                        text: nama,
                                        fontSize: 18,
                                        color: colorPrimary,
                                      ),
                                      SizedBox(height: 6),
                                      TextMontserrat(
                                        text: pageIzin
                                            ? "${parseDateInd(data!['tgl_izin'].toString(), "EEEE MM dd yyyy")} ${parseDateInd(data!['jam_izin'], "00:00:00")}"
                                            : "${parseDateInd(data!['tgl_cuti'].toString(), "EEEE MM dd yyyy")} ${parseDateInd(data!['jam_cuti'], "00:00:00")}",
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: colorPrimary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: colorPrimary),
                                    ),
                                    child: TextMontserrat(
                                      text: pageIzin ? data!['ket_jenis_izin'].toString() : data!['ket_jenis_cuti'].toString(),
                                      fontSize: 10,
                                      color: colorPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Image.asset(
                        AppImages.bgCard1,
                        color: colorPrimary,
                        height: 100,
                      ),
                    ],
                  ),
                  SizedBox(height: 14),
                  TextMontserrat(
                    text: "Dokumen Izin",
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  SizedBox(height: 8),
                  extension == ".jpg"
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            data!['dokumen'].toString(),
                            fit: BoxFit.fill,
                            width: MediaQuery.of(context).size.width,
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: InkWell(
                                onTap: () {
                                  final url = "https://docs.google.com/gview?embedded=true&url=${data!['dokumen']}";
                                  // final url = "https://docs.google.com/gview?embedded=true&url=https://apps.batikbalilestari.com/files/tutorial/Cara_Membuat_Penjualan.pdf";
                                  // log(url);
                                  _launchInWebViewOrVC(Uri.parse(url));
                                },
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf,
                                      size: 50,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 10),
                                    TextMontserrat(
                                      text: data!['dokumen'],
                                      fontSize: 14,
                                      color: Colors.blue,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                  SizedBox(height: 14),
                  TextMontserrat(
                    text: "Lokasi",
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  SizedBox(height: 8),
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
                            safetyParseDouble(data!['lat'].toString()),
                            safetyParseDouble(data!['long'].toString()),
                          ),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('1'),
                            position: LatLng(
                              safetyParseDouble(data!['lat'].toString()),
                              safetyParseDouble(data!['long'].toString()),
                            ),
                          ),
                        },
                        onMapCreated: (GoogleMapController controller) {},
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchInWebViewOrVC(Uri url) async {
    // if (!await launchUrl(
    //   url,
    //   mode: LaunchMode.inAppWebView,
    //   webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
    // )) {
    //   throw Exception('Could not launch $url');
    // }
  }
}
