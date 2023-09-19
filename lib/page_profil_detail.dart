import 'dart:developer';
import 'dart:io';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/utils/my_colors.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'utils/sessions.dart';

class PageProfilDetail extends StatefulWidget {
  const PageProfilDetail({Key? key}) : super(key: key);

  @override
  State<PageProfilDetail> createState() => _PageProfilDetailState();
}

class _PageProfilDetailState extends State<PageProfilDetail> {
  String nama = "", email = "", notlp = "", alamat = "", foto = "";

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    nama = await getPrefrence(NAMA) ?? "";
    email = await getPrefrence(EMAIL) ?? "";
    notlp = await getPrefrence(NOTLP) ?? "";
    alamat = await getPrefrence(ALAMAT) ?? "";
    foto = await getPrefrence(FOTO) ?? "";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Profil Detail"),
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
            children: [
              Container(
                width: 140,
                height: 140,
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    CircleAvatar(
                      radius: 100,
                      foregroundImage: Image.network(
                        foto,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return SizedBox(
                            child: Center(
                              child: loadingWidget(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          AppImages.logoGold,
                          width: 140,
                          height: 140,
                        ),
                      ).image,
                    ),
                    Positioned.fill(
                      top: 100,
                      left: 100,
                      bottom: 6,
                      right: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.biru,
                        ),
                        child: InkWell(
                          onTap: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                contentPadding: const EdgeInsets.all(8),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        AppNavigator.instance.pop(true);
                                      },
                                      child: const ListTile(
                                        leading: Icon(Icons.camera),
                                        title: Text("Kamera"),
                                      ),
                                    ),
                                    const Divider(),
                                    InkWell(
                                      onTap: () {
                                        AppNavigator.instance.pop(false);
                                      },
                                      child: const ListTile(
                                        leading: Icon(Icons.folder),
                                        title: Text("Galeri"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );

                            XFile? imageFile;

                            if (result == null) {
                              return;
                            }

                            if (result) {
                              //? open camera
                              if (Platform.isIOS) {
                                try {
                                  imageFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
                                } catch (e) {
                                  PermissionStatus permission = await Permission.photos.status;
                                  if (permission != PermissionStatus.granted) {
                                    if (mounted) {
                                      alertOpenSetting(context);
                                    }
                                  }
                                }
                              } else {
                                try {
                                  imageFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
                                } catch (e) {
                                  PermissionStatus permission = await Permission.camera.status;
                                  if (permission == PermissionStatus.denied) {
                                    //? Requesting the permission
                                    PermissionStatus statusDenied = await Permission.camera.request();
                                    if (statusDenied.isPermanentlyDenied) {
                                      //? permission isPermanentlyDenied
                                      if (mounted) {
                                        alertOpenSetting(context);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              //? open galery
                              if (Platform.isIOS) {
                                try {
                                  imageFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
                                } catch (e) {
                                  PermissionStatus permission = await Permission.photos.status;
                                  if (permission != PermissionStatus.granted) {
                                    if (mounted) {
                                      alertOpenSetting(context);
                                    }
                                  }
                                }
                              } else {
                                try {
                                  imageFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
                                } catch (e) {
                                  PermissionStatus permission = await Permission.storage.status;
                                  if (permission == PermissionStatus.denied) {
                                    //? Requesting the permission
                                    PermissionStatus statusDenied = await Permission.storage.request();
                                    if (statusDenied.isPermanentlyDenied) {
                                      //? permission isPermanentlyDenied
                                      if (mounted) {
                                        alertOpenSetting(context);
                                      }
                                    }
                                  }
                                }
                              }
                            }

                            print(imageFile);

                            //? upload image
                            await uploadAvatarProfile(imageFile);
                          },
                          child: Icon(
                            MdiIcons.pencil,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              cardCustom(nama, "Nama"),
              const SizedBox(height: 10),
              cardCustom(email, "Email"),
              const SizedBox(height: 10),
              cardCustom(notlp, "No.telp"),
              const SizedBox(height: 10),
              cardCustom(alamat, "Alamat"),
            ],
          ),
        ],
      ),
    );
  }

  Widget cardCustom(String text, String content, {void Function()? onTap}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                content,
                style: GoogleFonts.montserrat(color: Colors.black54, fontSize: 14),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                text,
                style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 12),
            onTap == null
                ? const SizedBox.shrink()
                : InkWell(
                    onTap: onTap,
                    child: Icon(
                      MdiIcons.pencil,
                      color: colorPrimary,
                      size: 20,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> uploadAvatarProfile(XFile? imageFile) async {
    log("start upload");
    if (imageFile != null) {
      log("You selected  image : ${imageFile.path}");
      //! upload file to server
      await showLoading();
      File compressedFile = await FlutterNativeImage.compressImage(imageFile.path);

      final response = await ApiConnect.instance.uploadFile(
        EndPoint.uploadAvatar,
        "avatar",
        compressedFile.path,
        {
          'hash_user': await getPrefrence(HASH_USER) ?? "",
          'token_auth': await getPrefrence(TOKEN_AUTH) ?? "",
        },
      );

      dismissLoading();

      if (response != null) {
        if (response['success']) {
          final data = response['data'];

          await setPrefrence(FOTO, data['avatar']);
          foto = await getPrefrence(FOTO) ?? "";

          if (mounted) {
            setState(() {});
          }
        }
        showToast(response['message'].toString());
      }
    } else {
      log("You have not taken image");
    }
  }
}
