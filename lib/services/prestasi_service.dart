// Aby
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class PrestasiService {
  Future<Map<String, dynamic>> getRiwayatPrestasi() async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      // UBAH DISINI: Tambahkan ?per_page=100 agar semua transaksi ditarik
      Uri.parse('${ApiConfig.baseUrl}/riwayat-prestasi?per_page=100'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil data dari server');
    }
  }

  Future<Map<String, dynamic>> createPrestasi(Map<String, dynamic> data) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/riwayat-prestasi'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: data,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal menyimpan data ke server');
    }
  }

  // UBAH DISINI: Tambahkan parameter existingData
  Future<Map<String, dynamic>> updateStatus(int id, String status, Map<String, dynamic> existingData) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    // Kemas semua data yang diminta Laravel
    final requestBody = {
      'mahasiswa_id': existingData['mahasiswa_id'],
      'kategori_id': existingData['kategori_id'],
      'nama_kompetisi': existingData['nama_kompetisi'],
      'penyelenggara': existingData['penyelenggara'],
      'tanggal_kegiatan': existingData['tanggal_kegiatan'],
      'status_validasi': status, // Status barunya disisipkan di sini
    };

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/riwayat-prestasi/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode(requestBody), // Encode semuanya ke JSON
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 422) {
      final errorData = jsonDecode(response.body);
      String pesanError = errorData['message'] ?? 'Validasi Ditolak Laravel';
      if (errorData['errors'] != null) {
        pesanError = errorData['errors'].toString();
      }
      throw Exception(pesanError);
    } else {
      throw Exception('Gagal memperbarui status: ${response.statusCode}');
    }
  }

  // Tambahkan fungsi ini untuk menghapus data
  Future<void> deletePrestasi(int id) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/riwayat-prestasi/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    // Laravel biasanya merespon dengan 200 (OK) atau 204 (No Content) saat berhasil delete
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus data HTTP: ${response.statusCode}');
    }
  }
}