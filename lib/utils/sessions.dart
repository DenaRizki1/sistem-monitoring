import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

setPrefrence(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

//prefrence string get using this function
Future<String?> getPrefrence(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

//prefrence boolean set using this function
setPrefrenceBool(String key, bool value) async {
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

  prefs.remove(HASH_USER);
  prefs.remove(TOKEN_AUTH);
  prefs.remove(NIK);
  prefs.remove(NAMA);
  prefs.remove(EMAIL);
  prefs.remove(NOTLP);
  prefs.remove(ALAMAT);
  prefs.remove(FOTO);
  prefs.remove(PASSWORD);
}
