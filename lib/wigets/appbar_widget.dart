import 'package:absentip/utils/app_images.dart';
import 'package:absentip/wigets/appbar_leading.dart';
import 'package:animate_do/animate_do.dart';

import 'package:flutter/material.dart';

import '../../utils/app_color.dart';

AppBar appBarWidget(String title, {Widget? leading = const AppbarLeading(), List<Widget>? action}) {
  return AppBar(
    elevation: 0,
    leading: leading,
    actions: action,
    centerTitle: true,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.asset(AppImages.bg2).image,
          fit: BoxFit.cover,
        ),
      ),
    ),
    title: FadeInUp(
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    backgroundColor: AppColor.kuning,
  );
}
