import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:sistem_monitoring/data/enums/request_method.dart';
import 'package:sistem_monitoring/modules/auth/login_page.dart';
import 'package:sistem_monitoring/utils/config/api_config.dart';
import 'package:sistem_monitoring/utils/helpers.dart';
import 'package:sistem_monitoring/utils/routes/app_navigator.dart';
import 'package:sistem_monitoring/utils/sessions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ApiConnect {
  static final ApiConnect instance = ApiConnect._();

  ApiConnect._();

  static Map<String, String> headers = <String, String>{"authorization": getBasicAuth()};

  late Completer<Map<String, dynamic>?> _completer;
  late Timer _timer;

  void cancelOperation() {
    _timer.cancel();
    if (_completer.isCompleted == false) {
      _completer.complete(null);
    }
  }

  Future<Map<String, dynamic>?> request({RequestMethod requestMethod = RequestMethod.get, required String url, required Map<String, String> params}) async {
    try {
      log("==================================================");
      log(url);
      log(params.toString());

      late Response response;

      if (requestMethod == RequestMethod.post) {
        response = await post(
          Uri.parse(url),
          headers: ApiConnect.headers,
          body: params,
        );
      } else {
        response = await get(
          Uri.parse(url),
          headers: ApiConnect.headers,
        );
      }

      log(response.body.toString());

      final body = jsonDecode(response.body);

      if (body['success'] == false) {
        if (body['message'].toString() == "Your Not Authorized") {
          clearUserSession();
          AppNavigator.instance.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (p0) => false);
          showToast(body['message']);
        }
      }

      return body;
    } on SocketException {
      showToast("Tidak ada koneksi internet");
      Future.error("Tidak ada koneksi internet");
    } catch (e) {
      log(e.toString());
      showToast("Terjadi kesalahan");
      Future.error("Terjadi kesalahan");
    }
    return null;
  }

  Future<Map<String, dynamic>?> uploadFile(String url, String keyFile, String filePath, Map<String, String> params) async {
    try {
      final request = MultipartRequest("POST", Uri.parse(url));

      request.headers.addAll(headers);
      request.fields.addAll(params);
      request.files.add(await MultipartFile.fromPath(keyFile, filePath));

      final streameResponse = await request.send();

      final response = await Response.fromStream(streameResponse);

      log("==================================================");
      log(url);
      log(params.toString());
      log(response.body);

      final result = jsonDecode(response.body);
      if (result['success'] == false) {
        if (result['message'].toString() == "Your Not Authorized") {
          clearUserSession();
          AppNavigator.instance.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
              (p0) => false);
          showToast(result['message']);
        }
      }

      return jsonDecode(response.body);
    } on SocketException {
      showToast("Tidak ada koneksi internet");
      Future.error("Tidak ada koneksi internet");
    } catch (e) {
      log(e.toString());
      showToast("Terjadi kesalahan");
      Future.error("Terjadi kesalahan");
    }
    return null;
  }
}
