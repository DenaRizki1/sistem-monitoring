import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/api_response.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/modules/tryout_psikologi/page_tryout_psikologi.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageTryoutPsikologiKategori extends StatefulWidget {
  const PageTryoutPsikologiKategori({Key? key}) : super(key: key);

  @override
  State<PageTryoutPsikologiKategori> createState() => _PageTryoutPsikologiKategoriState();
}

class _PageTryoutPsikologiKategoriState extends State<PageTryoutPsikologiKategori> {
  final _apiResponse = ApiResponse();
  final _refreshC = RefreshController();
  final _listKegiatan = [];

  @override
  void initState() {
    getKategori();
    super.initState();
  }

  @override
  void dispose() {
    _refreshC.dispose();
    super.dispose();
  }

  Future<void> getKategori() async {
    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.tryoutKategoriPsikologi,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH) ?? "",
        'hash_user': pref.getString(HASH_USER) ?? "",
      },
    );

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
      appBar: appBarWidget("Kategori Psikologi"),
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
            onRefresh: getKategori,
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
                                builder: (context) => PageTryoutPsikologi(),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.network(
                                  kegiatan['icon'].toString(),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Center(
                                        child: loadingWidget(),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    AppImages.logoGold,
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  kegiatan['subtitle'].toString(),
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
}
