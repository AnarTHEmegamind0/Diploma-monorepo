import 'dart:convert';

import 'package:core/core/dio_client.dart';
import 'package:core/features/auth/models/user.dart';
import 'package:core/features/auth/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({Dio? dio}) : _dio = dio ?? DioClient().dio;

  final Dio _dio;

  static const _tokenKey = 'token';
  static const _userKey = 'user';

  @override
  Future<User> login({required String phone, required String password}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'phone': phone,
        'password': password,
      },
    );

    final user = User.fromJson(response.data ?? const {});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, user.token ?? '');
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    return user;
  }

  @override
  Future<User?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me');
      final user = User.fromJson({
        ...?response.data,
        'access_token': token,
      });
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      return user;
    } on DioException {
      await logout();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
