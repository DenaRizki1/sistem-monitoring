import 'dart:developer';

import 'package:absentip/my_colors.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:flutx/flutx.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AlertDialogOkWidget extends StatefulWidget {
  const AlertDialogOkWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  final String message;

  @override
  State<AlertDialogOkWidget> createState() => _AlertDialogOkWidgetState();
}

class _AlertDialogOkWidgetState extends State<AlertDialogOkWidget> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    FocusManager.instance.primaryFocus?.unfocus();

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorInfo,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: FxText.titleLarge(
                      "Informasi",
                      fontWeight: 800,
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(MdiIcons.informationOutline)
              ],
            ),
            const Divider(),
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: FxText.titleSmall(
                widget.message,
                fontWeight: 600,
                letterSpacing: 0.2,
                color: Colors.black,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8),
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FxButton(
                      backgroundColor: colorPrimary,
                      elevation: 2,
                      borderRadiusAll: 4,
                      onPressed: () {
                        log("message");
                        Navigator.of(context).pop(true);
                      },
                      child: FxText.bodyMedium("Ok", fontWeight: 600, color: Colors.black)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
