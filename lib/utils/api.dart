import 'dart:convert';

const String baseUrl = 'https://apps.tacticalinpolice.com/api_guru';

final String basicAuth = 'Basic ' + base64Encode(utf8.encode('4p1k3yr3st4T1PPppPPpp:88d19af4acfa4d8aad5d4eb496b520b2'));
final headers = <String, String>{'authorization': basicAuth};

const int timeOut = 50;

const String urlLogin = '$baseUrl/auth_guru/loginV2';
const String urlLogout = '$baseUrl/auth_guru/logoutAuth';
const String urlUbahPassword = '$baseUrl/auth_guru/ubahPassword';
const String urlListTryoutHariIni = '$baseUrl/beranda/tryout_hariini';
const String urlKebijakanPrivasi = '$baseUrl/beranda/getKebijakan';
const String urlSyaratKetentuan = '$baseUrl/beranda/getTermAndCondition';

const String urlGetAbsenHarian = '$baseUrl/absen/getAbsenHarian';
const String urlSimpanAbsenHarian = '$baseUrl/absen/simpanAbsenHarian';
const String urlGetRekapAbsen = '$baseUrl/absen/getRekapAbsen';

const String urlListTryoutJasmaniByPengajar = '$baseUrl/jasmani/list_jadwal_tryout_by_pengajar';
const String urlDetailTryoutJasmani = '$baseUrl/jasmani/detail_jadwal_tryout';
const String urlGetAbsenTryoutJasmani = '$baseUrl/jasmani/getAbsenTryout';
const String urlSimpanAbsenTryoutJasmani = '$baseUrl/jasmani/simpanAbsenTryout';

const String urlListTryoutAkademikByPengajar = '$baseUrl/akademik/list_jadwal_tryout_by_pengajar';
const String urlDetailTryoutAkademik = '$baseUrl/akademik/detail_jadwal_tryout';
const String urlGetAbsenTryoutAkademik = '$baseUrl/akademik/getAbsenTryout';
const String urlSimpanAbsenTryoutAkademik = '$baseUrl/akademik/simpanAbsenTryout';

const String urlListTryoutPsikologiByPengajar = '$baseUrl/psikologi/list_jadwal_tryout_by_pengajar';
const String urlDetailTryoutPsikologi = '$baseUrl/psikologi/detail_jadwal_tryout';
const String urlGetAbsenTryoutPsikologi = '$baseUrl/psikologi/getAbsenTryout';
const String urlSimpanAbsenTryoutPsikologi = '$baseUrl/psikologi/simpanAbsenTryout';
