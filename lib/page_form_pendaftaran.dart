import 'dart:developer';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/wigets/alert_dialog_ok_widget.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:absentip/wigets/label_form.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class PageFormPendaftaran extends StatefulWidget {
  const PageFormPendaftaran({Key? key}) : super(key: key);

  @override
  State<PageFormPendaftaran> createState() => _PageFormPendaftaranState();
}

class _PageFormPendaftaranState extends State<PageFormPendaftaran> {
  TextEditingController _ECnik = TextEditingController();
  TextEditingController _ECnamaLengkap = TextEditingController();
  TextEditingController _ECemail = TextEditingController();
  TextEditingController _ECpassword = TextEditingController();
  TextEditingController _ECKonfirmasiPassword = TextEditingController();
  TextEditingController _ECnoHp = TextEditingController();
  TextEditingController _ECalamat = TextEditingController();
  TextEditingController _ECrekening = TextEditingController();
  TextEditingController _ECtempatLahir = TextEditingController();
  TextEditingController _ECtanggalLahir = TextEditingController();
  TextEditingController _ECnamaPemilikR = TextEditingController();
  String selectedBank = "";
  Map? selectedProvinsi, selectedKota, selectedKecamatan, selectedKelurahan, selectedPendidikan;
  String _selectedJK = "Laki-laki";

  final _formKey = GlobalKey<FormState>();

  DateTime? selectedDate;

  bool _passwordVisible = true;
  bool _konfirmasipasswordVisible = true;

  @override
  void initState() {
    // TODO: implement initState
    // getProvinsi();
    super.initState();
  }

  Future<List> getProvinsi() async {
    List data = [];

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.getProvinsi,
      params: {},
    );

    if (response != null) {
      if (response['success']) {
        data = response['data'];
      }
    }

