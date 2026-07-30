// Aby
import 'dart:convert';
import 'dart:io'; // Tambahan untuk File
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:image_picker/image_picker.dart';
import 'auth_service.dart';

class PrestasiService {
  Future<dynamic> getRiwayatPrestasi() async {
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
      // INI YANG PENTING: Tampilkan error asli dari Laravel
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  // UBAH DISINI: Tambahkan parameter File gambar dan ubah jadi MultipartRequest
  // Pastikan import ini ada di paling atas file service lu:
  // import 'package:http/http.dart' as http;
  // import 'package:image_picker/image_picker.dart'; // Untuk XFile

  Future<void> createPrestasi(Map<String, String> data, dynamic imageFile) async {
    // 1. Ambil token
    final token = await AuthService().getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/riwayat-prestasi'),
    );

    // 2. Set Header
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': 'true',
    });

    // 3. Masukkan data teks (ID mahasiswa, kategori, nama, dsb)
    request.fields.addAll(data);

    // 4. MASUKKAN GAMBAR (ANTI ERROR WEB)
    if (imageFile != null) {
      // Baca file sebagai Bytes (aman untuk Web dan Mobile)
      var bytes = await imageFile.readAsBytes();
      
      String fileName = imageFile.name;
      if (!fileName.toLowerCase().endsWith('.jpg') && !fileName.toLowerCase().endsWith('.png') && !fileName.toLowerCase().endsWith('.jpeg')) {
        fileName = 'bukti_prestasi.jpg'; // Nama default jika tidak terbaca
      }

      var multipartFile = http.MultipartFile.fromBytes(
        'file_bukti', // Harus sama dengan request di Laravel
        bytes,
        filename: fileName,
      );
      
      request.files.add(multipartFile);
    }

    // 5. Eksekusi pengiriman
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error Server: ${response.body}');
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