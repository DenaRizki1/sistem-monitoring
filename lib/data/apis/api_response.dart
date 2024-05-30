// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:sistem_monitoring/data/enums/api_status.dart';

class ApiResponse {
  ApiStatus _apiStatus = ApiStatus.loading;
  String _message = "Terjadi kesalahan";
  dynamic _data;

  set setApiSatatus(ApiStatus value) => _apiStatus = value;
  set setMessage(String value) => _message = value;
  set setData(var value) => _data = value;

  get getApiStatus => _apiStatus;
  get getMessage => _message;
  get getData => _data;
}
