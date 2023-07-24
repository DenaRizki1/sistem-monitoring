import 'dart:developer';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/ApiStatus.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/data/provider/main_provider.dart';
import 'package:absentip/model/absen_harian.dart';
import 'package:absentip/page_data_absensi.dart';
import 'package:absentip/page_detail_absen.dart';
import 'package:absentip/page_jadwal.dart';
import 'package:absentip/page_notification.dart';
import 'package:absentip/page_permintaan_izin.dart';
import 'package:absentip/page_rekap_absen_harian.dart';
import 'package:absentip/model/tryout.dart';
import 'package:absentip/page_profil.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/widgets.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'harian/page_beranda_absen_harian.dart';
import 'page_list_tryout.dart';
import 'my_colors.dart';
import 'utils/api.dart';
import 'utils/constants.dart';
import 'utils/helpers.dart';
import 'utils/sessions.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PageBeranda extends StatefulWidget {
  const PageBeranda({Key? key}) : super(key: key);

  @override
  State<PageBeranda> createState() => _PageBerandaState();
}

class _PageBerandaState extends State<PageBeranda> {
  bool loadingJadwalTryOut = true, loadingAbsenHariIni = true, jadwalAbsen = false;
  List<Tryout> list = [];
  String nama = "", foto = "", jamAbsenMasuk = "", jamAbsenPulang = "", keteranganMasuk = "", keteranganPulang = "", pesanKosong = "";
  Map data = {};

  @override
  void initState() {
    // TODO: implement initState
    mainProvider = context.read<MainProvider>();

    mainProvider.initIndex();
    super.initState();
    init();
  }

  late MainProvider mainProvider;

  final PageController pageController = PageController(initialPage: 0);

  init() async {
    String nm = "", ft = "";
    nm = (await getPrefrence(NAMA))!;
    ft = (await getPrefrence(FOTO))!;
    setState(() {
      nama = nm;
      foto = ft;
    });
    getAbsenHariIni();
    getJadwalTryout();
  }

  int currentIndex = 0;

  void onTap(int value) {
    currentIndex = value;
    pageController.jumpToPage(value);
    mainProvider.setCurrentIndex(value);
  }

