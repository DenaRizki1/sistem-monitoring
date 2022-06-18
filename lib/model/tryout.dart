class Tryout {
  String jenisTryout = "", idTryout = "", kdTryout = "", idPendidikan = "", namaPendidikan = "", idMataPelajaran = "", namaMataPelajaran = "", namaTryout = "", jumlahSoal = "",
      waktu = "", waktuMulai = "", waktuSelesai = "", createdAt = "", updatedAt = "", finish = "", keterangan = "", kdPengajar = "";
  AbsenTryout absenTryout = AbsenTryout();
}

class AbsenTryout {
  String bisaAbsen = "", tanggalJam = "", lat = "", long = "", status = "", statusKet = "", metode = "", fotoAbsen = "";
  bool? statusBisaAbsen;
}

class JenisTryout {
  static const String jasmani = "jasmani";
  static const String akademik = "akademik";
  static const String psikologi = "psikologi";
}