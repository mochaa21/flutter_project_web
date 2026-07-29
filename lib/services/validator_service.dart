// Aby
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class ValidatorService {
  final AuthService _authService = AuthService();

  // Ambil list data akun validator (admin/operator)
  Future<List<dynamic>> getValidator() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    // CATATAN: Sesuaikan endpoint ini dengan route API Laravel lu.
    // Biasanya nembak ke route yang nampilin user dengan role != mahasiswa
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/validator'), // Sesuaikan nama route-nya
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
      throw Exception('Gagal memuat data validator');
    }
  }
}