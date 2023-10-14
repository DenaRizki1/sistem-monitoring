import 'dart:developer';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/utils/sessions.dart';
import 'package:absentip/wigets/alert_dialog_confirm_widget.dart';
import 'package:absentip/wigets/alert_dialog_ok_widget.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class PageAbsenScan extends StatefulWidget {
  final Map cekAbsen;
  const PageAbsenScan({Key? key, required this.cekAbsen}) : super(key: key);

  @override
  State<PageAbsenScan> createState() => _PageAbsenScanState();
}

class _PageAbsenScanState extends State<PageAbsenScan> {
  @override
  void initState() {
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

  Future<void> simpanAbsen(String barcodeJadwal) async {
    await showLoading(dismissOnTap: false);

    DateTime dateTime = DateTime.now();

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.simpanAbsen,
      params: {
        'token_auth': await getPrefrence(TOKEN_AUTH) ?? "",
        'hash_user': await getPrefrence(HASH_USER) ?? "",
        'jenis_absen': widget.cekAbsen['jenis_absen'].toString(),
        'time_zone_name': dateTime.timeZoneName,
        'time_zone_offset': dateTime.timeZoneOffset.inHours.toString(),
        'lat': widget.cekAbsen['lat'].toString(),
        'long': widget.cekAbsen['lng'].toString(),
        'status_absen': widget.cekAbsen['status_absen'].toString(),
        'kd_tanda': widget.cekAbsen['kd_tanda'].toString(),
        'jadwal': barcodeJadwal,
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

  Future<void> cekBarcodeAbsen(String barcode) async {
    await showLoading(dismissOnTap: false);

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.cekBarcodeAbsen,
      params: {
        'token_auth': await getPrefrence(TOKEN_AUTH) ?? "",
        'hash_user': await getPrefrence(HASH_USER) ?? "",
        'barcode': barcode,
      },
    );

    dismissLoading();

    if (response != null) {
      if (response['success']) {
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialogConfirmWidget(
            message: response['message'].toString(),
          ),
        );
        if (result ?? false) {
          simpanAbsen(barcode);
        }
      } else {
        switch (response['code'].toString()) {
          case "0":
            showToast(response['message'].toString());
            break;

          case "1":
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
        cekBarcodeAbsen(barcodeScanRes);
      }
    } on PlatformException {
      showToast("Failed to get platform version.");
    }
  }

  @override
  Widget build(BuildContext context) {
    log("PageAbsenScanTetap");
    return Scaffold(
      appBar: appBarWidget("Scan QR Code"),
    );
  }
}
