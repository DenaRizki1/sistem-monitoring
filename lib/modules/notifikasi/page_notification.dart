import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/modules/notifikasi/page_notification_detail.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/text_montserrat.dart';
import 'package:absentip/wigets/alert_dialog_confirm_widget.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_color.dart';

class PageNotification extends StatefulWidget {
  const PageNotification({Key? key}) : super(key: key);

  @override
  State<PageNotification> createState() => _PageNotificationState();
}

class _PageNotificationState extends State<PageNotification> {
  final _refreshController = RefreshController(initialRefresh: false);
  final List _listNotif = [];
  ApiStatus _apiStatus = ApiStatus.loading;

  @override
  void initState() {
    getNotifikasi();
    super.initState();
  }

  getNotifikasi() async {
    setState(() {
      _apiStatus = ApiStatus.loading;
      _listNotif.clear();
    });

    final pref = await SharedPreferences.getInstance();

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.notif,
      params: {
        'hash_user': pref.getString(HASH_USER) ?? "",
        'token_auth': pref.getString(TOKEN_AUTH) ?? "",
      },
    );

    if (response != null) {
      if (response['success']) {
        final data = response['data'];
        _listNotif.addAll(data);

        if (mounted) {
          setState(() {
            _apiStatus = ApiStatus.success;
          });
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
      showToast("Terjadi kesalahan");
      if (mounted) {
        setState(() {
          _apiStatus = ApiStatus.failed;
        });
      }
    }

    if (_refreshController.isRefresh) {
      _refreshController.refreshCompleted();
    }
  }

  Future<Map<String, dynamic>?> deleteNotifikasi(String idNotif) async {
    await showLoading();
    final pref = await SharedPreferences.getInstance();

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.deleteNotif,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH)!,
        'hash_user': pref.getString(HASH_USER)!,
        'id_notif': idNotif,
      },
    );

    await dismissLoading();

    return response;
  }

  Future<void> readNotifikasi(String idNotif) async {
    loadingWidget();
    final pref = await SharedPreferences.getInstance();
    // ignore: unused_local_variable
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.readNotif,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH)!,
        'hash_user': pref.getString(HASH_USER)!,
        'id_notif': idNotif,
      },
    );
    dismissLoading();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Notifikasi", leading: null),
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
          Container(
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
          SmartRefresher(
            controller: _refreshController,
            onRefresh: () => getNotifikasi(),
            physics: const BouncingScrollPhysics(),
            child: Builder(
              builder: (context) {
                if (_apiStatus == ApiStatus.success) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _listNotif.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: InkWell(
                              onLongPress: () async {
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => const AlertDialogConfirmWidget(message: "Apakah Anda Yakin Ingin Menghapus Notifikasi?"),
                                );

                                if (result ?? false) {
                                  final response = await deleteNotifikasi(_listNotif[index]['id_notif'].toString());
                                  if (response != null) {
                                    showToast(response['message'].toString());
                                    if (response['success']) {
                                      getNotifikasi();
                                    }
                                  } else {
                                    showToast("Terjadi kesalahan");
                                  }
                                }
                              },
                              onTap: () async {
                                await readNotifikasi(_listNotif[index]['id_notif'].toString());
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PageNotificationDetail(data: _listNotif[index]),
                                ));
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
                                            visible: _listNotif[index]['read'].toString() == "0",
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
                                              text: _listNotif[index]['judul'],
                                              fontSize: 14,
                                              bold: true,
                                              color: Colors.black,
                                            ),
                                            const SizedBox(height: 4),
                                            TextMontserrat(
                                              text: _listNotif[index]['pesan'],
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                            const SizedBox(height: 4),
                                            TextMontserrat(
                                              text: _listNotif[index]['created_at'],
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
                  return loadingWidget();
                } else if (_apiStatus == ApiStatus.empty) {
                  return emptyWidget("Tidak ada notifikasi");
                } else {
                  return emptyWidget("Terjadi kesalahan");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
