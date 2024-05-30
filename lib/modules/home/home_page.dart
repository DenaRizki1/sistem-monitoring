import 'dart:convert';
import 'dart:developer';

import 'package:sistem_monitoring/modules/history/history_page.dart';
import 'package:sistem_monitoring/utils/app_color.dart';
import 'package:sistem_monitoring/utils/helpers.dart';
import 'package:sistem_monitoring/utils/routes/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:web_socket_channel/io.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const routeName = "home-page";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final channel = IOWebSocketChannel.connect('ws://192.168.10.113:3000');

  List sensor = [];

  @override
  void initState() {
    streamListener();
    sensor = [
      {"id": 1, "title": "Suhu", "icon": MdiIcons.homeThermometerOutline, "icon_text": MdiIcons.temperatureCelsius},
      {"id": 2, "title": "Humidity", "icon": MdiIcons.waterPercent, "icon_text": MdiIcons.percent},
      {"id": 3, "title": "Cahaya", "icon": MdiIcons.lightbulb, "icon_text": MdiIcons.temperatureCelsius},
      {"id": 4, "title": "Gas", "icon": MdiIcons.moleculeCo2, "icon_text": MdiIcons.temperatureCelsius},
    ];
    super.initState();
  }

  streamListener() async {
    await channel.ready;
    channel.stream.listen((event) {
      Map data = jsonDecode(event);
      for (var i = 0; i < sensor.length; i++) {
        switch (i) {
          case 0:
            sensor[i]['data'] = data['temp'];
            break;
          case 1:
            sensor[i]['data'] = data['hum'];
            break;
          case 2:
            sensor[i]['data'] = data['temp'];
            break;
          case 3:
            sensor[i]['data'] = data['temp'];
            break;
          default:
        }
      }
      setState(() {});
    }, onError: (error) => log(error));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            padding: EdgeInsets.only(top: 20, left: 20, bottom: MediaQuery.of(context).size.height * .1, right: 12),
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Selamat Datang Di",
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.normal, color: Colors.white),
                    ),
                    Text(
                      "Sistem Monitoring",
                      style: GoogleFonts.poppins(color: Colors.white),
                    )
                  ],
                ),
                const Spacer(),
                Icon(
                  MdiIcons.bellOutline,
                  color: Colors.white,
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: AppColor.secondPrimary,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            parseDateInd(DateTime.now().toString(), "EEEE, dd MMMM yyyy"),
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                          Text(
                            parseDateInd(DateTime.now().toString(), "HH:mm"),
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                        ],
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          AppNavigator.instance.pushNamed(HistoryPage.routeName);
                        },
                        child: Icon(
                          MdiIcons.history,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Kondisi Ruangan",
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                              const VerticalDivider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                              Expanded(
                                  child: Text(
                                "Baik",
                                style: GoogleFonts.poppins(),
                                textAlign: TextAlign.right,
                              ))
                            ],
                          ),
                        ),
                        const Divider(
                          color: Colors.black,
                          thickness: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tidak ada tindakan yang harus dilakukan. Tetap jaga kondisi ruangan seperti ini",
                          style: GoogleFonts.poppins(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Sensor",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 4,
              width: double.infinity,
              child: Divider(
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: 4,
            itemBuilder: (context, index) {
              if (sensor.isNotEmpty) {
                Map sensors = sensor[index] as Map;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.secondPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            sensors['icon'],
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            sensors['title']?.toString() ?? "-",
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          )
                        ],
                      ),
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            sensors['data']?.toString() ?? "0",
                            style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            sensors['icon_text'],
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.secondPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
