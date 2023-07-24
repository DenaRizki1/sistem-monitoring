import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:absentip/data/enums/ApiStatus.dart';
import 'package:absentip/data/provider/notification_model_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/helpers.dart';

class MainProvider with ChangeNotifier {
  int _currentIndex = 0;
  bool _errorSource = false;
  bool _enableBtnSend = false;
  String _email = "";
  String _name = "";
  String _foto = "";
  String _noTelp = "";
  String _appVersion = "";
  String _term = "";
  String _privacy = "";
  Timer? _timer;
  final List<NotificationModelProvider> _listNotif = [];
  final List _listBranch = [];
  final Map _homeData = {};
  late ApiStatus _statusGetPrivacy;
  late ApiStatus _statusGetTerm;
  late ApiStatus _statusGetNotification;
  late ApiStatus _statusGetBranch;

  ApiStatus get statusGetPrivacy => _statusGetPrivacy;
  ApiStatus get statusGetTerm => _statusGetTerm;
  ApiStatus get statusGetNotification => _statusGetNotification;
  ApiStatus get statusGetBranch => _statusGetBranch;
  int get currentIndex => _currentIndex;
  bool get errorSource => _errorSource;
  bool get enableBtnSend => _enableBtnSend;
  String get email => _email;
  String get name => _name;
  String get foto => _foto;
  String get noTelp => _noTelp;
  String get appVersion => _appVersion;
  String get term => _term;
  String get privacy => _privacy;
  Timer? get timer => _timer;
  List<NotificationModelProvider> get listNotif => _listNotif;
  List get listBranch => _listBranch;
  Map get homeData => _homeData;

  set setTimer(Timer value) {
    _timer = value;
  }

  set setErrorSource(bool value) {
    _errorSource = value;
    notifyListeners();
  }

  set setSnableBtnSend(bool value) {
    _enableBtnSend = value;
    notifyListeners();
  }

  // Future<bool> readNotification(String id) async {
  //   final listId = [];
  //   listId.add(id);

  //   final pref = await SharedPreferences.getInstance();
  //   final response = await ApiConnect.instance.request(
  //     requestMethod: RequestMethod.post,
  //     url: EndPoints.actionNotification,
  //     params: {
  //       'token_auth': pref.getString(KeySession.TOKEN_AUTH) ?? "",
  //       'hash_user': pref.getString(KeySession.HASH_USER) ?? "",
  //       "list_id": json.encode(listId),
  //       "action": "read",
  //     },
  //   );

  //   if (response != null) {
  //     if (response['success']) {
  //       return true;
  //     } else {
  //       showToast(response['message'].toString());
  //     }
  //   }
  //   return false;
  // }

  // Future<void> actionListNotif(String action) async {
  //   List<String> listId = [];
  //   for (var element in _listNotif) {
  //     if (element.isSelected) {
  //       listId.add(element.id_notif);
  //     }
  //   }
  //   final pref = await SharedPreferences.getInstance();
  //   final response = await ApiConnect.instance.request(
  //     requestMethod: RequestMethod.post,
  //     url: EndPoints.actionNotification,
  //     params: {
  //       'token_auth': pref.getString(KeySession.TOKEN_AUTH) ?? "",
  //       'hash_user': pref.getString(KeySession.HASH_USER) ?? "",
  //       "list_id": json.encode(listId),
  //       "action": action,
  //     },
  //   );

  //   _listNotif.clear();

  //   if (response != null) {
  //     if (response['success']) {
  //       _listNotif.addAll((response['data'] as List).map((e) => NotificationModelProvider.fromMap(e)).toList());
  //     } else {
  //       showToast(response['message'].toString());
  //     }
  //   }
  //   notifyListeners();
  //   return;
  // }

  // Future<void> getNotification() async {
  //   _statusGetNotification = ApiStatus.loading;

  //   final pref = await SharedPreferences.getInstance();
  //   final response = await ApiConnect.instance.request(
  //     requestMethod: RequestMethod.post,
  //     url: EndPoints.notification,
  //     params: {
  //       'token_auth': pref.getString(KeySession.TOKEN_AUTH) ?? "",
  //       'hash_user': pref.getString(KeySession.HASH_USER) ?? "",
  //     },
  //   );

  //   await dismissLoading();

  //   _listNotif.clear();

  //   if (response != null) {
  //     if (response['success']) {
  //       _statusGetNotification = ApiStatus.success;
  //       _listNotif.addAll((response['data'] as List).map((e) => NotificationModelProvider.fromMap(e)).toList());
  //     } else {
  //       _statusGetNotification = ApiStatus.empty;
  //     }
  //   } else {
  //     _statusGetNotification = ApiStatus.failed;
  //   }
  //   notifyListeners();
  // }

  // void getProfileUser() async {
  //   final pref = await SharedPreferences.getInstance();
  //   _name = pref.getString(KeySession.NAMA_LENGKAP).toString();
  //   _email = pref.getString(KeySession.EMAIL).toString();
  //   _noTelp = pref.getString(KeySession.NO_TLP).toString();
  //   _foto = pref.getString(KeySession.AVATAR).toString();
  //   _appVersion = pref.getString(KeySession.VERSION).toString();
  //   notifyListeners();
  // }

  void initIndex() {
    _currentIndex = 0;
  }

  void setCurrentIndex(int value) {
    _currentIndex = value;
    notifyListeners();
  }

  void update() {
    notifyListeners();
  }
}
