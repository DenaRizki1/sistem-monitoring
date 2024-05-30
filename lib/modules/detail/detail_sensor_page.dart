import 'package:sistem_monitoring/model/chart_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DetailSensorPage extends StatefulWidget {
  const DetailSensorPage({Key? key}) : super(key: key);

  static const routeName = "/detailSensorPage";

  @override
  State<DetailSensorPage> createState() => _DetailSensorPageState();
}

class _DetailSensorPageState extends State<DetailSensorPage> {
  late List<ChartData> dataTemp;

  @override
  void initState() {
    dataTemp = [
      ChartData(25, 0, 60, 50),
      ChartData(27, 3, 62, 60),
      ChartData(26, 4, 64, 63),
      ChartData(28, 5, 62, 64),
      ChartData(30, 6, 63, 62),
      ChartData(30, 7, 65, 10),
      ChartData(29, 8, 66, 20),
      ChartData(30, 9, 67, 30),
      ChartData(32, 12, 69, 40),
      ChartData(33, 14, 70, 70),
      ChartData(32, 16, 74, 70),
      ChartData(31, 18, 47, 80),
      ChartData(28, 20, 79, 74),
    ];
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Page")),
      body: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    MdiIcons.homeThermometerOutline,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Temperatur",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: SfCartesianChart(
                  margin: const EdgeInsets.all(0),
                  borderWidth: 0,
                  borderColor: Colors.transparent,
                  plotAreaBorderWidth: 0,

                  primaryXAxis: NumericAxis(
                    minimum: 0,
                    maximum: 20,
                    interval: 6,
                    isVisible: true,
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 21,
                    maximum: 39,
                    isVisible: true,
                    borderColor: Colors.transparent,
                    borderWidth: 0,
                  ),
                  // plotAreaBackgroundColor: Colors.black,
                  series: <ChartSeries<ChartData, int>>[
                    SplineAreaSeries(
                      dataSource: dataTemp,
                      xValueMapper: (ChartData data, _) => data.hour,
                      yValueMapper: (ChartData data, _) => data.temp,
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withOpacity(0.7),
                          Colors.yellow.withOpacity(0.5),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      splineType: SplineType.natural,
                    ),
                    SplineSeries(
                      dataSource: dataTemp,
                      color: Colors.orange,
                      width: 4,
                      markerSettings: const MarkerSettings(
                        color: Colors.black,
                        borderColor: Colors.black,
                        shape: DataMarkerType.circle,
                        isVisible: true,
                      ),
                      xValueMapper: (ChartData data, _) => data.hour,
                      yValueMapper: (ChartData data, _) => data.temp,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    MdiIcons.waterThermometerOutline,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Kelembaban",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: SfCartesianChart(
                  margin: const EdgeInsets.all(0),
                  borderWidth: 0,
                  borderColor: Colors.transparent,
                  plotAreaBorderWidth: 0,

                  primaryXAxis: NumericAxis(
                    minimum: 0,
                    maximum: 20,
                    interval: 6,
                    isVisible: true,
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 20,
                    maximum: 90,
                    interval: 10,
                    isVisible: true,
                    borderColor: Colors.transparent,
                    borderWidth: 0,
                  ),
                  // plotAreaBackgroundColor: Colors.black,
                  series: <ChartSeries<ChartData, int>>[
                    SplineAreaSeries(
                      dataSource: dataTemp,
                      xValueMapper: (ChartData data, _) => data.hour,
                      yValueMapper: (ChartData data, _) => data.hum,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.7),
                          Colors.blueAccent.withOpacity(0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      splineType: SplineType.natural,
                    ),
                    SplineSeries(
                      dataSource: dataTemp,
                      color: Colors.blue,
                      width: 4,
                      markerSettings: const MarkerSettings(
                        color: Colors.black,
                        borderColor: Colors.black,
                        shape: DataMarkerType.circle,
                        isVisible: true,
                      ),
                      xValueMapper: (ChartData data, _) => data.hour,
                      yValueMapper: (ChartData data, _) => data.hum,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    MdiIcons.lightbulbOnOutline,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Cahaya",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: SfCartesianChart(
                  margin: const EdgeInsets.all(0),
                  borderWidth: 0,
                  borderColor: Colors.transparent,
                  plotAreaBorderWidth: 0,

                  primaryXAxis: NumericAxis(
                    minimum: 0,
                    maximum: 20,
                    interval: 6,
                    isVisible: true,
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: 200,
                    interval: 10,
                    isVisible: true,
                    borderColor: Colors.transparent,
                    borderWidth: 0,
                  ),
                  // plotAreaBackgroundColor: Colors.black,
                  series: <ChartSeries<ChartData, int>>[
                    SplineAreaSeries(
                      dataSource: dataTemp,
                      xValueMapper: (ChartData data, _) => data.hour,
                      yValueMapper: (ChartData data, _) => data.light,
                      gradient: LinearGradient(
                        colors: [
                          Colors.orangeAccent.withOpacity(0.7),
                          Colors.orangeAccent.withOpacity(0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      splineType: SplineType.natural,
                    ),
                    SplineSeries(
                      dataSource: dataTemp,
                      color: Colors.orange,
                      width: 4,
                      markerSettings: const MarkerSettings(
                        color: Colors.black,
                        borderColor: Colors.black,
                        shape: DataMarkerType.circle,
                        isVisible: true,
                      ),
                      xValueMapper: (ChartData data, _) => data.hour,
                      yValueMapper: (ChartData data, _) => data.light,
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
