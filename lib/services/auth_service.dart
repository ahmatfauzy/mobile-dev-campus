import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const _baseUrl = 'https://freeapi.tahuaci.com';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/register');
    final res = await http.post(
      uri,
      body: {'name': name, 'email': email, 'password': password},
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      final body = json.decode(res.body);
      await _saveAuthData(body['data']);
      return body;
    }

    throw HttpException(res.body, statusCode: res.statusCode);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/login');
    final res = await http.post(
      uri,
      body: {'email': email, 'password': password},
    );

    if (res.statusCode == 200) {
      final body = json.decode(res.body);
      await _saveAuthData(body['data']);
      return body;
    }

    throw HttpException(res.body, statusCode: res.statusCode);
  }

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final token = data['token']?.toString() ?? '';
    final user = data['user'] ?? {};
    final name = user['name']?.toString() ?? '';
    final email = user['email']?.toString() ?? '';

    await _storage.write(key: 'auth_token', value: token);
    await _storage.write(key: 'user_name', value: name);
    await _storage.write(key: 'user_email', value: email);
  }

  Future<String?> getToken() async {
    return _storage.read(key: 'auth_token');
  }

  Future<String?> getUserName() async {
    return _storage.read(key: 'user_name');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'user_email');
  }
}

class HttpException implements Exception {
  final String message;
  final int? statusCode;
  HttpException(this.message, {this.statusCode});

  @override
  String toString() => 'HttpException: $statusCode - $message';
}
