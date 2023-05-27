import 'package:http/http.dart' as http;

import '../localsources/auth_local_storage.dart';
import '../models/request/login_model.dart';
import '../models/request/register_model.dart';
import '../models/response/login_response_model.dart';
import '../models/response/profile_response_model.dart';
import '../models/response/register_response_model.dart';

class AuthDatasource {
  Future<RegisterResponseModel> register(RegisterModel registerModel) async {
    final response = await http.post(
      Uri.parse('https://api.escuelajs.co/api/v1/users/'),
      body: registerModel.toMap(),
    );

    final result = RegisterResponseModel.fromJson(response.body);
    return result;
  }

  Future<LoginResponseModel> login(LoginModel loginModel) async {
    final response = await http.post(
      Uri.parse('https://api.escuelajs.co/api/v1/auth/login'),
      body: loginModel.toMap(),
    );

    final result = LoginResponseModel.fromJson(response.body);
    return result;
  }

  Future<ProfileResponseModel> getProfile() async {
    final token = await AuthLocalStorage().getToken();
    var headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(
      Uri.parse('https://api.escuelajs.co/api/v1/auth/profile'),
      headers: headers,
    );

    final result = ProfileResponseModel.fromJson(response.body);
    return result;
  }
}
