import 'dart:convert';
import 'dart:developer';

import 'package:absentip/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import 'my_appbar.dart';
import 'utils/constants.dart';
import 'utils/helpers.dart';
import 'utils/sessions.dart';
import 'utils/strings.dart';

class PageSyaratKetentuan extends StatefulWidget {
  const PageSyaratKetentuan({Key? key}) : super(key: key);

  @override
  State<PageSyaratKetentuan> createState() => _PageSyaratKetentuanState();
}

class _PageSyaratKetentuanState extends State<PageSyaratKetentuan> {

  var data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSyaratKetentuan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar.getAppBar("Syarat & Ketentuan"),
      body: Stack(
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
          SingleChildScrollView(
            child: data!=null ? Container(
              padding: const EdgeInsets.all(16),
              child: data.toString().contains('<p>')
                  ? Html(data: data)
                  : Text(data),
            ) : SizedBox(
              height: MediaQuery.of(context).size.height,
              child: const Center(child: CupertinoActivityIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  getSyaratKetentuan() async {

    if(await Helpers.isNetworkAvailable()) {

      try {

        String tokenAuth = "", hashUser = "";
        tokenAuth = (await getPrefrence(TOKEN_AUTH))!;
        hashUser = (await getPrefrence(HASH_USER))!;

        var param = {
          'token_auth': tokenAuth,
          'hash_user': hashUser,
        };

        http.Response response = await http.post(
          Uri.parse(urlSyaratKetentuan),
          headers: headers,
          body: param,
        );

        log(response.body);

        Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        log(jsonResponse.toString());
        if (jsonResponse.containsKey("error")) {

        } else {

          bool success = jsonResponse['success'];
          String message = jsonResponse["message"];
          if (success) {

            setState(() {
              data = jsonResponse['data'];
            });

          } else {
            Helpers.dialogErrorNetwork(context, message);
          }
        }
      } catch (e, stacktrace) {
        log(e.toString());
        log(stacktrace.toString());
        String customMessage = "${Strings.TERJADI_KESALAHAN}.\n${e.runtimeType.toString()}";
        Helpers.dialogErrorNetwork(context, customMessage);
      }

    } else {
      Helpers.dialogErrorNetwork(context, 'Tidak ada koneksi internet');
    }
  }
}
