import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'utils/constants.dart';
import 'utils/helpers.dart';
import 'utils/sessions.dart';

class PagePrivasi extends StatefulWidget {
  const PagePrivasi({Key? key}) : super(key: key);

  @override
  State<PagePrivasi> createState() => _PagePrivasiState();
}

class _PagePrivasiState extends State<PagePrivasi> {
  String _data = "";

  @override
  void initState() {
    super.initState();
    getKebijakanPrivasi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Kebijakan Privasi"),
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
          _data.isNotEmpty
              ? SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: _data.toString().contains('<p>') ? Html(data: _data) : Text(_data),
                  ),
                )
              : loadingWidget()
        ],
      ),
    );
  }

  getKebijakanPrivasi() async {
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.policyPrivacy,
      params: {
        'hash_user': await getPrefrence(HASH_USER) ?? "",
        'token_auth': await getPrefrence(TOKEN_AUTH) ?? "",
      },
    );

    if (response != null) {
      if (response['success']) {
        if (mounted) {
          setState(() {
            _data = response['data'];
          });
        }
      } else {
        showToast(response['message'].toString());
      }
    } else {
      showToast("Terjadi kesalahan");
    }
  }
}
