// Aby
import 'dart:convert';
import 'dart:io'; // Tambahan untuk File
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class PrestasiService {
  Future<Map<String, dynamic>> getRiwayatPrestasi() async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
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

  // UBAH DISINI: Tambahkan parameter File gambar dan ubah jadi MultipartRequest
  Future<Map<String, dynamic>> createPrestasi(Map<String, String> data, File? imageFile) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    var uri = Uri.parse('${ApiConfig.baseUrl}/riwayat-prestasi');
    var request = http.MultipartRequest('POST', uri);

    // Set Headers
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': 'true',
    });

    // Masukkan data teks (Form Fields)
    request.fields.addAll(data);

    // Masukkan file gambar jika ada
    // Sesuaikan 'file_sertifikat' dengan nama kolom/field yang diminta API Laravel lu
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('file_sertifikat', imageFile.path),
      );
    }

    // Kirim Request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal menyimpan data ke server: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateStatus(int id, String status, Map<String, dynamic> existingData) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final requestBody = {
      'mahasiswa_id': existingData['mahasiswa_id'],
      'kategori_id': existingData['kategori_id'],
      'nama_kompetisi': existingData['nama_kompetisi'],
      'penyelenggara': existingData['penyelenggara'],
      'tanggal_kegiatan': existingData['tanggal_kegiatan'],
      'status_validasi': status, 
    };

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/riwayat-prestasi/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode(requestBody), 
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

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus data HTTP: ${response.statusCode}');
    }
  }
}