import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/api_response.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/modules/tryout_jasmani/page_tryout_jasmani_siswa_detail.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageTryoutJasmaniSiswa extends StatefulWidget {
  final String kdTryout;
  final String kdLokasiAbsen;

  const PageTryoutJasmaniSiswa({Key? key, required this.kdTryout, required this.kdLokasiAbsen}) : super(key: key);

  @override
  State<PageTryoutJasmaniSiswa> createState() => _PageTryoutJasmaniSiswaState();
}

class _PageTryoutJasmaniSiswaState extends State<PageTryoutJasmaniSiswa> {
  final _apiResponse = ApiResponse();
  final _refreshC = RefreshController();
  final _listKegiatan = [];

  @override
  void initState() {
    getSiswaAbsen();
    super.initState();
  }

  @override
  void dispose() {
    _refreshC.dispose();
    super.dispose();
  }

  Future<void> getSiswaAbsen() async {
    setState(() {
      _apiResponse.setApiSatatus = ApiStatus.loading;
      _listKegiatan.clear();
    });

    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.daftarSiswaJasmani,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH) ?? "",
        'hash_user': pref.getString(HASH_USER) ?? "",
        'kd_tryout': widget.kdTryout,
        'kd_lokasi_absen': widget.kdLokasiAbsen,
      },
    );

    if (_refreshC.isRefresh) {
      _refreshC.refreshCompleted();
    }

    if (response != null) {
      if (response['success']) {
        if (mounted) {
          setState(() {
            _apiResponse.setApiSatatus = ApiStatus.success;
            _listKegiatan.addAll(response['data']);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _apiResponse.setApiSatatus = ApiStatus.empty;
            _apiResponse.setMessage = response['message'].toString();
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _apiResponse.setApiSatatus = ApiStatus.failed;
          _apiResponse.setMessage = "Terjadi kesalahan";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Daftar Siswa"),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'images/bg_doodle.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SmartRefresher(
            controller: _refreshC,
            physics: const BouncingScrollPhysics(),
            onRefresh: getSiswaAbsen,
            child: Builder(
              builder: (context) {
                if (_apiResponse.getApiStatus == ApiStatus.success) {
                  return ListView.builder(
                    itemCount: _listKegiatan.length,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 12),
                    itemBuilder: (context, index) {
                      Map kegiatan = _listKegiatan[index];
                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        margin: const EdgeInsets.only(left: 16, right: 16, top: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: InkWell(
                          onTap: () {
                            AppNavigator.instance.push(
                              MaterialPageRoute(
                                builder: (context) => PageTryoutJasmaniSiswaDetail(
                                  hashSiswa: kegiatan['hash_user'].toString(),
                                  namaSiswa: kegiatan['nama_lengkap'].toString(),
                                  kdTryout: widget.kdTryout,
                                  kdLokasiAbsen: widget.kdLokasiAbsen,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColor.hitam,
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      kegiatan['foto'].toString(),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: Center(
                                            child: loadingWidget(),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) => Image.asset(
                                        AppImages.logoGold,
                                        width: 50,
                                        height: 50,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      kegiatan['nama_lengkap'].toString(),
                                      style: GoogleFonts.montserrat(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Builder(builder: (context) {
                                          if (kegiatan['absen_masuk'].toString() != "null") {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: colorStatusVerifAbsen(kegiatan['absen_masuk']['status_verif'].toString()).withAlpha(40),
                                                border: Border.all(
                                                  width: 1,
                                                  color: colorStatusVerifAbsen(kegiatan['absen_masuk']['status_verif'].toString()),
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                "Absen Masuk",
                                                style: GoogleFonts.montserrat(
                                                  color: colorStatusVerifAbsen(kegiatan['absen_masuk']['status_verif'].toString()),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          } else {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: colorStatusVerifAbsen("0").withAlpha(40),
                                                border: Border.all(
                                                  width: 1,
                                                  color: colorStatusVerifAbsen("0"),
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                "Belum Absen Masuk",
                                                style: GoogleFonts.montserrat(
                                                  color: colorStatusVerifAbsen("0"),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }
                                        }),
                                        const SizedBox(width: 6),
                                        Builder(builder: (context) {
                                          if (kegiatan['absen_pulang'].toString() != "null") {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: colorStatusVerifAbsen(kegiatan['absen_pulang']['status_verif'].toString()).withAlpha(40),
                                                border: Border.all(
                                                  width: 1,
                                                  color: colorStatusVerifAbsen(kegiatan['absen_pulang']['status_verif'].toString()),
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                "Absen Pulang",
                                                style: GoogleFonts.montserrat(
                                                  color: colorStatusVerifAbsen(kegiatan['absen_pulang']['status_verif'].toString()),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          } else {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: colorStatusVerifAbsen("0").withAlpha(40),
                                                border: Border.all(
                                                  width: 1,
                                                  color: colorStatusVerifAbsen("0"),
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                "Belum Absen Pulang",
                                                style: GoogleFonts.montserrat(
                                                  color: colorStatusVerifAbsen("0"),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }
                                        })
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (_apiResponse.getApiStatus == ApiStatus.loading) {
                  return loadingWidget();
                } else {
                  return emptyWidget(_apiResponse.getMessage);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Color colorStatusVerifAbsen(String statusAbsen) {
    switch (statusAbsen) {
      case "1":
        return Colors.orange;
      case "2":
        return Colors.green;
      case "3":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
