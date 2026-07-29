// Aby
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class ValidatorService {
  final AuthService _authService = AuthService();

  // Ambil list data akun yang statusnya "pending"
  Future<List<dynamic>> getPendingUsers() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/approval-akun'), 
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is Map && jsonResponse.containsKey('data')) {
        return jsonResponse['data'];
      }
      return jsonResponse is List ? jsonResponse : [];
    } else {
      throw Exception('Gagal memuat data akun pending');
    }
  }

  // Fungsi untuk Eksekusi Tombol ACC
  Future<void> accAkun(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/approval-akun/$id/acc'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal menyetujui akun');
    }
  }
}