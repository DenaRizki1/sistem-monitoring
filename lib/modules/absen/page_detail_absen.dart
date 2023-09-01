import 'dart:developer';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/api_response.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/modules/absen/item_absen_harian_widget.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageDetailAbsen extends StatefulWidget {
  final String tglAbsen;
  const PageDetailAbsen({Key? key, required this.tglAbsen}) : super(key: key);

  @override
  State<PageDetailAbsen> createState() => PageDetailAbsenState();
}

class PageDetailAbsenState extends State<PageDetailAbsen> {
  final _apiResponse = ApiResponse();
  String _tglAbsen = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tglAbsen = widget.tglAbsen;
      getDetailAbsen();
    });

    super.initState();
  }

  Future<void> getDetailAbsen() async {
    setState(() {
      _apiResponse.setApiSatatus = ApiStatus.loading;
    });

    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.absenHarianDetail,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH) ?? "",
        'hash_user': pref.getString(HASH_USER) ?? "",
        'tgl_absen': _tglAbsen,
      },
    );

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
      appBar: appBarWidget(parseDateInd(_tglAbsen.toString(), "dd MMMM yyyy")),
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
                Map absen = _apiResponse.getData;

                return SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        ItemAbsenHarianWidget(absenDetail: absen),
                        Divider(color: AppColor.biru),
                      ],
                    ),
                  ),
                );
              } else if (_apiResponse.getApiStatus == ApiStatus.loading) {
                return loadingWidget();
              } else {
                return emptyWidget(_apiResponse.getMessage);
              }
            },
          ),
        ],
      ),
    );
  }
}
