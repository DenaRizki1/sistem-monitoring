import 'package:absentip/utils/config/api_config.dart';

abstract class EndPoint {
  static String urlLogin = '${getBaseUrl()}/auth_guru/loginV2';
  static String urlListTryoutHariIni = '${getBaseUrl()}/beranda/tryout_hariini';

  //! API PENGAJAR KEUANGAN
  static String login = '${getBaseUrl()}/auth_pengajar/login';
  static String checkLogin = '${getBaseUrl()}/auth_pengajar/checkLogin';
  static String logout = '${getBaseUrl()}/auth_pengajar/logout';
  static String gantiPassword = '${getBaseUrl()}/auth_pengajar/gantiPassword';
  static String termCondition = '${getBaseUrl()}/auth_pengajar/termCondition';
  static String policyPrivacy = '${getBaseUrl()}/auth_pengajar/policyPrivacy';
  static String uploadAvatar = '${getBaseUrl()}/auth_pengajar/uploadAvatar';

  static String notif = '${getBaseUrl()}/notifikasi/notif';
  static String readNotif = '${getBaseUrl()}/notifikasi/readNotif';
  static String deleteNotif = '${getBaseUrl()}/notifikasi/deleteNotif';

  static String simpanAbsen = '${getBaseUrl()}/absen/simpanAbsen';
  static String cekAbsen = '${getBaseUrl()}/absen/cekAbsen';
  static String cekBarcodeAbsen = '${getBaseUrl()}/absen/cekBarcodeAbsen';
  static String absenHarian = '${getBaseUrl()}/absen/absenHarian';
  static String absenHarianDetail = '${getBaseUrl()}/absen/absenHarianDetail';
  static String simpanAbsenIzin = '${getBaseUrl()}/absen/simpanAbsenIzin';
  static String simpanAbsenCuti = '${getBaseUrl()}/absen/simpanAbsenCuti';
  static String hitungJumlahCuti = '${getBaseUrl()}/absen/hitungJumlahCuti';
  static String absenIzin = '${getBaseUrl()}/absen/absenIzin';
  static String absenCuti = '${getBaseUrl()}/absen/absenCuti';
  static String rekapAbsen = '${getBaseUrl()}/absen/rekapAbsen';
  static String jadwalAbsen = '${getBaseUrl()}/absen/jadwalAbsen';

  static String simpanLembur = '${getBaseUrl()}/lembur/simpanLembur';
  static String lembur = '${getBaseUrl()}/lembur/lembur';

  static String aktivitas = '${getBaseUrl()}/aktivitas/aktivitas';
  static String aktivitasDetail = '${getBaseUrl()}/aktivitas/aktivitasDetail';
  static String simpanAktivitas = '${getBaseUrl()}/aktivitas/simpanAktivitas';
  static String updateAktivitas = '${getBaseUrl()}/aktivitas/updateAktivitas';
  static String uploadAktivitas = '${getBaseUrl()}/aktivitas/uploadAktivitas';

  static String kegiatan = '${getBaseUrl()}/kegiatan/kegiatan';
  static String kegiatanDetail = '${getBaseUrl()}/kegiatan/kegiatanDetail';
  static String cekKegiatan = '${getBaseUrl()}/kegiatan/cekKegiatan';
  static String simpanAbsenKegiatan = '${getBaseUrl()}/kegiatan/simpanAbsenKegiatan';

  static String jadwalPengajar = '${getBaseUrl()}/jadwal/jadwalPengajar';
  static String jadwalPengajarDetail = '${getBaseUrl()}/jadwal/jadwalPengajarDetail';

  static String event = '${getBaseUrl()}/kalender/event';
}
