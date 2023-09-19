import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/label_form.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class DialogKonfirmasiAbsen extends StatefulWidget {
  final List listLokasi;

  const DialogKonfirmasiAbsen({Key? key, required this.listLokasi}) : super(key: key);

  @override
  State<DialogKonfirmasiAbsen> createState() => _DialogKonfirmasiAbsenState();
}

class _DialogKonfirmasiAbsenState extends State<DialogKonfirmasiAbsen> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LabelForm(label: "Lokasi Absen", isRequired: true),
            const SizedBox(height: 4),
            DropdownSearch<dynamic>(
              items: widget.listLokasi,
              itemAsString: (item) => item['nama_branch'].toString(),
              popupProps: PopupProps.menu(
                showSearchBox: false,
                menuProps: const MenuProps(),
                searchFieldProps: TextFieldProps(
                  decoration: textFieldDecoration(
                    textHint: "Cari Lokasi Absen",
                  ),
                ),
                loadingBuilder: (context, searchEntry) => loadingWidget(),
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: textFieldDecoration(
                  textHint: "Pilih Lokasi Absen",
                ),
              ),
              onChanged: (item) {
                AppNavigator.instance.pop(item['id_branch'].toString());
              },
            ),
          ],
        ),
      ),
    );
  }
}
