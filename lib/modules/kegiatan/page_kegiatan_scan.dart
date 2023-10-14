import 'dart:developer';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/services/location_service.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/utils/sessions.dart';
import 'package:absentip/wigets/alert_dialog_ok_widget.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageKegiatanScan extends StatefulWidget {
  final Map kegiatan;
  const PageKegiatanScan({Key? key, required this.kegiatan}) : super(key: key);

  @override
  State<PageKegiatanScan> createState() => _PageKegiatanScanState();
}

class _PageKegiatanScanState extends State<PageKegiatanScan> {
  Map _kegiatan = {};

  @override
  void initState() {
    _kegiatan = widget.kegiatan;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scanQR();
    });
    super.initState();
  }

  @override
  void dispose() {
    // scanC.dispose();
    super.dispose();
  }

  Future<void> cekKegiatan(Map kegiatan) async {
    showLoading();

    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.cekKegiatan,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH) ?? "",
        'hash_user': pref.getString(HASH_USER) ?? "",
        'kd_pegawai_jadwal': kegiatan['kd_pegawai_jadwal'].toString(),
        'status_absen': kegiatan['status_absen'].toString(),
      },
    );

    dismissLoading();

    if (response != null) {
      if (response['success']) {
        simpanAbsen();
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialogOkWidget(message: response['message'].toString()),
        );
      }
    }
  }

  Future<void> simpanAbsen() async {
    await showLoading(dismissOnTap: false);

    double latitude = 0.0;
    double longitude = 0.0;
    // ignore: unused_local_variable
    String address = "";

    final _currentLocation = await LocationService.instance.getCurrentLocation(context);
    if (_currentLocation != null) {
      latitude = _currentLocation.latitude;
      longitude = _currentLocation.longitude;
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentLocation.latitude,
        _currentLocation.longitude,
        localeIdentifier: "id_ID",
      );
      if (placemarks.isNotEmpty) {
        Placemark placeMark = placemarks[0];
        if (mounted) {
          setState(() {
            address =
                "${placeMark.street}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.subAdministrativeArea}, ${placeMark.administrativeArea}, ${placeMark.country}, ${placeMark.postalCode}";
          });
        }
      } else {
        showToast("Lokasi tidak ditemukan");
        return;
      }
    } else {
      showToast("Koordinat tidak ditemukan");
      return;
    }

    DateTime dateTime = DateTime.now();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.simpanAbsenKegiatan,
      params: {
        'token_auth': await getPrefrence(TOKEN_AUTH) ?? "",
        'hash_user': await getPrefrence(HASH_USER) ?? "",
        'time_zone_name': dateTime.timeZoneName,
        'time_zone_offset': dateTime.timeZoneOffset.inHours.toString(),
        'kd_pegawai_jadwal': _kegiatan['kd_pegawai_jadwal'].toString(),
        'status_absen': _kegiatan['status_absen'].toString(),
        'kd_tanda': _kegiatan['kd_tanda'].toString(),
        'lat': latitude.toString(),
        'long': longitude.toString(),
      },
    );

    dismissLoading();

    if (response != null) {
      if (response['success']) {
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialogOkWidget(
            message: response['message'].toString(),
          ),
        );
        if (result ?? false) {
          AppNavigator.instance.pop();
        }
      } else {
        switch (response['code'].toString()) {
          case "0":
            showToast(response['message'].toString());
            break;

          case "1":
            showDialog<bool>(
              context: context,
              builder: (context) => AlertDialogOkWidget(
                message: response['message'].toString(),
              ),
            );
            break;

          default:
            showToast(response['message'].toString());
        }
      }
    }
  }

  Future<void> scanQR() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.QR);
      log("barcodeScanRes=" + barcodeScanRes);
      if (barcodeScanRes == "-1") {
        AppNavigator.instance.pop();
      } else {
        log("kd_kegiatan:   " + _kegiatan['kd_pegawai_jadwal'].toString());
        log("barcode:  " + barcodeScanRes);
        if (barcodeScanRes == _kegiatan['kd_pegawai_jadwal'].toString()) {
          cekKegiatan(_kegiatan);
        } else {
          final result = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => const AlertDialogOkWidget(
              message: "Barcode absen tidak sesuai dengan jadwal kegiatan anda",
            ),
          );
          if (result ?? false) {
            AppNavigator.instance.pop();
          }
        }
      }
    } on PlatformException {
      showToast("Failed to get platform version.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Scan QR Code"),
    );
  }
}
