import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

Future<void> setPrefrence(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

//prefrence string get using this function
Future<String?> getPrefrence(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

//prefrence boolean set using this function
Future<void> setPrefrenceBool(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

//prefrence boolean get using this function
Future<bool> getPrefrenceBool(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key) ?? false;
}

Future<void> clearUserSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(IS_LOGIN, false);
  prefs.setString(HASH_USER, "");
  prefs.setString(TOKEN_AUTH, "");
  prefs.setString(NAMA, "");
  prefs.setString(EMAIL, "");
  prefs.setString(NOTLP, "");
  prefs.setString(ALAMAT, "");
  prefs.setString(FOTO, "");
  prefs.setString(PASSWORD, "");
  prefs.setString(TOKEN_NOTIF, "");
  prefs.setString(LAT_USER, "");
  prefs.setString(LNG_USER, "");
}
