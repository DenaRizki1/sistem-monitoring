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
  final waitList = <Future<void>>[];

  SharedPreferences prefs = await SharedPreferences.getInstance();

  waitList.add(prefs.remove(HASH_USER));
  waitList.add(prefs.remove(TOKEN_AUTH));
  waitList.add(prefs.remove(NIK));
  waitList.add(prefs.remove(NAMA));
  waitList.add(prefs.remove(EMAIL));
  waitList.add(prefs.remove(NOTLP));
  waitList.add(prefs.remove(ALAMAT));
  waitList.add(prefs.remove(FOTO));
  waitList.add(prefs.remove(PASSWORD));
  waitList.add(prefs.remove(TOKEN));

  await prefs.clear();
}
