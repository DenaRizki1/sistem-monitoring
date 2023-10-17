import 'package:absentip/utils/config/api_config.dart';

abstract class EndPoint {
  static String login = '${getBaseUrl()}/auth_pengajar/login';
  static String checkLogin = '${getBaseUrl()}/auth_pengajar/checkLogin';
  static String logout = '${getBaseUrl()}/auth_pengajar/logout';
  static String hapusAkunFreelance = '${getBaseUrl()}/auth_pengajar/hapusAkunFreelance';
  static String gantiPassword = '${getBaseUrl()}/auth_pengajar/gantiPassword';
  static String termCondition = '${getBaseUrl()}/auth_pengajar/termCondition';
  static String policyPrivacy = '${getBaseUrl()}/auth_pengajar/policyPrivacy';
  static String uploadAvatar = '${getBaseUrl()}/auth_pengajar/uploadAvatar';

  static String notif = '${getBaseUrl()}/notifikasi/notif';
  static String readNotif = '${getBaseUrl()}/notifikasi/readNotif';
  static String deleteNotif = '${getBaseUrl()}/notifikasi/deleteNotif';

  static String simpanAbsen = '${getBaseUrl()}/absen/simpanAbsen';
  static String lokasiAbsenLuarKelas = '${getBaseUrl()}/absen/lokasiAbsenLuarKelas';
  static String simpanAbsenLuarkelas = '${getBaseUrl()}/absen/simpanAbsenLuarkelas';
  static String cekAbsen = '${getBaseUrl()}/absen/cekAbsen';
  static String cekBarcodeAbsen = '${getBaseUrl()}/absen/cekBarcodeAbsen';
  static String absenHarian = '${getBaseUrl()}/absen/absenHarian';
  static String absenHarianDetail = '${getBaseUrl()}/absen/absenHarianDetail';
  static String rekapAbsen = '${getBaseUrl()}/absen/rekapAbsen';
  static String jadwalAbsenHarian = '${getBaseUrl()}/absen/jadwalAbsenHarian';

  static String jadwalAbsen = '${getBaseUrl()}/main/jadwalAbsen';

  static String simpanAbsenCuti = '${getBaseUrl()}/cuti/simpanAbsenCuti';
  static String hitungJumlahCuti = '${getBaseUrl()}/cuti/hitungJumlahCuti';
  static String absenCuti = '${getBaseUrl()}/cuti/absenCuti';

  static String simpanAbsenIzin = '${getBaseUrl()}/izin/simpanAbsenIzin';
  static String absenIzin = '${getBaseUrl()}/izin/absenIzin';

  static String simpanLembur = '${getBaseUrl()}/lembur/simpanLembur';
  static String simpanLemburV2 = '${getBaseUrl()}/lembur/simpanLemburV2';
  static String lembur = '${getBaseUrl()}/lembur/lembur';
  static String cekDurasiLembur = '${getBaseUrl()}/lembur/cekDurasiLembur';
  static String uploadFileLembur = '${getBaseUrl()}/lembur/uploadFileLembur';
  static String ajukanUlangLembur = '${getBaseUrl()}/lembur/ajukanUlangLembur';

  static String aktivitas = '${getBaseUrl()}/aktivitas/aktivitas';
  static String aktivitasDetail = '${getBaseUrl()}/aktivitas/aktivitasDetail';
  static String simpanAktivitas = '${getBaseUrl()}/aktivitas/simpanAktivitas';
  static String updateAktivitas = '${getBaseUrl()}/aktivitas/updateAktivitas';
  static String uploadAktivitas = '${getBaseUrl()}/aktivitas/uploadAktivitas';

  static String tryoutJasmani = '${getBaseUrl()}/tryout_jasmani_v2/tryoutJasmani';
  static String tryoutDetailJasmani = '${getBaseUrl()}/tryout_jasmani_v2/tryoutDetailJasmani';
  static String cekTryoutJasmani = '${getBaseUrl()}/tryout_jasmani_v2/cekTryoutJasmani';
  static String simpanAbsenTryoutJasmani = '${getBaseUrl()}/tryout_jasmani_v2/simpanAbsenTryoutJasmani';

  static String tryoutPsikologi = '${getBaseUrl()}/tryout_psikologi/tryoutPsikologi';
  static String tryoutDetailPsikologi = '${getBaseUrl()}/tryout_psikologi/tryoutDetailPsikologi';
  static String cekTryoutPsikologi = '${getBaseUrl()}/tryout_psikologi/cekTryoutPsikologi';
  static String simpanAbsenTryoutPsikologi = '${getBaseUrl()}/tryout_psikologi/simpanAbsenTryoutPsikologi';

  static String tryoutAkademik = '${getBaseUrl()}/tryout_akademik/tryoutAkademik';
  static String tryoutDetailAkademik = '${getBaseUrl()}/tryout_akademik/tryoutDetailAkademik';
  static String cekTryoutAkademik = '${getBaseUrl()}/tryout_akademik/cekTryoutAkademik';
  static String simpanAbsenTryoutAkademik = '${getBaseUrl()}/tryout_akademik/simpanAbsenTryoutAkademik';

  static String kegiatan = '${getBaseUrl()}/kegiatan/kegiatan';
  static String kegiatanDetail = '${getBaseUrl()}/kegiatan/kegiatanDetail';
  static String cekKegiatan = '${getBaseUrl()}/kegiatan/cekKegiatan';
  static String simpanAbsenKegiatan = '${getBaseUrl()}/kegiatan/simpanAbsenKegiatan';

  static String event = '${getBaseUrl()}/kalender/event';

  static String getProvinsi = '${getBaseUrl()}/pendaftaran/getProvinsi';
  static String getKota = '${getBaseUrl()}/pendaftaran/getKota';
  static String getKecamatan = '${getBaseUrl()}/pendaftaran/getKecamatan';
  static String getKelurahan = '${getBaseUrl()}/pendaftaran/getKelurahan';
  static String getPendidikan = '${getBaseUrl()}/pendaftaran/getPendidikan';
  static String simpanPendaftaran = '${getBaseUrl()}/pendaftaran/simpanPendaftaran';
  static String getBank = '${getBaseUrl()}/pendaftaran/getBank';
}
