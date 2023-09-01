import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:absentip/wigets/label_form.dart';
import 'package:absentip/wigets/pdf_view_page.dart';
import 'package:absentip/wigets/show_image_page.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/helpers.dart';

class PageDetailLembur extends StatefulWidget {
  final Map dataLembur;

  const PageDetailLembur({Key? key, required this.dataLembur}) : super(key: key);

  @override
  State<PageDetailLembur> createState() => _PageDetailLemburState();
}

class _PageDetailLemburState extends State<PageDetailLembur> {
  Map _dataLembur = {};

  @override
  void initState() {
    _dataLembur = widget.dataLembur;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(parseDateInd(_dataLembur['tgl_lembur'], "dd MMMM yyyy")),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'images/bg_doodle.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.biru2,
                  AppColor.biru2.withOpacity(0.6),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          ListView(
            padding: FxSpacing.fromLTRB(16, 0, 16, 16),
            children: [
              FxSpacing.height(16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: Colors.white,
                    child: Stack(
                      children: [
                        Image.asset(
                          AppImages.bgCard1,
                          width: 40,
                          // height: 70,
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          width: double.infinity,
                          // height: 70,
                          child: Column(
                            children: [
                              Center(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _dataLembur['nama_lengkap'].toString(),
                                            style: GoogleFonts.montserrat(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                          FxSpacing.height(4),
                                          Text(
                                            parseDateInd(_dataLembur['jam_awal'].toString(), "HH:mm") + " - " + parseDateInd(_dataLembur['jam_akhir'].toString(), "HH:mm"),
                                            style: GoogleFonts.montserrat(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                    FxContainer.bordered(
                                      borderRadiusAll: 12,
                                      height: 20,
                                      padding: FxSpacing.xy(8, 2),
                                      border: Border.all(color: AppColor.hitam),
                                      color: AppColor.biru2,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [FxText.bodySmall(_dataLembur['lama_lembur'].toString() + " Jam", color: Colors.white)],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: colorStatusVerif(_dataLembur['status_lembur'].toString()).withAlpha(50),
                                  border: Border.all(color: colorStatusVerif(_dataLembur['status_lembur'].toString())),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _dataLembur['ket_status_lembur'].toString(),
                                      style: GoogleFonts.montserrat(
                                        color: colorStatusVerif(_dataLembur['status_lembur'].toString()),
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  FxSpacing.height(16),
                  const LabelForm(label: "Foto Lembur", fontSize: 14),
                  FxSpacing.height(4),
                  Builder(builder: (context) {
                    if (_dataLembur['foto_lembur'].toString() == "null") {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey,
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 0.5,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Icon(
                                MdiIcons.imageBroken,
                                color: Colors.red.shade200,
                                size: 60,
                              ),
                            ),
                            FxText(
                              "Tidak ada file",
                              textAlign: TextAlign.center,
                              fontSize: 10,
                            ),
                          ],
                        ),
                      );
                    } else if (_dataLembur['foto_lembur'].toString().contains("pdf")) {
                      return InkWell(
                        //? PDF FILE;
                        onTap: () {
                          AppNavigator.instance.push(
                            MaterialPageRoute(
                              builder: (context) => PdfViewPage(
                                url: _dataLembur['foto_lembur'].toString(),
                                title: "Berkas Izin",
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey,
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width * 0.5,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Icon(
                                  MdiIcons.filePdfBox,
                                  color: Colors.red.shade200,
                                  size: 60,
                                ),
                              ),
                              FxText(
                                _dataLembur['foto_lembur'].toString(),
                                textAlign: TextAlign.center,
                                fontSize: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return InkWell(
                        //? IMAGE FILE
                        onTap: () => AppNavigator.instance.push(
                          MaterialPageRoute(
                            builder: (context) => ShowImagePage(
                              judul: "Foto ${_dataLembur['foto_lembur'].toString()}",
                              url: _dataLembur['foto_lembur'].toString(),
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _dataLembur['foto_lembur'].toString(),
                            fit: BoxFit.fill,
                            width: MediaQuery.of(context).size.width,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width * 0.5,
                                child: Center(
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 0).toInt(),
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              AppImages.noImage,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width * 0.5,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }
                  }),
                ],
              ),
              FxSpacing.height(20),
            ],
          ),
        ],
      ),
    );
  }

  Color colorStatusVerif(String statusVerif) {
    switch (statusVerif) {
      case "1":
        return Colors.grey;
      case "2":
        return Colors.green;
      case "3":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
