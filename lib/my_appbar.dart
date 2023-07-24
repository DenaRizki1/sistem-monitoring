import 'package:absentip/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyAppBar {
  static getAppBar(String _title) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: colorPrimary,
      leading: const BackButton(
        color: Colors.black,
      ),
      centerTitle: true,
      title: SizedBox(
        width: double.infinity,
        child: Text(
          _title,
          textAlign: TextAlign.start,
          style: const TextStyle(color: Colors.black, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  static getCariMenuAppBar(Widget _title, Icon _icon) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      leading: const BackButton(
        color: Colors.black,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _title,
        ],
      ),
      actions: [
        IconButton(
          icon: _icon,
          color: Colors.grey,
          tooltip: 'Cari Menu',
          onPressed: () {},
        ),
      ],
    );
  }
}
