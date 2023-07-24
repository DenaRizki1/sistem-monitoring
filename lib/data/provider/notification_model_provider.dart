// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';

class NotificationModelProvider extends ChangeNotifier {
  String id_notif = "";
  String hash_user = "";
  String judul = "";
  String pesan = "";
  String created_at = "";
  String module = "";
  String submodule = "";
  String id = "";
  String image = "";
  String icon = "";
  String read = "";
  String trash = "";
  String jenis = "";
  bool isSelected = false;

  NotificationModelProvider({
    required this.id_notif,
    required this.hash_user,
    required this.judul,
    required this.pesan,
    required this.created_at,
    required this.module,
    required this.submodule,
    required this.id,
    required this.image,
    required this.icon,
    required this.read,
    required this.trash,
    required this.jenis,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_notif': id_notif,
      'hash_user': hash_user,
      'judul': judul,
      'pesan': pesan,
      'created_at': created_at,
      'module': module,
      'submodule': submodule,
      'id': id,
      'image': image,
      'icon': icon,
      'read': read,
      'trash': trash,
      'jenis': jenis,
    };
  }

  factory NotificationModelProvider.fromMap(Map<String, dynamic> map) {
    return NotificationModelProvider(
      id_notif: map['id_notif'] ?? "",
      hash_user: map['hash_user'] ?? "",
      judul: map['judul'] ?? "",
      pesan: map['pesan'] ?? "",
      created_at: map['created_at'] ?? "",
      module: map['module'] ?? "",
      submodule: map['submodule'] ?? "",
      id: map['id'] ?? "",
      image: map['image'] ?? "",
      icon: map['icon'] ?? "",
      read: map['read'] ?? "0",
      trash: map['trash'] ?? "",
      jenis: map['jenis'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModelProvider.fromJson(String source) => NotificationModelProvider.fromMap(json.decode(source) as Map<String, dynamic>);

  set selectedItem(bool value) {
    isSelected = value;
    notifyListeners();
  }
}
