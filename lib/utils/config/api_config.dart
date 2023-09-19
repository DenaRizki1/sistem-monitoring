import 'dart:convert';

const String bau = '4p1k3yr3st4p1P3ng4j4R';
const String bap = '88d19af4acfa4d8aad5d4eb496b520b24jfij';

String getBasicAuth() {
  return 'Basic ${base64Encode(utf8.encode("$bau:$bap"))}';
}

String getBaseUrl() {
  return "https://api.tacticalinpolice.com/tip5/pengajartip/v1";
}
