import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/api_response.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/modules/absen/page_data_absensi.dart';
import 'package:absentip/modules/aktivitas/page_aktivitas.dart';
import 'package:absentip/modules/gaji/page_gaji.dart';
import 'package:absentip/modules/kalender/page_kalender.dart';
import 'package:absentip/modules/kegiatan/page_kegiatan.dart';
import 'package:absentip/modules/kegiatan/page_kegiatan_detail.dart';
import 'package:absentip/modules/lembur/page_rekap_lembur.dart';
import 'package:absentip/page_profil_detail.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageBeranda extends StatefulWidget {
  const PageBeranda({Key? key}) : super(key: key);

  @override
  State<PageBeranda> createState() => _PageBerandaState();
}

class _PageBerandaState extends State<PageBeranda> {
  final _refreshC = RefreshController();
  final _apiResponse = ApiResponse();
  final _carouselController = CarouselController();
  late AnimationController _animateControllerPrev;
  late AnimationController _animateControllerNext;

  String _foto = "";
  String _nama = "";

  @override
  void initState() {
    getJadwalAbsen();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SharedPreferences.getInstance().then((value) {
        setState(() {
          _foto = value.getString(FOTO) ?? "";
          _nama = value.getString(NAMA) ?? "";
        });
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _refreshC.dispose();
    super.dispose();
  }

  Future<void> getJadwalAbsen() async {
    setState(() {
      _apiResponse.setApiSatatus = ApiStatus.loading;
    });

    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.jadwalAbsen,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH) ?? "",
        'hash_user': pref.getString(HASH_USER) ?? "",
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
            _apiResponse.setData = response['data'];
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
          Column(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppColor.biru,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: Image.asset(AppImages.bg2).image,
                  ),
                ),
                padding: const EdgeInsets.only(left: 20, right: 20, top: 36, bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        showToast("message");
                        AppNavigator.instance.push(MaterialPageRoute(
                          builder: (context) => const PageProfilDetail(),
                        ));
                      },
                      child: _foto.isEmpty
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
                              imageUrl: _foto,
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(width: 2, color: Colors.grey),
                                  color: Colors.red,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                  ),
                                ),
                              ),
                              progressIndicatorBuilder: (context, url, progressDownload) {
                                return Center(child: loadingWidget());
                              },
                              errorWidget: (context, url, error) {
                                return const CircleAvatar(backgroundImage: AssetImage("assets/images/ic_launcher.jpg"), radius: 50);
                              },
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 10),
                          const Text(
                            "Selamat Datang,",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _nama,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.biru2,
                        AppColor.biru2.withOpacity(0.6),
                        Colors.white.withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          SmartRefresher(
            controller: _refreshC,
            onRefresh: getJadwalAbsen,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    color: AppColor.hitam,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      height: 200,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 130,
                            child: Builder(
                              builder: (context) {
                                if (_apiResponse.getApiStatus == ApiStatus.success) {
                                  List listKegiatan = _apiResponse.getData['Kegiatan'];
                                  if (listKegiatan.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'Jadwal Kegiatan tidak tersedia',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return carouselKegiatan(listKegiatan);
                                  }
                                } else if (_apiResponse.getApiStatus == ApiStatus.loading) {
                                  return loadingWidget(size: 14, color: Colors.white);
                                } else {
                                  return emptyWidget(_apiResponse.getMessage, size: 12, color: Colors.white);
                                }
                              },
                            ),
                          ),
                          const Divider(color: Colors.white, height: 1),
                          const SizedBox(height: 4),
                          const Text(
                            "Absen Harian Anda",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                if (_apiResponse.getApiStatus == ApiStatus.success) {
                                  Map? jadwalMengajar = _apiResponse.getData['mengajar'];
                                  if (jadwalMengajar == null) {
                                    return const Center(
                                      child: Text(
                                        'Jadwal mengajar tidak tersedia',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Absen Masuk",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                              Text(
                                                jadwalMengajar['jam_masuk'].toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const VerticalDivider(
                                          color: Colors.white,
                                          indent: 8,
                                          endIndent: 8,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Absen Pulang",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                              Text(
                                                jadwalMengajar['jam_pulang'].toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                } else if (_apiResponse.getApiStatus == ApiStatus.loading) {
                                  return loadingWidget(size: 14, color: Colors.white);
                                } else {
                                  return emptyWidget(_apiResponse.getMessage, size: 12, color: Colors.white);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            itemMenu("images/ic_izin.png", "rekap\nAbsen", () {
                              AppNavigator.instance.push(MaterialPageRoute(
                                builder: (context) => const PageDataAbsensi(),
                              ));
                            }),
                            itemMenu("images/ic_jasmani.png", "Kegiatan\nJasmani", () {
                              AppNavigator.instance.push(MaterialPageRoute(
                                builder: (context) => const PageKegiatan(jenisKegiatan: "jasmani"),
                              ));
                            }),
                            itemMenu("images/ic_akademik.png", "Kegiatan\nAkademik", () {
                              AppNavigator.instance.push(MaterialPageRoute(
                                builder: (context) => const PageKegiatan(jenisKegiatan: "akademik"),
                              ));
                            }),
                            itemMenu("images/ic_psikolog.png", "Kegiatan\nPsikologi", () {
                              AppNavigator.instance.push(MaterialPageRoute(
                                builder: (context) => const PageKegiatan(jenisKegiatan: "psikologi"),
                              ));
                            }),
                          ],
                        ),
                        Row(
                          children: [
                            itemMenu("images/ic_lembur.png", "Pengajuan\nLembur", () {
                              AppNavigator.instance.push(MaterialPageRoute(
                                builder: (context) => const PageRekapLembur(),
                              ));
                            }),
                            itemMenu("images/ic_gaji.png", "Informasi\nGaji", () {
                              AppNavigator.instance.push(MaterialPageRoute(
                                builder: (context) => const PageGaji(),
                              ));
                            }),
                            itemMenu("images/ic_document.png", "Laporan\nAktivitas", () {
                              AppNavigator.instance.push(MaterialPageRoute(
                                builder: (context) => const PageAktivitas(),
                              ));
                            }),
                            itemMenu("images/ic_calendar.png", "Kalender\nKegiatan", () {
                              AppNavigator.instance.push(MaterialPageRoute(
                                builder: (context) => const PageKalender(),
                              ));
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget carouselKegiatan(List listKegiatan) {
    return Stack(
      children: [
        const SizedBox(height: 12),
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: MediaQuery.of(context).size.width * 0.6,
            initialPage: 0,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 12),
            autoPlayAnimationDuration: const Duration(milliseconds: 1000),
            autoPlayCurve: Curves.fastOutSlowIn,
            viewportFraction: 1,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              _animateControllerPrev.reset();
              _animateControllerPrev.forward();
              _animateControllerNext.reset();
              _animateControllerNext.forward();
            },
          ),
          items: listKegiatan
              .map(
                (element) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: InkWell(
                    onTap: () {
                      AppNavigator.instance.push(
                        MaterialPageRoute(
                          builder: (context) => PageKegiatanDetail(
                            kdTryout: element['kd_tryout'].toString(),
                            jenisKegiatan: element['jenis'].toString(),
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        color: AppColor.biru,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                element['nama_tryout'].toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                parseDateInd(element['waktu_mulai'].toString(), "HH:mm dd MMM yyyy") + " - " + parseDateInd(element['waktu_mulai'].toString(), "HH:mm dd MMM yyyy"),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          child: InkWell(
            onTap: () {
              _carouselController.previousPage();
            },
            child: FadeIn(
              duration: const Duration(seconds: 2),
              controller: (p0) => _animateControllerPrev = p0,
              manualTrigger: true,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(3, 0),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.menuLeft,
                  color: AppColor.hitam,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: () => _carouselController..nextPage(),
            child: FadeIn(
              duration: const Duration(seconds: 2),
              controller: (p0) => _animateControllerNext = p0,
              manualTrigger: true,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(3, 0),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.menuRight,
                  color: AppColor.hitam,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget itemMenu(String icon, String title, void Function()? onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Image.asset(
                  icon,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
