import 'dart:io';

import 'package:sistem_monitoring/utils/routes/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ShowImagePage extends StatefulWidget {
  final String judul;
  final String url;
  final bool isFile;

  const ShowImagePage({Key? key, required this.judul, required this.url, this.isFile = false}) : super(key: key);

  @override
  State<ShowImagePage> createState() => _ShowImagePageState();
}

class _ShowImagePageState extends State<ShowImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: widget.isFile
                ? PhotoView(
                    imageProvider: Image.file(File(widget.url)).image,
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 1.1,
                    heroAttributes: PhotoViewHeroAttributes(tag: widget.judul),
                  )
                : widget.url.contains('http')
                    ? PhotoView(
                        imageProvider: Image.network(widget.url).image,
                        minScale: PhotoViewComputedScale.contained * 0.8,
                        maxScale: PhotoViewComputedScale.covered * 1.1,
                        heroAttributes: PhotoViewHeroAttributes(tag: widget.judul),
                        loadingBuilder: (context, event) => Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              value: event == null ? 0 : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 0).toInt(),
                            ),
                          ),
                        ),
                      )
                    : PhotoView(
                        imageProvider: Image.asset(widget.url).image,
                        minScale: PhotoViewComputedScale.contained * 0.8,
                        maxScale: PhotoViewComputedScale.covered * 1.1,
                        heroAttributes: PhotoViewHeroAttributes(tag: widget.judul),
                      ),
          ),
          Positioned(
            top: 40,
            right: 0,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
              iconSize: 30,
              onPressed: () => AppNavigator.instance.pop(),
            ),
          ),
        ],
      ),
    );
  }
}
