import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/page_home.dart';
import 'package:absentip/page_login.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/utils/sessions.dart';
import 'package:flutter/material.dart';

class PageSplashscreen extends StatefulWidget {
  const PageSplashscreen({Key? key}) : super(key: key);

  @override
  State<PageSplashscreen> createState() => _PageSplashscreenState();
}

class _PageSplashscreenState extends State<PageSplashscreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    Future.delayed(const Duration(seconds: 4), () async {
      final response = await ApiConnect.instance.request(
        requestMethod: RequestMethod.post,
        url: EndPoint.checkLogin,
        params: {
          'hash_user': await getPrefrence(HASH_USER) ?? "",
          'token_auth': await getPrefrence(TOKEN_AUTH) ?? "",
        },
      );

      final isLogin = await getPrefrenceBool(IS_LOGIN);
      if (response != null) {
        if (response['success'] && isLogin) {
          AppNavigator.instance.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const PageHome(),
            ),
            (p0) => false,
          );
        } else {
          showToast(response['message'].toString());
          AppNavigator.instance.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const PageLogin(),
            ),
            (p0) => false,
          );
        }
      } else {
        showToast("Terjadi kesalahan");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          'images/splash.gif',
          gaplessPlayback: true,
          color: AppColor.biru,
          colorBlendMode: BlendMode.color,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
