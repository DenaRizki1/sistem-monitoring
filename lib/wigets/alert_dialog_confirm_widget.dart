import 'package:sistem_monitoring/utils/routes/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AlertDialogConfirmWidget extends StatelessWidget {
  const AlertDialogConfirmWidget({
    Key? key,
    required this.message,
    this.title = 'Konfirmasi',
    this.textNo = "Tidak",
    this.textYes = "Ya",
  }) : super(key: key);

  final String title;
  final String message;
  final String textNo;
  final String textYes;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
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
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Icon(MdiIcons.alertDecagramOutline)
              ],
            ),
            const Divider(),
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      AppNavigator.instance.pop(false);
                    },
                    child: Text(
                      textNo,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      AppNavigator.instance.pop(true);
                    },
                    child: Text(
                      textYes,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