  Future _onRefresh() async {
    init();
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();

    return Future.value(false);
    // return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WillPopScope(
          onWillPop: onWillPop,
          child: Consumer<MainProvider>(
            builder: (BuildContext context, value, Widget? child) {
              return Scaffold(
                body: Column(
                  children: [
                    currentIndex != 2 && currentIndex != 3 && currentIndex != 4
                        ? Container(
                            decoration: BoxDecoration(
                              color: colorPrimary,
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: Image.asset(AppImages.bg2).image,
                              ),
                            ),
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
                            child: Row(
                              children: [
                                foto == ""
                                    ? Container(
                                        width: 44,
                                        height: 44,
                                        decoration: const BoxDecoration(
                                          color: Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    : CachedNetworkImage(
                                        width: 44,
                                        height: 44,
                                        imageUrl: foto,
                                        imageBuilder: (context, imageProvider) => Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(width: 2, color: colorPrimary),
                                            color: Colors.red,
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.topCenter,
                                            ),
                                          ),
                                        ),
                                        progressIndicatorBuilder: (context, url, progressDownload) {
                                          return const Center(child: CupertinoActivityIndicator());
                                        },
                                        errorWidget: (context, url, error) {
                                          return const CircleAvatar(backgroundImage: AssetImage("assets/images/ic_launcher.jpg"), radius: 50);
                                        },
                                      ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(width: 10),
                                      const Text("Selamat Datang,"),
                                      Text(
                                        nama,
                                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w900),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    Expanded(
                      child: PageView(
                        controller: pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: mainProvider.setCurrentIndex,
                        children: [
                          beranda(context),
                          const PageJadwal(),
                          const PageBerandaAbsenHarian(),
                          const PageNotification(),
                          const PageProfil(),
                        ],
                      ),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  heroTag: "Absen",
                  backgroundColor: colorPrimary,
                  onPressed: () {
                    onTap(2);
                  },
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: Icon(MdiIcons.calendarCheck),
                      ),
                      Visibility(
                        visible: false,
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: SizedBox.shrink(),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(
                                height: 16,
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.only(left: 5, right: 4, top: 2, bottom: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  // borderRadius: const BorderRadius.horizontal(left: Radius.circular(12), right: Radius.circular(12)),
                                  shape: BoxShape.circle,
                                  border: Border.all(width: 1, color: Colors.white),
                                ),
                                child: Center(
                                  child: Text(
                                    "value.homeData['count_penjualan'].toString()",
                                    style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                bottomNavigationBar: BottomAppBar(
                  shape: const CircularNotchedRectangle(),

                  elevation: 3,
                  color: AppColor.hitam,
                  // color: Color.fromARGB(255, 123, 209, 126),
                  notchMargin: 5, //notche margin between floating button and bottom appbar
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Divider(height: 1, thickness: 1),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () => onTap(0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Stack(
                                      children: [
                                        SizedBox(
                                            width: double.infinity,
                                            child: Image.asset(
                                              'images/beranda.png',
                                              width: 24,
                                              height: 24,
                                              color: value.currentIndex == 0 ? null : Colors.white,
                                            )
                                            // Icon(
                                            //   value.currentIndex == 0 ? MdiIcons.home : MdiIcons.homeOutline,
                                            //   color: value.currentIndex == 0 ? navigationTheme.selectedItemColor : navigationTheme.unselectedItemColor,
                                            // ),
                                            ),
                                        Consumer<MainProvider>(
                                          builder: (context, value, child) {
                                            return Visibility(
                                              visible: false,
                                              child: Row(
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: SizedBox.shrink(),
                                                  ),
                                                  Flexible(
                                                    flex: 1,
                                                    child: Container(
                                                      height: 16,
                                                      padding: const EdgeInsets.symmetric(vertical: 2.4, horizontal: 5.4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        // borderRadius: BorderRadius.horizontal(left: Radius.circular(12), right: Radius.circular(12)),
                                                        shape: BoxShape.circle,
                                                        border: Border.all(width: 1, color: Colors.white),
                                                      ),
                                                      child: Text(
                                                        "value.homeData['count_distribusi'].toString()",
                                                        style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                    Text(
                                      "Beranda",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        color: value.currentIndex == 0 ? colorPrimary : Colors.white,
                                        fontWeight: value.currentIndex == 0 ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () => onTap(1),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Stack(
                                      children: [
                                        SizedBox(
                                            width: double.infinity,
                                            child: Icon(
                                              MdiIcons.calendarBadge,
                                              color: value.currentIndex == 1 ? colorPrimary : Colors.white,
                                            )
                                            // Icon(
                                            //   value.currentIndex == 0 ? MdiIcons.home : MdiIcons.homeOutline,
                                            //   color: value.currentIndex == 0 ? navigationTheme.selectedItemColor : navigationTheme.unselectedItemColor,
                                            // ),
                                            ),
                                        Consumer<MainProvider>(
                                          builder: (context, value, child) {
                                            return Visibility(
                                              visible: false,
                                              child: Row(
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: SizedBox.shrink(),
                                                  ),
                                                  Flexible(
                                                    flex: 1,
                                                    child: Container(
                                                      height: 16,
                                                      padding: const EdgeInsets.symmetric(vertical: 2.4, horizontal: 5.4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        // borderRadius: BorderRadius.horizontal(left: Radius.circular(12), right: Radius.circular(12)),
                                                        shape: BoxShape.circle,
                                                        border: Border.all(width: 1, color: Colors.white),
                                                      ),
                                                      child: Text(
                                                        "value.homeData['count_distribusi'].toString()",
                                                        style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                    Text(
                                      "Jadwal",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        color: value.currentIndex == 1 ? colorPrimary : Colors.white,
                                        fontWeight: value.currentIndex == 1 ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () {},
                                enableFeedback: false,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      MdiIcons.cashSync,
                                      color: Colors.transparent,
                                    ),
                                    Text(
                                      "",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () => onTap(3),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.notifications,
                                      color: value.currentIndex == 3 ? colorPrimary : Colors.white,
                                    ),
                                    // Icon(
                                    //   value.currentIndex == 3 ? MdiIcons.cog : MdiIcons.cogOutline,
                                    //   color: value.currentIndex == 3 ? navigationTheme.selectedItemColor : navigationTheme.unselectedItemColor,
                                    // ),
                                    Text(
                                      "Notifikasi",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        color: value.currentIndex == 3 ? colorPrimary : Colors.white,
                                        fontWeight: value.currentIndex == 3 ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () => onTap(4),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'images/pengaturan.png',
                                      width: 24,
                                      height: 24,
                                      color: value.currentIndex == 4 ? null : Colors.white,
                                    ),
                                    // Icon(
                                    //   value.currentIndex == 3 ? MdiIcons.cog : MdiIcons.cogOutline,
                                    //   color: value.currentIndex == 3 ? navigationTheme.selectedItemColor : navigationTheme.unselectedItemColor,
                                    // ),
                                    Text(
                                      "Pengaturan",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        color: value.currentIndex == 4 ? colorPrimary : Colors.white,
                                        fontWeight: value.currentIndex == 4 ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget widgetMenuItem(String icon, String label) {
    return Column(
      children: [
        Image.asset(
          icon,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // getAbsenHariIni() async {
  //   setState(() {
  //     loadingAbsenHariIni = true;
  //   });

  //   if (await Helpers.isNetworkAvailable()) {
  //     try {
  //       String tokenAuth = "", hashUser = "";
  //       tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
  //       hashUser = (await getPrefrence(HASH_USER))!;

  //       var param = {
  //         'token_auth': tokenAuth,
  //         'hash_user': hashUser,
  //       };

  //       log(param.toString());
  //       http.Response response = await http.post(
  //         Uri.parse(urlGetAbsenHarian),
  //         headers: headers,
  //         body: param,
  //       );

  //       setState(() {
  //         loadingAbsenHariIni = false;
  //       });

  //       log(response.body);

  //       Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
  //       log(jsonResponse.toString());
  //       if (jsonResponse.containsKey("error")) {
  //       } else {
  //         bool success = jsonResponse['success'];
  //         if (success) {
  //           setState(() {
  //             jadwalAbsen = true;
  //             if (jsonResponse['absenMasuk'].toString().toLowerCase() != "null") {
  //               jamAbsenMasuk = jsonResponse["absenMasuk"]["jam_absen"].toString();
  //               keteranganMasuk = jsonResponse["absenMasuk"]["keterangan"].toString();
  //             } else {
  //               jamAbsenMasuk = "-";
  //               keteranganMasuk = "";
  //             }
  //             if (jsonResponse['absenPulang'].toString().toLowerCase() != "null") {
  //               jamAbsenPulang = jsonResponse["absenPulang"]["jam_absen"].toString();
  //               keteranganPulang = jsonResponse["absenPulang"]["keterangan"].toString();
  //             } else {
  //               jamAbsenPulang = "-";
  //               keteranganPulang = "";
  //             }
  //           });
  //         } else {
  //           setState(() {
  //             jadwalAbsen = false;
  //             jamAbsenMasuk = "Tidak ada jadwal";
  //             jamAbsenPulang = "Tidak ada jadwal";
  //             keteranganMasuk = "";
  //             keteranganPulang = "";
  //           });
  //         }
  //       }
  //     } catch (e, stacktrace) {
  //       log(stacktrace.toString());
  //       setState(() {
  //         loadingAbsenHariIni = false;
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       loadingAbsenHariIni = false;
  //     });
  //   }
  // }

  ApiStatus _apiStatus = ApiStatus.loading;

  getAbsenHariIni() async {
    if (mounted) {
      setState(() {
        _apiStatus = ApiStatus.loading;
      });
    }

    final pref = await SharedPreferences.getInstance();

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.urlGetAbsenHarian,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH)!,
        'hash_user': pref.getString(HASH_USER)!,
        // 'bulan': DateTime.now().month.toString(),
        // 'tahun': DateTime.now().year.toString(),
      },
    );

    data = response!;
    if (response.isNotEmpty) {
      if (response['success']) {
        if (response['absenMasuk'] != null) {
          jamAbsenMasuk = response['absenMasuk']['jam_absen'].toString();
          keteranganMasuk = response['absenMasuk']['keterangan'].toString();
        } else {
          jamAbsenMasuk = "-";
          keteranganMasuk = "";
        }

        if (response['absenPulang'] != null) {
          jamAbsenPulang = response['absenPulang']['jam_absen'].toString();
          keteranganPulang = response['absenPulang']['keterangan'].toString();
        } else {
          jamAbsenPulang = "-";
          keteranganPulang = "-";
        }

        if (mounted) {
          setState(() {
            _apiStatus = ApiStatus.success;
          });

          log(_apiStatus.toString());
        }
      } else {
        showToast(response['message'].toString());
        if (mounted) {
          setState(() {
            _apiStatus = ApiStatus.empty;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _apiStatus = ApiStatus.failed;
        });
      }
    }
    log("============================");
    log(data.toString());
  }

  getJadwalTryout() async {
    setState(() {
      _apiStatus = ApiStatus.loading;
    });

    final pref = await SharedPreferences.getInstance();

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.urlListTryoutHariIni,
      params: {
        'username': pref.getString(EMAIL)!,
        'token_auth': pref.getString(TOKEN_AUTH)!,
        'hash_user': pref.getString(HASH_USER)!,
      },
    );

    log(response.toString());

    if (response != null) {
      if (response['success']) {
        if (mounted) {
          list.clear();
        }

        for (int i = 0; i < response['data'].length; i++) {
          if (mounted) {
            setState(() {
              list.add(response['data'][i]);
              _apiStatus = ApiStatus.success;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            loadingJadwalTryOut = false;
          });
        }
        pesanKosong = response['message'];
      }
    } else {
      showToast(response!['message'].toString());
    }
  }

  // getListTryoutHariIni() async {
  //   setState(() {
  //     loadingJadwalTryOut = true;
  //     list.clear();
  //   });

  //   if (await Helpers.isNetworkAvailable()) {
  //     try {
  //       String email = "", tokenAuth = "", hashUser = "";
  //       email = (await getPrefrence(EMAIL))!;
  //       tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
  //       hashUser = (await getPrefrence(HASH_USER))!;

  //       var param = {
  //         'username': email,
  //         'token_auth': tokenAuth,
  //         'hash_user': hashUser,
  //       };

  //       http.Response response = await http.post(
  //         Uri.parse(urlListTryoutHariIni),
  //         headers: headers,
  //         body: param,
  //       );

  //       setState(() {
  //         loadingJadwalTryOut = false;
  //       });

  //       log(response.body);

  //       Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
  //       log(jsonResponse.toString());
  //       if (jsonResponse.containsKey("error")) {
  //       } else {
  //         bool success = jsonResponse['success'];
  //         String message = jsonResponse["message"];
  //         if (success) {
  //           setState(() {
  //             list.clear();
  //           });

  //           for (int i = 0; i < jsonResponse["data"].length; i++) {
  //             Tryout tryout = Tryout();
  //             tryout.jenisTryout = jsonResponse["data"][i]["jenis_tryout"].toString();
  //             tryout.idTryout = jsonResponse["data"][i]["id_tryout"].toString();
  //             tryout.kdTryout = jsonResponse["data"][i]["kd_tryout"].toString();
  //             tryout.namaTryout = jsonResponse["data"][i]["nama_tryout"].toString();
  //             tryout.keterangan = jsonResponse["data"][i]["keterangan"].toString();
  //             tryout.waktu = jsonResponse["data"][i]["waktu"].toString();
  //             tryout.waktuMulai = jsonResponse["data"][i]["waktu_mulai_formatted"].toString();
  //             tryout.waktuSelesai = jsonResponse["data"][i]["waktu_selesai_formatted"].toString();
  //             tryout.jumlahSoal = jsonResponse["data"][i]["jumlah_soal"].toString();
  //             tryout.finish = jsonResponse["data"][i]["finish"].toString();
  //             tryout.kdPengajar = jsonResponse["data"][i]["kd_pengajar"].toString();
  //             tryout.createdAt = jsonResponse["data"][i]["created_at"].toString();
  //             tryout.absenTryout.bisaAbsen = jsonResponse["data"][i]["absen"]["bisa_absen"].toString();
  //             setState(() {
  //               list.add(tryout);
  //             });
  //           }
  //         } else {
  //           setState(() {
  //             pesanKosong = message;
  //           });
  //         }
  //       }
  //     } catch (e, stacktrace) {
  //       log(stacktrace.toString());
  //       setState(() {
  //         loadingJadwalTryOut = false;
  //         pesanKosong = e.toString();
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       loadingJadwalTryOut = false;
  //       pesanKosong = "Tidak ada koneksi internet";
  //     });
  //   }
  // }

  Widget beranda(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.asset(
            'images/bg_doodle.jpg',
            fit: BoxFit.cover,
            // color: const Color.fromRGBO(255, 255, 255, 0.1),
            // colorBlendMode: BlendMode.modulate,
          ),
        ),
        RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 148,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xffc18e28),
                          // Color(0xffc18e28),
                          Color(0xffc18e28),
                          Colors.white.withOpacity(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      color: AppColor.hitam,
                      margin: EdgeInsets.zero,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Absen Masuk",
                                            style: GoogleFonts.montserrat(color: AppColor.kuning),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "Absen Pulang",
                                            style: GoogleFonts.montserrat(color: AppColor.kuning),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => PageDetailAbsen(dataAbsen: data),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    MdiIcons.history,
                                    color: AppColor.kuning,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: Icon(
                                                MdiIcons.clock,
                                                color: AppColor.kuning,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            _apiStatus == ApiStatus.success
                                                ? Text(
                                                    jamAbsenMasuk,
                                                    textAlign: TextAlign.end,
                                                    style: GoogleFonts.montserrat(
                                                      color: AppColor.kuning,
                                                      fontSize: jadwalAbsen ? 16 : 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                : const CupertinoActivityIndicator(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const VerticalDivider(
                                        width: 1,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              MdiIcons.clock,
                                              color: AppColor.kuning,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            _apiStatus == ApiStatus.success
                                                ? Text(
                                                    jamAbsenPulang,
                                                    textAlign: TextAlign.start,
                                                    style: GoogleFonts.montserrat(
                                                      color: AppColor.kuning,
                                                      fontSize: jadwalAbsen ? 16 : 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                : const CupertinoActivityIndicator(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 16, right: 16, bottom: 5),
                    child: !loadingJadwalTryOut
                        ? Text(
                            "Jadwal Tryout Anda",
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Jadwal Tryout Anda",
                                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const CupertinoActivityIndicator(),
                              const Expanded(
                                child: SizedBox(),
                              ),
                            ],
                          ),
                  ),
                  !loadingJadwalTryOut
                      ? (list.isNotEmpty
                          ? ExpandablePageView.builder(
                              controller: PageController(viewportFraction: 0.9),
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                return widgetItemTryout(context, list[index]);
                              },
                            )
                          : Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                elevation: 5,
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                color: colorInfo,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    pesanKosong,
                                    style: GoogleFonts.montserrat(fontSize: 12),
                                  ),
                                ),
                              ),
                            ))
                      : const SizedBox(),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PageDataAbsensi()));
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'images/ic_izin.png',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Rekap\nAbsen",
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        height: 1.2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const PageListTryout(
                                                jenisTryout: JenisTryout.jasmani,
                                              )));
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'images/ic_jasmani.png',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Kegiatan\nJasmani",
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        height: 1.2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const PageListTryout(
                                                jenisTryout: JenisTryout.akademik,
                                              )));
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'images/ic_akademik.png',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Kegiatan\nAkademik",
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        height: 1.2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const PageListTryout(
                                                jenisTryout: JenisTryout.psikologi,
                                              )));
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'images/ic_psikolog.png',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Kegiatan\nPsikologi",
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        height: 1.2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
