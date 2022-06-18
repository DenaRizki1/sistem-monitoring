import 'package:absentip/session_helper.dart';
import 'package:absentip/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'my_appbar.dart';
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
    // TODO: implement initState
    super.initState();
    init();
  }

  init() async {
    String nm = "", em = "", nt = "", alm = "", ft = "";
    nm = (await getPrefrence(NAMA))!;
    em = (await getPrefrence(EMAIL))!;
    nt = (await getPrefrence(NOTLP))!;
    alm = (await getPrefrence(ALAMAT))!;
    ft = (await getPrefrence(FOTO))!;
    setState(() {
      nama = nm;
      email = em;
      notlp = nt;
      alamat = alm;
      foto = ft;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar.getAppBar("Info Pribadi"),
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              'images/bg_doodle.jpg',
              fit: BoxFit.cover,
              // color: const Color.fromRGBO(255, 255, 255, 0.1),
              // colorBlendMode: BlendMode.modulate,
            ),
          ),
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    child: Center(
                      child: foto!="" ? InkWell(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          height: MediaQuery.of(context).size.width / 3,
                          child: CircleAvatar(
                            child: Padding(
                              padding: const EdgeInsets.all(1),
                              child: ClipOval(child: Image.network(foto)),
                            ),
                            backgroundColor: Colors.black38,
                          ),
                        ),
                        onTap: () {

                        },
                      ) : const CupertinoActivityIndicator(),
                    ),
                  ),
                  widgetLabel("Nama"),
                  const SizedBox(height: 5,),
                  widgetValue(nama),
                  const SizedBox(height: 10,),
                  widgetLabel("Email"),
                  const SizedBox(height: 5,),
                  widgetValue(email),
                  const SizedBox(height: 10,),
                  widgetLabel("No. Telepon"),
                  const SizedBox(height: 5,),
                  widgetValue(notlp),
                  const SizedBox(height: 10,),
                  widgetLabel("Alamat"),
                  const SizedBox(height: 5,),
                  widgetValue(alamat),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget widgetLabel(String label) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.bold),);
  }
  Widget widgetValue(String value) {

    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: const Color(0xffEAEAEA),
            borderRadius: BorderRadius.circular(10)),
        child: Text(value)
    );

  }
}
