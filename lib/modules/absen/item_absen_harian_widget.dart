import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/show_image_page.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ItemAbsenHarianWidget extends StatefulWidget {
  final Map absenDetail;

  const ItemAbsenHarianWidget({Key? key, required this.absenDetail}) : super(key: key);

  @override
  State<ItemAbsenHarianWidget> createState() => _ItemAbsenHarianWidgetState();
}

class _ItemAbsenHarianWidgetState extends State<ItemAbsenHarianWidget> {
  int statusAbsenDetail = 1;
  Map dataAbsen = {};
  List _detailAbsen = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    _detailAbsen = widget.absenDetail['item_absen'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dataAbsen = statusAbsenDetail == 1 ? _detailAbsen[0] : _detailAbsen[1];
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            FxSpacing.height(10),
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(0),
              child: Container(
                margin: FxSpacing.all(6),
                child: statusAbsenDetail == 1 ? activeCheckIn() : activeCheckOut(),
              ),
            ),
            FxSpacing.height(16),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(0),
              color: Colors.white,
              child: FxContainer(
                borderRadiusAll: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => AppNavigator.instance.push(
                            MaterialPageRoute(
                              builder: (context) => ShowImagePage(
                                judul: dataAbsen['foto_absen'].toString(),
                                url: dataAbsen['foto_absen'].toString(),
                              ),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              dataAbsen['foto_absen'].toString(),
                              fit: BoxFit.fill,
                              width: 100,
                              height: 150,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return SizedBox(
                                  width: 100,
                                  height: 150,
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
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade300,
                                child: Image.asset(
                                  AppImages.logoGold,
                                  width: 100,
                                  height: 150,
                                  fit: BoxFit.fitWidth,
                                  color: AppColor.biru2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        FxSpacing.width(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 150,
                                decoration: BoxDecoration(
                                  color: colorKeteranganAbsen(dataAbsen['jenis_absen'].toString()).withAlpha(60),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                child: FxText.bodySmall(
                                  dataAbsen['ket_jenis_absen'].toString(),
                                  color: colorKeteranganAbsen(dataAbsen['jenis_absen'].toString()),
                                  fontWeight: 700,
                                  fontSize: 11,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              FxSpacing.height(8),
                              FxText.bodySmall(
                                'Lokasi Absen',
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              FxSpacing.height(2),
                              FxText.bodySmall(
                                dataAbsen['nama_lokasi'].toString(),
                                fontSize: 12,
                                fontWeight: 700,
                                color: Colors.black,
                              ),
                              FxSpacing.height(8),
                              FxText.bodySmall(
                                'Jam Absen',
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              FxSpacing.height(2),
                              FxText.bodySmall(
                                dataAbsen['jam_absen'].toString(),
                                fontSize: 12,
                                fontWeight: 700,
                                color: Colors.black,
                              ),
                              FxSpacing.height(8),
                              FxText.bodySmall(
                                'Metode Absen',
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              FxSpacing.height(2),
                              FxText.bodySmall(
                                dataAbsen['ket_metode'].toString(),
                                fontSize: 12,
                                fontWeight: 700,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    FxSpacing.height(16),
                    FxText.bodySmall('Lokasi Absen', fontSize: 12, color: Colors.grey, textAlign: TextAlign.left),
                    FxSpacing.height(4),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(1),
                      width: double.infinity,
                      height: 250,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: GoogleMap(
                          scrollGesturesEnabled: false,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              safetyParseDouble(dataAbsen['lat'].toString()),
                              safetyParseDouble(dataAbsen['long'].toString()),
                            ),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('1'),
                              position: LatLng(
                                safetyParseDouble(dataAbsen['lat'].toString()),
                                safetyParseDouble(dataAbsen['long'].toString()),
                              ),
                            ),
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row activeCheckIn() {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: FxContainer.bordered(
              onTap: () {
                if (mounted) {
                  setState(() {
                    statusAbsenDetail = 1;
                  });
                }
              },
              padding: const EdgeInsets.symmetric(vertical: 8),
              borderRadiusAll: 8,
              border: Border.all(color: AppColor.biru),
              color: AppColor.biru.withAlpha(70),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Absen Masuk',
                    style: TextStyle(
                      color: AppColor.biru,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 34,
            child: TextButton(
              onPressed: () {
                if (_detailAbsen.length == 2) {
                  if (mounted) {
                    setState(() {
                      statusAbsenDetail = 2;
                    });
                  }
                } else {
                  showToast("Belum ada absen pulang");
                }
              },
              child: const Text(
                "Absen Pulang",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Row activeCheckOut() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 34,
            child: TextButton(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    statusAbsenDetail = 1;
                  });
                }
              },
              child: const Text(
                "Absen Masuk",
                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: FxContainer.bordered(
              onTap: () {
                if (mounted) {
                  setState(() {
                    statusAbsenDetail = 2;
                  });
                }
              },
              padding: const EdgeInsets.symmetric(vertical: 8),
              borderRadiusAll: 8,
              border: Border.all(color: AppColor.biru),
              color: AppColor.biru.withAlpha(70),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Absen Pulang',
                    style: TextStyle(
                      color: AppColor.biru,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color colorKeteranganAbsen(String statusAbsen) {
    switch (statusAbsen) {
      case "1":
        return Colors.green;
      case "2":
        return Colors.red;
      case "3":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
