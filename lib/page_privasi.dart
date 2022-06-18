import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:http/http.dart' as http;

import 'my_appbar.dart';
import 'utils/api.dart';
import 'utils/constants.dart';
import 'utils/helpers.dart';
import 'utils/sessions.dart';
import 'utils/strings.dart';

class PagePrivasi extends StatefulWidget {
  const PagePrivasi({Key? key}) : super(key: key);

  @override
  State<PagePrivasi> createState() => _PagePrivasiState();
}

class _PagePrivasiState extends State<PagePrivasi> {

  var data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getKebijakanPrivasi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar.getAppBar("Kebijakan Privasi"),
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

  getKebijakanPrivasi() async {

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
          Uri.parse(urlKebijakanPrivasi),
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
