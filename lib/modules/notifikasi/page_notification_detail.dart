import 'package:absentip/utils/helpers.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:flutter/material.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Detail Notifikasi"),
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
                    dataNotif['judul'].toString(),
                    style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const Divider(color: Colors.black26),
                  Text(
                    dataNotif["pesan"].toString(),
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
    );
  }
}
