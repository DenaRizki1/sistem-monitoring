import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/page_login.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/routes/app_navigator.dart';
import 'package:absentip/wigets/alert_dialog_confirm_widget.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:absentip/wigets/label_form.dart';
import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'utils/helpers.dart';
import 'utils/sessions.dart';

class PageGantiPassword extends StatefulWidget {
  const PageGantiPassword({Key? key}) : super(key: key);

  @override
  State<PageGantiPassword> createState() => _PageGantiPasswordState();
}

class _PageGantiPasswordState extends State<PageGantiPassword> {
  final controllerPasswordLama = TextEditingController();
  final controllerPasswordBaru = TextEditingController();
  final controllerPasswordKonfirmasi = TextEditingController();
  bool _passwordLamaVisible = false;
  bool _passwordBaruVisible = false;
  bool _passwordKonfirmasiVisible = false;

  @override
  void dispose() {
    controllerPasswordLama.dispose();
    controllerPasswordBaru.dispose();
    controllerPasswordKonfirmasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Ganti Password"),
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
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Card(
                  margin: const EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const LabelForm(label: "Password Lama", fontSize: 14),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: controllerPasswordLama,
                          decoration: textFieldDecoration(
                            textHint: "Masukan password lama",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordLamaVisible ? Icons.visibility : Icons.visibility_off,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordLamaVisible = !_passwordLamaVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_passwordLamaVisible,
                        ),
                        const SizedBox(height: 16),
                        const LabelForm(label: "Password Baru", fontSize: 14),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: controllerPasswordBaru,
                          decoration: textFieldDecoration(
                            textHint: "Masukan password baru",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordBaruVisible ? Icons.visibility : Icons.visibility_off,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordBaruVisible = !_passwordBaruVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_passwordBaruVisible,
                        ),
                        const SizedBox(height: 16),
                        const LabelForm(
                          label: "Konfirmasi Password",
                          fontSize: 14,
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: controllerPasswordKonfirmasi,
                          decoration: textFieldDecoration(
                            textHint: "Masukan konfirmasi password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordKonfirmasiVisible ? Icons.visibility : Icons.visibility_off,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordKonfirmasiVisible = !_passwordKonfirmasiVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_passwordKonfirmasiVisible,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (controllerPasswordLama.text.toString().isEmpty) {
                                showToast("Password lama tidak boleh kosong");
                              } else if (controllerPasswordBaru.text.toString().isEmpty) {
                                showToast("Password baru tidak boleh kosong");
                              } else if (controllerPasswordKonfirmasi.text.toString().isEmpty) {
                                showToast("Password konfirmasi tidak boleh kosong");
                              } else if (controllerPasswordBaru.text.toString() != controllerPasswordKonfirmasi.text.toString()) {
                                showToast("Password konfirmasi tidak sama");
                              } else {
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => const AlertDialogConfirmWidget(
                                    message: "Anda akan diminta untuk login kembali saat berhasil merubah password.\nApakah anda yakin akan mengubah password?",
                                  ),
                                );

                                if (result ?? false) {
                                  simpanPasswordBaru();
                                }
                              }
                            },
                            child: const Text("SIMPAN"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> simpanPasswordBaru() async {
    showLoading();

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.gantiPassword,
      params: {
        'hash_user': await getPrefrence(HASH_USER) ?? "",
        'token_auth': await getPrefrence(TOKEN_AUTH) ?? "",
        'password_lama': controllerPasswordLama.text.toString().trim(),
        'password_baru': controllerPasswordKonfirmasi.text.toString().trim(),
      },
    );

    dismissLoading();

    if (response != null) {
      showToast(response['message'].toString());
      if (response['success']) {
        AppNavigator.instance.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const PageLogin(),
          ),
          (p0) => false,
        );
      }
    } else {
      showToast("Terjadi kesalahan");
    }
  }
}
