import 'dart:convert';

const String baseUrl1 = 'https://apps.tacticalinpolice.com/api_guru';
const String baseUrl2 = 'https://apps.tacticalinpolice.com/api_guru_v2';

final String basicAuth = 'Basic ' + base64Encode(utf8.encode('4p1k3yr3st4T1PPppPPpp:88d19af4acfa4d8aad5d4eb496b520b2'));
final headers = <String, String>{'authorization': basicAuth};

const int timeOut = 50;

const String urlLogin = '$baseUrl1/auth_guru/loginV2';
const String urlLogout = '$baseUrl1/auth_guru/logoutAuth';
const String urlUbahPassword = '$baseUrl1/auth_guru/ubahPassword';
const String urlListTryoutHariIni = '$baseUrl1/beranda/tryout_hariini';
const String urlKebijakanPrivasi = '$baseUrl1/beranda/getKebijakan';
const String urlSyaratKetentuan = '$baseUrl1/beranda/getTermAndCondition';

const String urlGetAbsenHarian = '$baseUrl1/absen/getAbsenHarian';
const String urlSimpanAbsenHarian = '$baseUrl1/absen/simpanAbsenHarian';
const String urlGetRekapAbsen = '$baseUrl1/absen/getRekapAbsen';
const String urlCekAbsen = '$baseUrl2/absen/cekAbsen';

const String urlListTryoutJasmaniByPengajar = '$baseUrl1/jasmani/list_jadwal_tryout_by_pengajar';
const String urlDetailTryoutJasmani = '$baseUrl1/jasmani/detail_jadwal_tryout';
const String urlGetAbsenTryoutJasmani = '$baseUrl1/jasmani/getAbsenTryout';
const String urlSimpanAbsenTryoutJasmani = '$baseUrl1/jasmani/simpanAbsenTryout';

const String urlListTryoutAkademikByPengajar = '$baseUrl1/akademik/list_jadwal_tryout_by_pengajar';
const String urlDetailTryoutAkademik = '$baseUrl1/akademik/detail_jadwal_tryout';
const String urlGetAbsenTryoutAkademik = '$baseUrl1/akademik/getAbsenTryout';
const String urlSimpanAbsenTryoutAkademik = '$baseUrl1/akademik/simpanAbsenTryout';

const String urlListTryoutPsikologiByPengajar = '$baseUrl1/psikologi/list_jadwal_tryout_by_pengajar';
const String urlDetailTryoutPsikologi = '$baseUrl1/psikologi/detail_jadwal_tryout';
const String urlGetAbsenTryoutPsikologi = '$baseUrl1/psikologi/getAbsenTryout';
const String urlSimpanAbsenTryoutPsikologi = '$baseUrl1/psikologi/simpanAbsenTryout';
