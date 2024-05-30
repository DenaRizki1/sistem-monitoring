import 'dart:developer';

import 'package:sistem_monitoring/utils/app_color.dart';
import 'package:sistem_monitoring/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sistem_monitoring/wigets/appbar_widget.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  static const routeName = '/history-page';

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List data = [
    {"tanggal": parseDateInd(DateTime.now().subtract(Duration(days: 5)).toString(), "EEEE, dd MMMM yyyy"), "temp_max": 32.4, "hum_max": 74.2, "light_max": 120, "gas_max": 2000},
    {"tanggal": parseDateInd(DateTime.now().subtract(Duration(days: 5)).toString(), "EEEE, dd MMMM yyyy"), "temp_max": 32.4, "hum_max": 74.2, "light_max": 120, "gas_max": 2000},
    {"tanggal": parseDateInd(DateTime.now().subtract(Duration(days: 4)).toString(), "EEEE, dd MMMM yyyy"), "temp_max": 32.4, "hum_max": 74.2, "light_max": 120, "gas_max": 2000},
    {"tanggal": parseDateInd(DateTime.now().subtract(Duration(days: 4)).toString(), "EEEE, dd MMMM yyyy"), "temp_max": 32.4, "hum_max": 74.2, "light_max": 120, "gas_max": 2000},
    {"tanggal": parseDateInd(DateTime.now().subtract(Duration(days: 3)).toString(), "EEEE, dd MMMM yyyy"), "temp_max": 32.4, "hum_max": 74.2, "light_max": 120, "gas_max": 2000},
    {"tanggal": parseDateInd(DateTime.now().subtract(Duration(days: 3)).toString(), "EEEE, dd MMMM yyyy"), "temp_max": 32.4, "hum_max": 74.2, "light_max": 120, "gas_max": 2000},
    {"tanggal": parseDateInd(DateTime.now().subtract(Duration(days: 3)).toString(), "EEEE, dd MMMM yyyy"), "temp_max": 32.4, "hum_max": 74.2, "light_max": 120, "gas_max": 2000},
    {"tanggal": parseDateInd(DateTime.now().subtract(Duration(days: 2)).toString(), "EEEE, dd MMMM yyyy"), "temp_max": 32.4, "hum_max": 74.2, "light_max": 120, "gas_max": 2000},
    {"tanggal": parseDateInd(DateTime.now().subtract(Duration(days: 2)).toString(), "EEEE, dd MMMM yyyy"), "temp_max": 32.4, "hum_max": 74.2, "light_max": 120, "gas_max": 2000},
    {"tanggal": parseDateInd(DateTime.now().subtract(Duration(days: 2)).toString(), "EEEE, dd MMMM yyyy"), "temp_max": 32.4, "hum_max": 74.2, "light_max": 120, "gas_max": 2000},
    {"tanggal": parseDateInd(DateTime.now().subtract(Duration(days: 2)).toString(), "EEEE, dd MMMM yyyy"), "temp_max": 32.4, "hum_max": 74.2, "light_max": 120, "gas_max": 2000},
    {"tanggal": parseDateInd(DateTime.now().subtract(Duration(days: 1)).toString(), "EEEE, dd MMMM yyyy"), "temp_max": 32.4, "hum_max": 74.2, "light_max": 120, "gas_max": 2000},
    {"tanggal": parseDateInd(DateTime.now().toString(), "EEEE, dd MMMM yyyy"), "temp_max": 32.4, "hum_max": 74.2, "light_max": 120, "gas_max": 2000},
    {"tanggal": parseDateInd(DateTime.now().toString(), "EEEE, dd MMMM yyyy"), "temp_max": 32.4, "hum_max": 74.2, "light_max": 120, "gas_max": 2000},
    {"tanggal": parseDateInd(DateTime.now().toString(), "EEEE, dd MMMM yyyy"), "temp_max": 32.4, "hum_max": 74.2, "light_max": 120, "gas_max": 2000},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("History Page"),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          Map history = data[index] as Map;
          bool showdate = false;
          if (index == 0) {
            showdate = true;
          } else if (data[index]['tanggal'].toString() != data[index - 1]['tanggal'].toString()) {
            showdate = true;
          } else {
            showdate = false;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: showdate,
                child: Row(
                  children: [
                    Icon(MdiIcons.calendar),
                    const SizedBox(width: 12),
                    Text(
                      parseDateInd(history['tanggal'].toString(), "EEEE, dd MMMM yyyy"),
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: AppColor.secondPrimary,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          history['tanggal'].toString(),
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(
                          width: double.infinity,
                          child: Divider(
                            color: Colors.white,
                            thickness: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 99,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Max Temp",
                                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        history['temp_max'].toString(),
                                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        MdiIcons.temperatureCelsius,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 99,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Max Hum",
                                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        history['hum_max'].toString(),
                                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        MdiIcons.temperatureCelsius,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 99,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Max Light",
                                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        history['light_max'].toString(),
                                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Lux",
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 99,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Max Gas",
                                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        history['gas_max'].toString(),
                                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "PPM",
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
