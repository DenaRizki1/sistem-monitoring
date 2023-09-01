import 'package:absentip/utils/app_images.dart';
import 'package:absentip/wigets/appbar_leading.dart';
import 'package:animate_do/animate_do.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    backgroundColor: AppColor.biru,
  );
}
