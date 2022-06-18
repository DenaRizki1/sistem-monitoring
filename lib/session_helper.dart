import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'page_login.dart';

const keyIsLoggedIn = 'isLoggedIn';
const keyIdPengajar = 'id_pengajar';
const keyKdPengajar = 'kd_pengajar';
const keyNamaPengajar = 'nama_pengajar';
const keyAlamat = 'alamat';
const keyNomorHp = 'nomor_hp';
const keyEmail = 'email';
const keyFoto = 'foto';

Future<SharedPreferences> getSharedPreferencesInstance() async {
  return SharedPreferences.getInstance();
}

setSessionItem(String key, String value) async {
  SharedPreferences sharedPreferences = await getSharedPreferencesInstance();
  sharedPreferences.setString(key, value);
}

checkSessionAndOpenLoginPage(BuildContext context) async {
  SharedPreferences sharedPreferences = await getSharedPreferencesInstance();
  bool login = sharedPreferences.getBool(keyIsLoggedIn) ?? false;
  if(!login) {
    clearSession(context, true);
    // myInfoAlertDialog(context: context, message: "Silakan login kembali untuk melanjutkan");
  }
}

clearSession(BuildContext context, bool goToLogin) async {
  SharedPreferences sharedPreferences = await getSharedPreferencesInstance();
  sharedPreferences.setBool(keyIsLoggedIn, false);
  sharedPreferences.setString(keyIdPengajar, "");
  sharedPreferences.setString(keyKdPengajar, "");
  sharedPreferences.setString(keyNamaPengajar, "");
  sharedPreferences.setString(keyAlamat, "");
  sharedPreferences.setString(keyNomorHp, "");
  sharedPreferences.setString(keyEmail, "");
  sharedPreferences.setString(keyFoto, "");
  if(goToLogin) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const PageLogin()), (route) => false);
}

