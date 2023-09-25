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
import 'package:geocoding/geocoding.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageTryoutJasmaniScan extends StatefulWidget {
  final Map tryout;
  const PageTryoutJasmaniScan({Key? key, required this.tryout}) : super(key: key);

  @override
  State<PageTryoutJasmaniScan> createState() => _PageTryoutJasmaniScanState();
}

class _PageTryoutJasmaniScanState extends State<PageTryoutJasmaniScan> {
  final scanC = MobileScannerController();
  Map _tryout = {};

  @override
  void initState() {
    _tryout = widget.tryout;
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    super.initState();
  }

  @override
  void dispose() {
    scanC.dispose();
    super.dispose();
  }

  Future<void> cekTryout(Map tryout) async {
    showLoading();

    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.cekTryoutJasmani,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH) ?? "",
        'hash_user': pref.getString(HASH_USER) ?? "",
        'kd_tryout': tryout['kd_tryout'].toString(),
        'kd_lokasi_absen': _tryout['kd_lokasi_absen'].toString(),
        'status_absen': tryout['status_absen'].toString(),
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
      url: EndPoint.simpanAbsenTryoutJasmani,
      params: {
        'token_auth': await getPrefrence(TOKEN_AUTH) ?? "",
        'hash_user': await getPrefrence(HASH_USER) ?? "",
        'time_zone_name': dateTime.timeZoneName,
        'time_zone_offset': dateTime.timeZoneOffset.inHours.toString(),
        'kd_tryout': _tryout['kd_tryout'].toString(),
        'kd_lokasi_absen': _tryout['kd_lokasi_absen'].toString(),
        'status_absen': _tryout['status_absen'].toString(),
        'kd_tanda': _tryout['kd_tanda'].toString(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Scan QR Code"),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: MobileScanner(
          controller: scanC,
          allowDuplicates: true,
          onDetect: (barcode, args) async {
            scanC.stop();
            log(barcode.rawValue.toString());
            if (barcode.rawValue == null) {
              final result = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialogOkWidget(
                  message: "Barcode tryout tidak ditemukan",
                ),
              );
              if (result ?? false) {
                AppNavigator.instance.pop();
              }
            } else {
              log(_tryout['kd_tryout'].toString());
              if (barcode.rawValue == _tryout['kd_tryout'].toString()) {
                simpanAbsen();
              } else {
                final result = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const AlertDialogOkWidget(
                    message: "Barcode tryout tidak sesuai dengan jadwal tryout anda",
                  ),
                );
                if (result ?? false) {
                  AppNavigator.instance.pop();
                }
              }
            }
          },
        ),
      ),
    );
  }
}
