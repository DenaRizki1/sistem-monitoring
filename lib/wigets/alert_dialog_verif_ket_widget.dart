import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/label_form.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AlertDialogVerifKetWidget extends StatefulWidget {
  const AlertDialogVerifKetWidget({
    Key? key,
    this.title = 'Detail Penolakan',
    this.textNo = "Batal",
    this.textYes = "Simpan",
  }) : super(key: key);

  final String title;
  final String textNo;
  final String textYes;

  @override
  State<AlertDialogVerifKetWidget> createState() => _AlertDialogVerifKetWidgetState();
}

class _AlertDialogVerifKetWidgetState extends State<AlertDialogVerifKetWidget> {
  final _ketEC = TextEditingController();

  @override
  void dispose() {
    _ketEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                      widget.title,
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
            const LabelForm(label: "Keterangan Penolakan", fontSize: 14),
            const SizedBox(height: 5),
            TextFormField(
              controller: _ketEC,
              decoration: textFieldDecoration(
                textHint: "Masukan Keterangan Penolakan",
              ),
              textCapitalization: TextCapitalization.words,
              minLines: 2,
              maxLines: 5,
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      AppNavigator.instance.pop({
                        'status': false,
                        'keterangan': _ketEC.text.toString(),
                      });
                    },
                    child: Text(
                      widget.textNo,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      AppNavigator.instance.pop({
                        'status': true,
                        'keterangan': _ketEC.text.toString(),
                      });
                    },
                    child: Text(
                      widget.textYes,
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
