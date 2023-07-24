import 'dart:developer';

import 'package:absentip/my_colors.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/text_montserrat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PageNotificationDetail extends StatefulWidget {
  final Map data;
  const PageNotificationDetail({Key? key, required this.data}) : super(key: key);

  @override
  State<PageNotificationDetail> createState() => _PageNotificationDetailState();
}

class _PageNotificationDetailState extends State<PageNotificationDetail> {
  Map dataNotif = {};

  @override
  void initState() {
    dataNotif = widget.data;

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          flexibleSpace: const Image(
            image: AssetImage(AppImages.bg2),
            fit: BoxFit.cover,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: colorPrimary,
          leading: GestureDetector(
            // onTap: () => AppNavigator.instance.pop(),
            onTap: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(3, 3),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Icon(
                    MdiIcons.chevronLeft,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          title: const SizedBox(
            // width: double.infinity,
            child: Text(
              "Detail Notifikasi",
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.black,
                overflow: TextOverflow.ellipsis,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        body: ListView(
          children: [
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Text(
                      dataNotif['judul'],
                      style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(color: Colors.black26),
                    Text(
                      dataNotif["pesan"],
                      style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      parseDateInd(dataNotif['created_at'].toString(), "dd MMM yyyy HH:mm"),
                      style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
