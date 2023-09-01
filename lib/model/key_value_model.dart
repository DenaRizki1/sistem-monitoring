// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class KeyValueModel {
  String key;
  String value;

  KeyValueModel({
    required this.key,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'key': key,
      'value': value,
    };
  }

  factory KeyValueModel.fromMap(Map<String, dynamic> map) {
    return KeyValueModel(
      key: map['key'] as String,
      value: map['value'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory KeyValueModel.fromJson(String source) => KeyValueModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
