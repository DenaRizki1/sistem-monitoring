import 'package:absentip/utils/config/api_config.dart';

abstract class EndPoint {
  static String urlLogin = '${getBaseUrl()}/auth_guru/loginV2';
  // static String urlLogout = '${getBaseUrl()}/auth_guru/logoutAuth';
  // static String urlUbahPassword = '${getBaseUrl()}/auth_guru/ubahPassword';
  static String urlListTryoutHariIni = '${getBaseUrl()}/beranda/tryout_hariini';
  // static String urlKebijakanPrivasi = '${getBaseUrl()}/beranda/getKebijakan';
  // static String urlSyaratKetentuan = '${getBaseUrl()}/beranda/getTermAndCondition';

  static String urlGetAbsenHarian = '${getBaseUrl()}/absen/getAbsenHarian';
  static String urlSimpanAbsenHarian = '${getBaseUrlV2()}/absen/simpanAbsen';
  static String urlGetRekapAbsen = '${getBaseUrlV2()}/absen/absenHarian';
  static String urlCekAbsen = '${getBaseUrlV2()}/absen/cekAbsen';

  static String urlSimpanAbsenIzin = '${getBaseUrlV2()}/absen/simpanAbsenIzin';
  static String urlSimpanAbsenCuti = '${getBaseUrlV2()}/absen/simpanAbsenCuti';
  static String urlGetRekapIzin = '${getBaseUrlV2()}/absen/absenIzin';
  static String urlGetRekapCuti = '${getBaseUrlV2()}/absen/absenCuti';
  static String urlGetProgresAbsen = '${getBaseUrlV2()}/absen/rekapAbsen';

  static String urlGetNotifikasi = '${getBaseUrlV2()}/notifikasi/notif';
  static String urlReadNotifikasi = '${getBaseUrlV2()}/notifikasi/readNotif';
  static String urlDeleteNotifikasi = '${getBaseUrlV2()}/notifikasi/deleteNotif';

  // static String urlListTryoutJasmaniByPengajar = '${getBaseUrl()}/jasmani/list_jadwal_tryout_by_pengajar';
  // static String urlDetailTryoutJasmani = '${getBaseUrl()}/jasmani/detail_jadwal_tryout';
  // static String urlGetAbsenTryoutJasmani = '${getBaseUrl()}/jasmani/getAbsenTryout';
  // static String urlSimpanAbsenTryoutJasmani = '${getBaseUrl()}/jasmani/simpanAbsenTryout';

  // static String urlListTryoutAkademikByPengajar = '${getBaseUrl()}/akademik/list_jadwal_tryout_by_pengajar';
  // static String urlDetailTryoutAkademik = '${getBaseUrl()}/akademik/detail_jadwal_tryout';
  // static String urlGetAbsenTryoutAkademik = '${getBaseUrl()}/akademik/getAbsenTryout';
  // static String urlSimpanAbsenTryoutAkademik = '${getBaseUrl()}/akademik/simpanAbsenTryout';

//   static String urlListTryoutPsikologiByPengajar = '${getBaseUrl()}/psikologi/list_jadwal_tryout_by_pengajar';
//   static String urlDetailTryoutPsikologi = '${getBaseUrl()}/psikologi/detail_jadwal_tryout';
//   static String urlGetAbsenTryoutPsikologi = '${getBaseUrl()}/psikologi/getAbsenTryout';
//   static String urlSimpanAbsenTryoutPsikologi = '${getBaseUrl()}/psikologi/simpanAbsenTryout';
}
