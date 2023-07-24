import 'dart:developer';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/ApiStatus.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/my_colors.dart';
import 'package:absentip/page_notification_detail.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/text_montserrat.dart';
import 'package:absentip/wigets/alert_dialog_oke_widget.dart';
import 'package:absentip/wigets/konfirmasi_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageNotification extends StatefulWidget {
  const PageNotification({Key? key}) : super(key: key);

  @override
  State<PageNotification> createState() => _PageNotificationState();
}

class _PageNotificationState extends State<PageNotification> {
  List dataNotif = [];
  ApiStatus _apiStatus = ApiStatus.loading;
  final _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    getNotifikasi();
    super.initState();
  }

  getNotifikasi() async {
    setState(() {
      dataNotif.clear();
      _apiStatus = ApiStatus.loading;
    });

    if (_refreshController.isRefresh) {
      _apiStatus = ApiStatus.success;
    }
    final pref = await SharedPreferences.getInstance();

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.urlGetNotifikasi,
      params: {
        'hash_user': pref.getString(HASH_USER)!,
        'token_auth': pref.getString(TOKEN_AUTH)!,
      },
    );

    if (response!['data'].isNotEmpty) {
      if (response['success']) {
        for (int i = 0; i < response['data'].length; i++) {
          dataNotif.add(response['data'][i]);
        }
        setState(() {
          _apiStatus = ApiStatus.success;
        });
      } else {
        showToast(response['message'].toString());
        setState(() {
          _apiStatus = ApiStatus.failed;
        });
      }
    } else {
      showToast(response['message'].toString());
      setState(() {
        _apiStatus = ApiStatus.empty;
      });
    }

    if (_refreshController.isRefresh) {
      _refreshController.refreshCompleted();
    }

    log(dataNotif.toString());
  }

  Future<Map<String, dynamic>?> deleteNotifikasi(String idNotif) async {
    await showLoading();
    final pref = await SharedPreferences.getInstance();

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.urlDeleteNotifikasi,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH)!,
        'hash_user': pref.getString(HASH_USER)!,
        'id_notif': idNotif,
      },
    );

    await dismissLoading();

    return response;
  }

  Future<Map<String, dynamic>?> readNotifikasi(String idNotif) async {
    final pref = await SharedPreferences.getInstance();

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.urlReadNotifikasi,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH)!,
        'hash_user': pref.getString(HASH_USER)!,
        'id_notif': idNotif,
      },
    );
    log("===============================================");
    // log(response.toString());

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            flexibleSpace: const Image(
              image: AssetImage(AppImages.bg2),
              fit: BoxFit.cover,
            ),
            centerTitle: true,
            // systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: colorPrimary,

            title: const SizedBox(
              // width: double.infinity,
              child: Text(
                "Notifikasi",
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  MdiIcons.filterSettingsOutline,
                ),
                onPressed: () {},
              )
            ],
          ),
          body: SmartRefresher(
            controller: _refreshController,
            onRefresh: () => getNotifikasi(),
            header: const ClassicHeader(),
            physics: const BouncingScrollPhysics(),
            child: Builder(
              builder: (context) {
                if (_apiStatus == ApiStatus.success) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: dataNotif.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: InkWell(
                              onLongPress: () async {
                                final result = await showDialog(
                                  context: context,
                                  builder: (context) => KonfimasiWidget(message: "Apakah Anda Yakin Ingin Menghapus Notifikasi?"),
                                );

                                log(result.toString());

                                if (result == true) {
                                  final response = await deleteNotifikasi(dataNotif[index]['id_notif'].toString());
                                  if (response != null) {
                                    if (response['success']) {
                                      final result = await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialogOkWidget(message: response['message']),
                                      );
                                      log(result.toString());
                                    } else {
                                      showToast(response['message'].toString());
                                    }
                                  }
                                }
                                getNotifikasi();
                              },
                              onTap: () async {
                                final response = await readNotifikasi(dataNotif[index]['id_notif'].toString());
                                if (response!['success']) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => PageNotificationDetail(data: dataNotif[index]),
                                  ));
                                }
                              },
                              child: Card(
                                color: Colors.white,
                                elevation: 3,
                                margin: const EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: Image.asset(
                                              AppImages.notifikasi,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          Visibility(
                                            visible: dataNotif[index]['read'].toString() == "0",
                                            child: Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: Colors.red, // border color
                                                  shape: BoxShape.circle,
                                                  border: Border.all(width: 1, color: Colors.white),
                                                ),
                                                child: const Text(
                                                  "*",
                                                  style: TextStyle(color: Colors.white, fontSize: 6),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextMontserrat(
                                              text: dataNotif[index]['judul'],
                                              fontSize: 14,
                                              bold: true,
                                              color: Colors.black,
                                            ),
                                            const SizedBox(height: 4),
                                            TextMontserrat(
                                              text: dataNotif[index]['pesan'],
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                            SizedBox(height: 4),
                                            TextMontserrat(
                                              text: dataNotif[index]['created_at'],
                                              fontSize: 10,
                                              color: Colors.black,
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                        );
                      },
                    ),
                  );
                } else if (_apiStatus == ApiStatus.loading) {
                  return Center(child: CupertinoActivityIndicator());
                } else if (_apiStatus == ApiStatus.empty) {
                  return const Center(child: Text("Tidak Ada Notifikasi"));
                } else {
                  return const Center(child: Text("Terjadi kesalahan"));
                }
              },
            ),
          )),
    );
  }
}
