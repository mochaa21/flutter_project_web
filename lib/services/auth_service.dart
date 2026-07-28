// Aby
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {'Accept': 'application/json', 'ngrok-skip-browser-warning': 'true',},
        body: {
          'email': email,
          'password': password,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final String token = data['token'];
        final String role = data['user']['role'];
        
        await _saveAuthData(token, role);
        
        return {'success': true, 'role': role, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi server'};
    }
  }

  // Tambahkan fungsi ini di dalam class AuthService
  Future<Map<String, dynamic>> register(String nama, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: {
          'name': nama,
          'email': email,
          'password': password,
          // Secara default kita set sebagai user biasa (mahasiswa)
          'role': 'user', 
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Registrasi berhasil'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal mendaftar'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }

  Future<bool> logout() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        await _clearAuthData();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveAuthData(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_role', role);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
  }
}