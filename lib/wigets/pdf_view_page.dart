import 'dart:developer';

import 'package:absentip/utils/helpers.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'package:flutter/material.dart';

class PdfViewPage extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewPage({Key? key, required this.url, this.title = "Lihat PDF"}) : super(key: key);

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(widget.title),
      body: Center(
        child: FutureBuilder<PDFDocument>(
          future: loadDocument(widget.url),
          builder: (context, AsyncSnapshot<PDFDocument> snapshot) {
            if (snapshot.hasData) {
              return PDFViewer(document: snapshot.data!);
            } else {
              return loadingWidget();
            }
          },
        ),
      ),
    );
  }

  Future<PDFDocument> loadDocument(String url) async {
    log(url);
    PDFDocument document = await PDFDocument.fromURL(url);
    return document;
  }
}
