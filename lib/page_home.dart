import 'package:absentip/data/provider/main_provider.dart';
import 'package:absentip/modules/kegiatan/page_kegiatan.dart';
import 'package:absentip/modules/notifikasi/page_notification.dart';
import 'package:absentip/page_beranda.dart';
import 'package:absentip/page_profil.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'modules/absen/page_absen.dart';

class PageHome extends StatefulWidget {
  const PageHome({Key? key}) : super(key: key);

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  late MainProvider mainProvider;
  final PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  DateTime? currentBackPressTime;

  @override
  void initState() {
    mainProvider = context.read<MainProvider>();
    mainProvider.initIndex();
    super.initState();
  }

  void onTap(int value) {
    currentIndex = value;
    pageController.jumpToPage(value);
    mainProvider.setCurrentIndex(value);
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 1)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Press the back button again to exit"),
        duration: Duration(seconds: 1),
      ));
      return Future.value(false);
    }
    // FlutterForegroundTask.minimizeApp();
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Consumer<MainProvider>(
          builder: (BuildContext context, value, Widget? child) {
            return PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: mainProvider.setCurrentIndex,
              children: const [
                PageBeranda(),
                PageKegiatan(),
                PageAbsen(),
                PageNotification(),
                PageProfil(),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "Absen",
        backgroundColor: AppColor.biru2,
        onPressed: () {
          onTap(2);
        },
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: 36,
              child: Icon(
                MdiIcons.calendarCheck,
                color: Colors.white,
              ),
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
      bottomNavigationBar: Container(
        color: Colors.white,
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          elevation: 3,
          color: AppColor.biru2,
          notchMargin: 5, //notche margin between floating button and bottom appbar
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 1, thickness: 1),
              Consumer<MainProvider>(
                builder: (context, value, child) {
                  return Container(
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
                                    Icon(
                                      Icons.home,
                                      color: value.currentIndex == 0 ? Colors.white : Colors.white60,
                                      size: value.currentIndex == 0 ? 28 : 24,
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
                                    color: value.currentIndex == 0 ? Colors.white : Colors.white,
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
                                    Icon(
                                      MdiIcons.calendarBadge,
                                      color: value.currentIndex == 1 ? Colors.white : Colors.white60,
                                      size: value.currentIndex == 1 ? 28 : 24,
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
                                    color: value.currentIndex == 1 ? Colors.white : Colors.white,
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
                                  color: value.currentIndex == 3 ? Colors.white : Colors.white60,
                                  size: value.currentIndex == 3 ? 28 : 24,
                                ),
                                Text(
                                  "Notifikasi",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: value.currentIndex == 3 ? Colors.white : Colors.white,
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
                                Icon(
                                  Icons.person,
                                  color: value.currentIndex == 4 ? Colors.white : Colors.white60,
                                  size: value.currentIndex == 4 ? 28 : 24,
                                ),
                                Text(
                                  "Profil",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: value.currentIndex == 4 ? Colors.white : Colors.white,
                                    fontWeight: value.currentIndex == 4 ? FontWeight.bold : FontWeight.normal,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
