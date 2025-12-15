import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const _baseUrl = 'https://freeapi.tahuaci.com';

  final FlutterSecureStorage storage;
  final http.Client client;

  AuthService({FlutterSecureStorage? storage, http.Client? client})
    : storage = storage ?? const FlutterSecureStorage(),
      client = client ?? http.Client();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/register');
    final res = await client.post(
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
    final res = await client.post(
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

    await storage.write(key: 'auth_token', value: token);
    await storage.write(key: 'user_name', value: name);
    await storage.write(key: 'user_email', value: email);
  }

  Future<String?> getToken() => storage.read(key: 'auth_token');

  Future<String?> getUserName() => storage.read(key: 'user_name');

  Future<void> logout() async {
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'user_name');
    await storage.delete(key: 'user_email');
  }
}

class HttpException implements Exception {
  final String message;
  final int? statusCode;
  HttpException(this.message, {this.statusCode});

  @override
  String toString() => 'HttpException: $statusCode - $message';
}
