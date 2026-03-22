import 'package:core/core/dio_client.dart';
import 'package:core/features/profile/models/profile.dart';
import 'package:core/features/profile/repositories/profile_repository.dart';
import 'package:dio/dio.dart';

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository({Dio? dio}) : _dio = dio ?? DioClient().dio;

  final Dio _dio;

  @override
  Future<Profile> fetchProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return Profile.fromJson(response.data ?? const {});
  }
}
