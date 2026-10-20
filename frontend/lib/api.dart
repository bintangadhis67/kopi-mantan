import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Error dari API (pesan sudah Bahasa Indonesia, siap ditampilkan).
class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, [this.status]);
  @override
  String toString() => message;
}

/// Klien REST API Kopi Mantan.
class Api {
  /// Isi kalau backend tidak jalan di laptop yang sama.
  /// Contoh HP fisik: 'http://192.168.1.10:3000' (IP laptop di WiFi yang sama).
  static const String? overrideBaseUrl = null;

  static String get baseUrl {
    if (overrideBaseUrl != null) return overrideBaseUrl!;
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android)
      return 'http://10.0.2.2:3000'; // emulator Android
    return 'http://localhost:3000'; // Windows / desktop
  }

  static String? token;
  static const _tokenKey = 'km_token';

  static Future<void> loadToken() async {
    final p = await SharedPreferences.getInstance();
    token = p.getString(_tokenKey);
  }

  static Future<void> saveToken(String? t) async {
    token = t; // langsung diset sebelum await
    final p = await SharedPreferences.getInstance();
    if (t == null) {
      await p.remove(_tokenKey);
    } else {
      await p.setString(_tokenKey, t);
    }
  }

  static Future<dynamic> _send(String method, String path,
      [Object? body]) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final enc = body == null ? null : jsonEncode(body);
    try {
      late http.Response r;
      switch (method) {
        case 'GET':
          r = await http.get(uri, headers: headers);
          break;
        case 'POST':
          r = await http.post(uri, headers: headers, body: enc);
          break;
        case 'PUT':
          r = await http.put(uri, headers: headers, body: enc);
          break;
        case 'DELETE':
          r = await http.delete(uri, headers: headers);
          break;
        default:
          throw ArgumentError('Method tidak didukung: $method');
      }
      final data = r.body.isEmpty ? null : jsonDecode(r.body);
      if (r.statusCode >= 200 && r.statusCode < 300) return data;
      final msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Terjadi kesalahan (${r.statusCode})';
      throw ApiException(msg, r.statusCode);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
          'Tidak bisa terhubung ke server. Pastikan backend sudah berjalan.');
    }
  }

  static Future<dynamic> get(String path) => _send('GET', path);
  static Future<dynamic> post(String path, [Object? body]) =>
      _send('POST', path, body ?? {});
  static Future<dynamic> put(String path, [Object? body]) =>
      _send('PUT', path, body ?? {});
  static Future<dynamic> delete(String path) => _send('DELETE', path);
}