    return data;
  }

  Future<List> getKota() async {
    List data = [];

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.getKota,
      params: {
        'id_provinsi': selectedProvinsi?['id_provinsi']?.toString() ?? "",
      },
    );

    if (response != null) {
      if (response['success']) {
        data = response['data'];
      }
    }

    return data;
  }

  Future<List> getKecamatan() async {
    List data = [];

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.getKecamatan,
      params: {
        'id_kota': selectedKota?['id_kota'].toString() ?? "",
      },
    );

    if (response != null) {
      if (response['success']) {
        data = response['data'];
      }
    }

    return data;
  }

  Future<List> getKelurahan() async {
    List data = [];

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.getKelurahan,
      params: {
        'id_kecamatan': selectedKecamatan?['id_kecamatan'].toString() ?? "",
      },
    );

    if (response != null) {
      if (response['success']) {
        data = response['data'];
      }
    }

    return data;
  }

  Future<List> getPendidikan() async {
    List data = [];

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.getPendidikan,
      params: {},
    );

    if (response != null) {
      if (response['success']) {
        data = response['data'];
      }
    }

    return data;
  }

  Future<List> getBank() async {
    List data = [];

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.get,
      url: EndPoint.getBank,
      params: {},
    );

    log(response.toString());

    if (response != null) {
      if (response['success']) {
        data = response['data'];
      }
    }
    return data;
  }

  Future simpanPendaftaran() async {
    await showLoading();

    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.simpanPendaftaran,
      params: {
        'nik': _ECnik.text,
        'nama_lengkap': _ECnamaLengkap.text,
        'email': _ECemail.text,
        'password': _ECpassword.text,
        'no_hp': _ECnoHp.text,
        'alamat': _ECalamat.text,
        'id_provinsi': selectedProvinsi?['id_provinsi'].toString() ?? "",
        'id_kota': selectedKota?['id_kota'].toString() ?? "",
        'id_kecamatan': selectedKecamatan?['id_kecamatan'].toString() ?? "",
        'id_kelurahan': selectedKelurahan?['id_kelurahan'].toString() ?? "",
        'jenis_kelamin': _selectedJK.toString(),
        'tempat_lahir': _ECtempatLahir.text,
        'tanggal_lahir': parseDateInd(selectedDate.toString(), "yyyy-MM-dd"),
        'id_pendidikan_pegawai': selectedPendidikan?['id_pendidikan_pegawai'].toString() ?? "",
        'bank': selectedBank.toString(),
        'no_rek': _ECrekening.text,
        'nama_pemilik_rekening': _ECnamaPemilikR.text,
      },
    );

    await dismissLoading();

    if (response != null) {
      if (response['success']) {
        final result = await showDialog(
          context: context,
          builder: (context) => AlertDialogOkWidget(message: response['message']),
        );

        if (result) {
          Navigator.of(context).pop();
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialogOkWidget(message: response['message']),
        );
      }
    }

    log(response.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Form Pendaftaran"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const LabelForm(label: "NIK", isRequired: true),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _ECnik,
                    decoration: textFieldDecoration(
                      textHint: "Masukkan NIK sesuai KTP",
                    ),
                    maxLength: 16,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "NIK tidak boleh kosong";
                      } else if (value.length != 16) {
                        return "NIK yang anda masukan kurang dari 16 digit";
                      }

                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  const LabelForm(label: "Nama Lengkap", isRequired: true),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _ECnamaLengkap,
                    decoration: textFieldDecoration(
                      textHint: "Masukkan Nama Lengkap",
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Nama Lengkap tidak boleh kosong";
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const LabelForm(label: "Email", isRequired: true),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _ECemail,
                    decoration: textFieldDecoration(
                      textHint: "Masukkan Email",
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Email tidak boleh kosong";
                      } else if (!RegExp(r'@').hasMatch(value)) {
                        return "Masukan email yang valid";
                      }

                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  const LabelForm(label: "Password", isRequired: true),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _ECpassword,
                    decoration: textFieldDecoration(
                      textHint: "Masukkan Kata Sandi",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          color: AppColor.biru,
                        ),
                        onPressed: () {
                          setState(() {
                            _konfirmasipasswordVisible = !_konfirmasipasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Password tidak boleh kosong";
                      } else if (_ECKonfirmasiPassword.text != "" && value != _ECKonfirmasiPassword.text) {
                        return "Password tidak sesuai";
                      }

                      return null;
                    },
                    obscureText: _konfirmasipasswordVisible,
                  ),
                  const SizedBox(height: 12),
                  const LabelForm(label: "Konfirmasi Password", isRequired: true),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _ECKonfirmasiPassword,
                    decoration: textFieldDecoration(
                      textHint: "Masukkan Konfirmasi Kata Sandi",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          color: AppColor.biru,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Konfirmasi Password tidak boleh kosong";
                      } else if (_ECpassword.text != "" && value != _ECpassword.text) {
                        return "Password tidak sesuai";
                      }

                      return null;
                    },
                    obscureText: _passwordVisible,
                  ),
                  const SizedBox(height: 12),
                  const LabelForm(label: "NO Hp", isRequired: true),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _ECnoHp,
                    decoration: textFieldDecoration(
                      textHint: "Masukkan No Hp",
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "No hp tidak boleh kosong";
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const LabelForm(label: "Alamat", isRequired: true),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _ECalamat,
                    decoration: textFieldDecoration(
                      textHint: "Masukkan Alamat",
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Alamat tidak boleh kosong";
                      }

                      return null;
                    },
                    maxLines: 5,
                    minLines: 2,
                  ),
                  const SizedBox(height: 12),
                  const LabelForm(label: "Provinsi", isRequired: true),
                  const SizedBox(height: 5),
                  DropdownSearch<dynamic>(
                    asyncItems: (text) => getProvinsi(),
                    itemAsString: (item) => item['nama_provinsi'].toString(),
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      menuProps: const MenuProps(),
                      searchFieldProps: TextFieldProps(
                        decoration: textFieldDecoration(
                          textHint: "Cari Provinsi",
                        ),
                      ),
                      loadingBuilder: (context, searchEntry) => loadingWidget(),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: textFieldDecoration(textHint: "Pilih provinsi"),
                    ),
                    selectedItem: selectedProvinsi,
                    onChanged: (item) {
                      setState(() {
                        selectedProvinsi = item;
                        selectedKota = null;
                        selectedKecamatan = null;
                        selectedKelurahan = null;
                        log(selectedProvinsi.toString());
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  const LabelForm(label: "Kota", isRequired: true),
                  const SizedBox(height: 5),
                  DropdownSearch<dynamic>(
                    asyncItems: (text) => getKota(),
                    itemAsString: (item) => item['nama_kota'].toString(),
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      menuProps: const MenuProps(),
                      searchFieldProps: TextFieldProps(
                        decoration: textFieldDecoration(
                          textHint: "Cari Kota",
                        ),
                      ),
                      loadingBuilder: (context, searchEntry) => loadingWidget(),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: textFieldDecoration(textHint: "Pilih Kota"),
                    ),
                    selectedItem: selectedKota,
                    onChanged: (item) {
                      setState(() {
                        selectedKota = item;
                        selectedKecamatan = null;
                        selectedKelurahan = null;
                        log(selectedKota.toString());
                      });
                    },
                    enabled: selectedProvinsi != null,
                  ),
                  const SizedBox(height: 12),
                  const LabelForm(label: "Kecamatan", isRequired: true),
                  const SizedBox(height: 5),
                  DropdownSearch<dynamic>(
                    asyncItems: (text) => getKecamatan(),
                    itemAsString: (item) => item['nama_kecamatan'].toString(),
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      menuProps: const MenuProps(),
                      searchFieldProps: TextFieldProps(
                        decoration: textFieldDecoration(
                          textHint: "Cari Kecamatan",
                        ),
                      ),
                      loadingBuilder: (context, searchEntry) => loadingWidget(),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: textFieldDecoration(textHint: "Pilih Kecamatan"),
                    ),
                    selectedItem: selectedKecamatan,
                    onChanged: (item) {
                      setState(() {
                        selectedKecamatan = item;
                        selectedKelurahan = null;
                        log(selectedKecamatan.toString());
                      });
                    },
                    enabled: selectedKota != null,
                  ),
                  const SizedBox(height: 12),
                  const LabelForm(label: "Kelurahan", isRequired: true),
                  const SizedBox(height: 5),
                  DropdownSearch<dynamic>(
                    asyncItems: (text) => getKelurahan(),
                    itemAsString: (item) => item['nama_kelurahan'].toString(),
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      menuProps: const MenuProps(),
                      searchFieldProps: TextFieldProps(
                        decoration: textFieldDecoration(
                          textHint: "Cari Kelurahan",
                        ),
                      ),
                      loadingBuilder: (context, searchEntry) => loadingWidget(),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: textFieldDecoration(textHint: "Pilih Kelurahan"),
                    ),
                    selectedItem: selectedKelurahan,
                    onChanged: (item) {
                      setState(() {
                        selectedKelurahan = item;
                        log(selectedKelurahan.toString());
                      });
                    },
                    enabled: selectedKecamatan != null,
                  ),
                  const SizedBox(height: 12),
                  const LabelForm(label: "Jenis Kelamin", isRequired: true),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Row(
                        children: [
                          Radio(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            value: "Laki-laki",
                            groupValue: _selectedJK,
                            onChanged: (value) {
                              setState(() {
                                _selectedJK = value.toString();
                                log(_selectedJK.toString());
                              });
                            },
                          ),
                          const SizedBox(width: 5),
                          const Text("Laki-Laki"),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Radio(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            value: "Perempuan",
                            groupValue: _selectedJK,
                            onChanged: (value) {
                              setState(() {
                                _selectedJK = value.toString();
                                log(_selectedJK.toString());
                              });
                            },
                          ),
                          const SizedBox(width: 5),
                          const Text("Perempuan"),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const LabelForm(label: "Tempat Lahir", isRequired: true),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _ECtempatLahir,
                    decoration: textFieldDecoration(
                      textHint: "Masukkan Tempat Lahir",
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Tempat Lahir tidak boleh kosong";
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const LabelForm(label: "Tanggal Lahir", isRequired: true),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _ECtanggalLahir,
                    decoration: textFieldDecoration(
                      textHint: "Masukkan Tanggal Lahir",
                    ),
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1945),
                        lastDate: DateTime.now(),
                      ).then(
                        (value) {
                          if (value != null) {
                            selectedDate = value;
                            _ECtanggalLahir.text = parseDateInd(selectedDate.toString(), "EEEE, dd MMMM yyyy");
                          }
                        },
                      );
                    },
                    readOnly: true,
                  ),
                  const SizedBox(height: 12),
                  const LabelForm(label: "Pendidikan", isRequired: true),
                  const SizedBox(height: 5),
                  DropdownSearch<dynamic>(
                    asyncItems: (text) => getPendidikan(),
                    itemAsString: (item) => item['pendidikan_pegawai'].toString(),
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      menuProps: const MenuProps(),
                      searchFieldProps: TextFieldProps(
                        decoration: textFieldDecoration(
                          textHint: "Cari Pendidikan",
                        ),
                      ),
                      loadingBuilder: (context, searchEntry) => loadingWidget(),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: textFieldDecoration(textHint: "Pilih Pendidikan"),
                    ),
                    selectedItem: selectedPendidikan,
                    onChanged: (item) {
                      setState(() {
                        selectedPendidikan = item;
                        log(selectedPendidikan.toString());
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const LabelForm(label: "INFORMASI BANK"),
                  const Divider(),
                  const SizedBox(height: 12),
                  const LabelForm(label: "Bank", isRequired: true),
                  const SizedBox(height: 5),
                  DropdownSearch<dynamic>(
                    asyncItems: (text) => getBank(),
                    itemAsString: (item) => item.toString(),
                    selectedItem: selectedBank,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: textFieldDecoration(textHint: "Pilih Bank"),
                    ),
                    onChanged: (item) {
                      setState(() {
                        selectedBank = item;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  const LabelForm(label: "No Rekening Pegawai", isRequired: true),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _ECrekening,
                    decoration: textFieldDecoration(
                      textHint: "Masukkan No Rekening",
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "No rekening tidak boleh kosong";
                      }

                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  const LabelForm(label: "Nama Pemilik Rekening", isRequired: true),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _ECnamaPemilikR,
                    decoration: textFieldDecoration(
                      textHint: "Masukkan Nama Pemilik Rekening",
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Nama Pemilik Rekening tidak boleh kosong";
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (selectedProvinsi == null) {
                            showToast("Provinsi tidak boleh kosong");
                          } else if (selectedKota == null) {
                            showToast("Kota tidak boleh kosong");
                          } else if (selectedKecamatan == null) {
                            showToast("Kecamatan tidak boleh kosong");
                          } else if (selectedKelurahan == null) {
                            showToast("Kelurahan tidak boleh kosong");
                          } else if (selectedDate == null) {
                            showToast("Tanggal lahir tidak boleh kosong");
                          } else if (selectedPendidikan == null) {
                            showToast("Pendidikan pegawai tidak boleh kosong");
                          } else if (selectedBank == "") {
                            showToast("Bank tidak boleh kosong");
                          } else {
                            simpanPendaftaran();
                          }
                        }
                      },
                      child: const Text("Daftar"),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
