// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/api_response.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/modules/aktivitas/page_update_aktivitas.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:absentip/wigets/show_image_page.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageDetailAktivitas extends StatefulWidget {
  final String hashAktivitas;

  const PageDetailAktivitas({Key? key, required this.hashAktivitas}) : super(key: key);

  @override
  State<PageDetailAktivitas> createState() => _PageDetailAktivitasState();
}

class _PageDetailAktivitasState extends State<PageDetailAktivitas> {
  final _apiResponse = ApiResponse();
  String _hashAktivitas = "";
  Map _dataAktivitas = {};
  List _listFoto = [];

  @override
  void initState() {
    _hashAktivitas = widget.hashAktivitas;
    getAktivitas();
    WidgetsBinding.instance.addPostFrameCallback((_) {});

    super.initState();
  }

  Future<void> getAktivitas() async {
    setState(() {
      _apiResponse.setApiSatatus = ApiStatus.loading;
    });

    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.aktivitasDetail,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH).toString(),
        'hash_user': pref.getString(HASH_USER).toString(),
        'hash_aktivitas': _hashAktivitas,
      },
    );

    if (response != null) {
      if (response['success']) {
        if (mounted) {
          setState(() {
            _apiResponse.setApiSatatus = ApiStatus.success;
            _dataAktivitas = response['data'];
            _listFoto = jsonDecode(_dataAktivitas['foto_aktivitas'].toString());
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
      appBar: appBarWidget(
        parseDateInd(_dataAktivitas['tgl_aktivitas'], "dd MMMM yyyy"),
        action: [
          IconButton(
            onPressed: () async {
              final result = await AppNavigator.instance.push(
                MaterialPageRoute(
                  builder: (context) => PageUpdateAktivitas(dataAktivitas: _dataAktivitas),
                ),
              );

              if (result ?? false) {
                getAktivitas();
              }
            },
            icon: Icon(
              MdiIcons.noteEdit,
              color: Colors.white,
            ),
            tooltip: "Ubah Aktivitas",
          )
        ],
      ),
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
          Builder(
            builder: (context) {
              if (_apiResponse.getApiStatus == ApiStatus.success) {
                return ListView(
                  shrinkWrap: true,
                  padding: FxSpacing.fromLTRB(16, 0, 16, 16),
                  children: [
                    FxSpacing.height(16),
                    Card(
                      elevation: 3,
                      margin: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              _dataAktivitas['nama_lengkap'].toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            Text(_dataAktivitas['aktivitas'].toString()),
                          ],
                        ),
                      ),
                    ),
                    FxSpacing.height(20),
                    Card(
                      elevation: 3,
                      margin: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.white,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _listFoto.length,
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                        itemBuilder: (context, index) {
                          final fotoAktivitas = _listFoto[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () {
                                AppNavigator.instance.push(MaterialPageRoute(
                                  builder: (context) => ShowImagePage(
                                    judul: "Foto Aktivitas",
                                    url: fotoAktivitas,
                                    isFile: false,
                                  ),
                                ));
                              },
                              child: Image.network(
                                fotoAktivitas,
                                fit: BoxFit.fitWidth,
                                width: double.infinity,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 100,
                                    child: Center(
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 0).toInt(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  AppImages.logoGold,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    FxSpacing.height(20),
                  ],
                );
              } else if (_apiResponse.getApiStatus == ApiStatus.loading) {
                return loadingWidget();
              } else {
                return emptyWidget(_apiResponse.getMessage);
              }
            },
          )
        ],
      ),
    );
  }

  Color colorStatusVerif(String statusVerif) {
    switch (statusVerif) {
      case "1":
        return Colors.grey;
      case "2":
        return Colors.green;
      case "3":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
