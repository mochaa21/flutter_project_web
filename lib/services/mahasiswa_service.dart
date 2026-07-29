// Aby
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class MahasiswaService {
  final AuthService _authService = AuthService();

  // Ambil list data mahasiswa
  Future<List<dynamic>> getMahasiswa() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/mahasiswa?per_page=100'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // Karena Laravel pakai paginate(), datanya ada di dalam key 'data'
      return jsonResponse['data'] ?? [];
    } else {
      throw Exception('Gagal memuat data mahasiswa: ${response.statusCode}');
    }
  }
}