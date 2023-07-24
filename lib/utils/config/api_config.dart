import 'dart:convert';

const String bau = '4p1k3yr3st4T1PPppPPpp';
const String bap = '88d19af4acfa4d8aad5d4eb496b520b2';

String getBasicAuth() {
  return 'Basic ${base64Encode(utf8.encode("$bau:$bap"))}';
}

String getBaseUrl() {
  return "https://apps.tacticalinpolice.com/api_guru";
}

String getBaseUrlV2() {
  return "https://apps.tacticalinpolice.com/api_guru_v2";
}
