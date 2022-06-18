// ignore_for_file: file_names

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:photo_view/photo_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:connectivity/connectivity.dart';

class Helpers {
  static defaultAppBar(BuildContext context, String tittle) {
    return AppBar(
      title: Text(
        tittle,
        style: TextStyle(color: Colors.black),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            SystemNavigator.pop();
          }
        },
      ),
    );
  }

  static showImageHero(BuildContext context, String tittle, String url) {
    bool http = false;
    if (url.contains('http')) {
      http = true;
    } else {
      http = false;
    }

    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => Scaffold(
            appBar: defaultAppBar(context, tittle),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Hero(
                tag: 'show pic',
                child: http
                    ?
                    // Image.network(url)
                    PhotoView(imageProvider: NetworkImage(url))
                    :
                    // Image.asset(url,)
                    PhotoView(imageProvider: AssetImage(url)),
              ),
            ))));
  }

  static void showToast(message) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      fontSize: 12,
    );
  }

  static getDateTimeNow(
      bool hari, bool tgl, bool bulan, bool tahun, bool waktu) {
    DateTime today = new DateTime.now();
    var month;
    switch (today.month) {
      case 1:
        month = "Januari";
        break;
      case 2:
        month = "Febuari";
        break;
      case 3:
        month = "Maret";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "Mei";
        break;
      case 6:
        month = "Juni";
        break;
      case 7:
        month = "Juli";
        break;
      case 8:
        month = "Agustus";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "Oktober";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "Desember";
        break;
    }
    var day;
    switch (DateFormat('EEEE').format(today)) {
      case 'Monday':
        day = "Senin";
        break;
      case 'Tuesday':
        day = "Selasa";
        break;
      case 'Wednesday':
        day = "Rabu";
        break;
      case 'Thursday':
        day = "Kamis";
        break;
      case 'Friday':
        day = "Jumat";
        break;
      case 'Saturday':
        day = "Sabtu";
        break;
      case 'Sunday':
        day = "Ahad";
        break;
    }

    var data,
        tempHari = '',
        tempTgl = '',
        tempBulan = '',
        tempTahun = '',
        tempWaktu = '';

    if (tahun) {
      tempTahun = today.year.toString();
    }

    if (bulan) {
      tempBulan = month;
    }

    if (tgl) {
      tempTgl = today.day.toString();
    }

    if (hari) {
      tempHari = day;
    }

    if (waktu) {
      String h = '', m = '';
      if (today.hour < 10) {
        h = '0' + today.hour.toString();
      } else {
        h = today.hour.toString();
      }
      if (today.minute < 10) {
        m = '0' + today.minute.toString();
      } else {
        m = today.minute.toString();
      }
      tempWaktu = '$h:$m';
    }

    data = '$tempHari, $tempTgl $tempBulan $tempTahun $tempWaktu';

    return data;
  }

  static formatDateFull(DateTime tm) {
    DateTime today = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration twoDay = new Duration(days: 2);
    Duration oneWeek = new Duration(days: 7);

    var day;
    switch (tm.day) {
      case 1:
        day = "01";
        break;
      case 2:
        day = "02";
        break;
      case 3:
        day = "03";
        break;
      case 4:
        day = "04";
        break;
      case 5:
        day = "05";
        break;
      case 6:
        day = "06";
        break;
      case 7:
        day = "07";
        break;
      case 8:
        day = "08";
        break;
      case 9:
        day = "09";
        break;
      default:
        day = tm.day;
        break;
    }

    var month;
    switch (tm.month) {
      case 1:
        month = "Januari";
        break;
      case 2:
        month = "Febuari";
        break;
      case 3:
        month = "Maret";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "Mei";
        break;
      case 6:
        month = "Juni";
        break;
      case 7:
        month = "Juli";
        break;
      case 8:
        month = "Agustus";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "Oktober";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "Desember";
        break;
    }

    Duration difference = today.difference(tm);

    return '$day $month ${tm.year}';
  }

  static formatMonthYear(DateTime tm) {
    DateTime today = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration twoDay = new Duration(days: 2);
    Duration oneWeek = new Duration(days: 7);
    var month;
    switch (tm.month) {
      case 1:
        month = "Januari";
        break;
      case 2:
        month = "Febuari";
        break;
      case 3:
        month = "Maret";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "Mei";
        break;
      case 6:
        month = "Juni";
        break;
      case 7:
        month = "Juli";
        break;
      case 8:
        month = "Agustus";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "Oktober";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "Desember";
        break;
    }

    Duration difference = today.difference(tm);

    return '$month ${tm.year}';
  }

  static Future imageSelector(
      BuildContext context, ImagePicker _picker, String pickerType) async {
    XFile? imageFile = null;
    // File file;

    switch (pickerType) {
      case "galeri":

        /// GALLERY IMAGE PICKER
        imageFile = await _picker.pickImage(source: ImageSource.gallery);
        break;

      case "kamera": // CAMERA CAPTURE CODE
        imageFile = await _picker.pickImage(
            source: ImageSource.camera,
            imageQuality: 80,
            maxHeight: 852,
            maxWidth: 450);
        break;
    }

    if (imageFile != null) {
      print("You selected  image : " + imageFile.path);
      // file = File(imageFile.path);
      return imageFile;
    } else {
      showToast('Batal mengambil foto');
    }
  }

  //check network
  static Future<bool> isNetworkAvailable() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  //show snackbar msg
  static setSnackbar(String msg, BuildContext context) {
    // ignore: unnecessary_new
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      // ignore: unnecessary_new
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 1.0,
    ));
  }

  static Future dialogOkNetwork(BuildContext context, String message) async {
    ArtDialogResponse response = await ArtSweetAlert.show(
        barrierDismissible: false,
        context: context,
        artDialogArgs: ArtDialogArgs(
            // title: "Perhatian",
            text: message,
            confirmButtonText: "Ok",
            confirmButtonColor: Colors.red,
            type: ArtSweetAlertType.success));

    if (response == null) {
      return;
    }

    if (response.isTapConfirmButton) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        SystemNavigator.pop();
      }
      return;
    }
  }

  static Future dialogErrorNetwork(BuildContext context, String message) async {
    ArtDialogResponse response = await ArtSweetAlert.show(
        barrierDismissible: false,
        context: context,
        artDialogArgs: ArtDialogArgs(
            // title: "Perhatian",
            text: message,
            confirmButtonText: "Ok",
            confirmButtonColor: Colors.red,
            type: ArtSweetAlertType.warning));

    if (response == null) {
      return;
    }

    if (response.isTapConfirmButton) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        SystemNavigator.pop();
      }
      return;
    }
  }

  static Future dialogErrorNetworkNoFinish(
      BuildContext context, String message) async {
    ArtDialogResponse response = await ArtSweetAlert.show(
        barrierDismissible: false,
        context: context,
        artDialogArgs: ArtDialogArgs(
            // title: "Perhatian",
            text: message,
            confirmButtonText: "Ok",
            confirmButtonColor: Colors.red,
            type: ArtSweetAlertType.warning));

    if (response == null) {
      return;
    }

    if (response.isTapConfirmButton) {
      return;
    }
  }

  static void downloadImage(String url) async {
    try {
      // Saved with this method.
      var imageId = await ImageDownloader.downloadImage(url);
      if (imageId == null) {
        return;
      }

      // Below is a method of obtaining saved image information.
      var fileName = await ImageDownloader.findName(imageId);
      var path = await ImageDownloader.findPath(imageId);
      var size = await ImageDownloader.findByteSize(imageId);
      var mimeType = await ImageDownloader.findMimeType(imageId);

      await ImageDownloader.open(path!);
    } on PlatformException catch (error) {
      print(error);
    }
  }

  static Color getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
    return Colors.white;
  }

  static MaterialColor getBaseColor(){
    const Map<int, Color> color = {
      50: Color.fromRGBO(0, 0, 0, .0),
      100: Color.fromRGBO(0, 0, 0, .0),
      200: Color.fromRGBO(0, 0, 0, .0),
      300: Color.fromRGBO(0, 0, 0, .0),
      400: Color.fromRGBO(0, 0, 0, .0),
      500: Color.fromRGBO(0, 0, 0, .0),
      600: Color.fromRGBO(0, 0, 0, .0),
      700: Color.fromRGBO(0, 0, 0, .0),
      800: Color.fromRGBO(0, 0, 0, .0),
      900: Color.fromRGBO(0, 0, 0, .0),
    };
    return MaterialColor(0xFFDFAA41, color);
  }

  static String getBulan(String angkaBulan) {
    switch (angkaBulan) {
      case "1":
        return "Januari";
      case "2":
        return "Febuari";
      case "3":
        return "Maret";
      case "4":
        return "April";
      case "5":
        return "Mei";
      case "6":
        return "Juni";
      case "7":
        return "Juli";
      case "8":
        return "Agustus";
      case "9":
        return "September";
      case "10":
        return "Oktober";
      case "11":
        return "November";
      case "12":
        return "Desember";
      default:
        return "";
    }
  }
}
