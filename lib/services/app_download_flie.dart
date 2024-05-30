import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:sistem_monitoring/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:path/path.dart' as path;

class AppDonwloadFile {
  static void init() {
    final ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, 'downloader_send_port');
    port.listen((dynamic data) async {
      String taskId = data[0];
      DownloadTaskStatus status = data[1];
      // ignore: unused_local_variable
      int progress = data[2];

      if (status.value == 3 && progress == 100) {
        showToast("Downlaod berhasil");
        if (Platform.isAndroid) {
          final resultopen = await FlutterDownloader.open(taskId: taskId);
          if (!resultopen) {
            showToast("Tidak ada aplikasi untuk membu ka file");
          }
        }
      } else if (status.value == 4) {
        if (Platform.isIOS) {
          showToast("Download gagal, silahkan coba beberapa saat lagi");
        }
      }
    });
  }

  static void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void download(BuildContext context, String url, String fileName) async {
    fileName = fileName.replaceAll(RegExp('[^A-Za-z0-9_ ]'), '');
    fileName = "$fileName-${getRandomString(5).toUpperCase()}${path.extension(url.toLowerCase())}";

    Directory? externalDir;

    if (Platform.isIOS) {
      externalDir = await getApplicationDocumentsDirectory();
    } else {
      externalDir = Directory('/storage/emulated/0/Download');
      if (!await externalDir.exists()) {
        externalDir = await getExternalStorageDirectory();
      }
    }

    final sdkVersion = await getSdkDevice();

    Future download() async {
      await FlutterDownloader.enqueue(
        url: url,
        savedDir: externalDir!.path,
        // fileName: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
    }

    if (Platform.isIOS) {
      try {
        await download();
      } catch (e) {
        debugPrint(e.toString());
        PermissionStatus permission = await Permission.storage.status;
        if (permission != PermissionStatus.granted) {
          // ignore: use_build_context_synchronously
          alertOpenSetting(context);
        }
      }
    } else {
      if (sdkVersion > 32) {
        await download();
      } else {
        try {
          PermissionStatus permission = await Permission.storage.status;
          if (permission == PermissionStatus.denied) {
            //? Requesting the permission
            PermissionStatus statusDenied = await Permission.storage.request();
            if (statusDenied.isPermanentlyDenied) {
              //? permission isPermanentlyDenied
              // ignore: use_build_context_synchronously
              alertOpenSetting(context);
            }
          } else {
            await download();
          }
        } catch (e) {
          debugPrint(e.toString());
          showToast("Terjadi kesalahan");
        }
      }
    }
  }
}
