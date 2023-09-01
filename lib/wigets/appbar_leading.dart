import 'package:absentip/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AppbarLeading extends StatelessWidget {
  const AppbarLeading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        // decoration: BoxDecoration(
        //   color: AppColor.hitam.withOpacity(0.5),
        //   borderRadius: BorderRadius.circular(6),
        // ),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColor.biru,
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
    );
  }
}
