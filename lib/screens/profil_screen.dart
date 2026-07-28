// Aby
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfilScreen extends StatelessWidget {
  final String role;
  
  const ProfilScreen({super.key, required this.role});

  void _handleLogout(BuildContext context) async {
    await AuthService().logout();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _showComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fitur $featureName sedang dalam tahap pengembangan.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profil Pengguna', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, size: 50, color: Color(0xFF2563EB)),
                ),
                const SizedBox(height: 16),
                Text(
                  role.toUpperCase(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const Text(
                  'Universitas Muhammadiyah',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 40),
                
                // Menu Pengaturan
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.settings_rounded, color: Color(0xFF64748B)),
                        title: const Text('Pengaturan Akun', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                        onTap: () => _showComingSoon(context, 'Pengaturan Akun'),
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ListTile(
                        leading: const Icon(Icons.help_outline_rounded, color: Color(0xFF64748B)),
                        title: const Text('Panduan Validasi', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                        onTap: () => _showComingSoon(context, 'Panduan Validasi'),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Tombol Logout
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleLogout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
                      foregroundColor: const Color(0xFFEF4444),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Keluar Aplikasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}