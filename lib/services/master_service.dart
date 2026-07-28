// Aby
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class MasterService {
  Future<List<dynamic>> getMahasiswa() async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    // Tambahkan parameter per_page=100 (atau angka berapapun yang cukup menampung semua mahasiswa)
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/mahasiswa?per_page=100'), 
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    } else {
      throw Exception('Gagal mengambil data mahasiswa');
    }
  }

  Future<List<dynamic>> getKategori() async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    // Kategori biasanya tidak banyak, tapi kita amankan juga dengan per_page=100
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/kategori-prestasi?per_page=100'), 
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    } else {
      throw Exception('Gagal mengambil data kategori');
    }
  }
}