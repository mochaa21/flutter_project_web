// Aby
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class KategoriService {
  final AuthService _authService = AuthService();

  // Ambil list data kategori prestasi
  Future<List<dynamic>> getKategori() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    // Sesuaikan endpoint ini dengan route di api.php Laravel lu 
    // (misal: /kategori-prestasi atau /kategori)
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/kategori-prestasi'), 
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // Cek apakah data dibungkus dalam key 'data' (standar paginate/resource Laravel)
      if (jsonResponse is Map && jsonResponse.containsKey('data')) {
        return jsonResponse['data'];
      }
      return jsonResponse is List ? jsonResponse : [];
    } else {
      throw Exception('Gagal memuat data kategori');
    }
  }
}