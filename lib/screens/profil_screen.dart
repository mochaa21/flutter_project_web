// Aby
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';
import 'login_screen.dart';
import 'edit_profil_screen.dart';

class ProfilScreen extends StatefulWidget {
  final String role;
  const ProfilScreen({super.key, required this.role});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final AuthService _authService = AuthService();
  
  String _namaLengkap = "Memuat...";
  String _fotoProfil = ""; // Simpan nama file foto
  bool _isLoadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Tarik data profil dari Laravel
  Future<void> _loadProfileData() async {
    try {
      final data = await _authService.getProfile();
      if (mounted) {
        setState(() {
          _namaLengkap = data['data']['name'] ?? 'Tanpa Nama';
          _fotoProfil = data['data']['foto_profil'] ?? '';
        });
      }
    } catch (e) {
      print("Gagal memuat profil: $e");
    }
  }

  // Buka galeri dan langsung upload
  Future<void> _pickAndUploadPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      setState(() => _isLoadingPhoto = true);
      try {
        String? newFileName = await _authService.uploadFotoProfil(image);
        if (newFileName != null) {
          setState(() {
            _fotoProfil = newFileName; // Update UI langsung
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto profil berhasil diperbarui!'), backgroundColor: Color(0xFF10B981)));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal upload: $e'), backgroundColor: Colors.red));
      } finally {
        setState(() => _isLoadingPhoto = false);
      }
    }
  }

  // --- FITUR BARU: HAPUS FOTO ---
  Future<void> _deletePhoto() async {
    setState(() => _isLoadingPhoto = true);
    try {
      await _authService.deleteFotoProfil();
      setState(() {
        _fotoProfil = ""; // Kosongkan UI langsung
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto profil berhasil dihapus'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoadingPhoto = false);
    }
  }

  // --- FITUR BARU: MENU PILIHAN FOTO ---
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF2563EB)),
              title: const Text('Ubah Foto Profil', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context); // Tutup menu
                _pickAndUploadPhoto(); // Jalankan fungsi ubah
              },
            ),
            if (_fotoProfil.isNotEmpty) // Tombol hapus cuma muncul kalau fotonya ada
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: const Text('Hapus Foto', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _deletePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  // --- FITUR BARU: LIHAT FOTO DIPERBESAR ---
  void _showEnlargedImage(String url) {
    if (url.isEmpty) return; // Kalau ga ada foto, ga usah ngapa-ngapain
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer( // Biar fotonya bisa di-zoom pakai jari (cubit)
              panEnabled: true,
              minScale: 1.0,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  url,
                  headers: const {'ngrok-skip-browser-warning': 'true'},
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar Aplikasi?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin mengakhiri sesi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.logout();
              if (mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Ya, Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fitur $featureName segera hadir!'), backgroundColor: const Color(0xFF2563EB)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Siapkan URL gambar asli dari server Laravel (folder public/profil)
    // UBAH BAGIAN INI: Sekarang kita panggil fotonya lewat jalur API yang baru dibuat
    String photoUrl = _fotoProfil.isNotEmpty 
        ? '${ApiConfig.baseUrl}/profil/foto/$_fotoProfil' 
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            color: const Color(0xFFF8FAFC),
            child: Column(
              children: [
                // Header Profil Premium
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, bottom: 40),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
                    boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          // KITA BUNGKUS DENGAN INKWELL BIAR BISA DI-TAP
                          InkWell(
                            onTap: () => _showEnlargedImage(photoUrl),
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFEEF2FF),
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
                              ),
                              child: ClipOval(
                                child: photoUrl.isNotEmpty
                                    ? Image.network(
                                        photoUrl,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                        headers: const {'ngrok-skip-browser-warning': 'true'},
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.image_not_supported_rounded, size: 40, color: Color(0xFF94A3B8));
                                        },
                                      )
                                    : const Icon(Icons.person_rounded, size: 50, color: Color(0xFF2563EB)),
                              ),
                            ),
                          ),
                          
                          if (_isLoadingPhoto)
                            const Positioned.fill(
                              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                            ),

                          // UBAH FUNGSI PADA TOMBOL PENSIL
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _isLoadingPhoto ? null : _showPhotoOptions, // Sekarang panggil menu pilihan
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: const Color(0xFF2563EB), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _namaLengkap, // Nama ditarik asli dari database
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          widget.role.toUpperCase(),
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w800, letterSpacing: 1.1),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Menu List
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("PREFERENSI SISTEM", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        _buildMenuCard(
                          icon: Icons.manage_accounts_rounded,
                          title: "Pengaturan Akun",
                          color: const Color(0xFF334155),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilScreen())).then((value) {
                              if (value == true) _loadProfileData(); // Reload data kalau habis edit profil
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuCard(
                          icon: Icons.help_center_rounded,
                          title: "Panduan Validasi",
                          color: const Color(0xFF334155),
                          onTap: () => _showComingSoon('Panduan Validasi'),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Tombol Keluar
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _handleLogout,
                            icon: const Icon(Icons.logout_rounded, color: Colors.white),
                            label: const Text("Keluar Aplikasi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
                const SizedBox(width: 16),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)))),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFCBD5E1), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}