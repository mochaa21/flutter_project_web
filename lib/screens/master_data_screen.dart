// Aby
import 'package:flutter/material.dart';
import 'kategori_list_screen.dart'; // Import layar kategori
import 'mahasiswa_list_screen.dart'; // Import layar mahasiswa

class MasterDataScreen extends StatelessWidget {
  const MasterDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Master Data', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildMenuCard(
                context,
                Icons.category_rounded, 
                'Kategori Prestasi', 
                'Kelola data kategori dan poin SKPI', 
                const Color(0xFF2563EB),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KategoriListScreen())),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                Icons.people_alt_rounded, 
                'Data Mahasiswa', 
                'Kelola data mahasiswa aktif', 
                const Color(0xFF10B981),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MahasiswaListScreen())),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                Icons.admin_panel_settings_rounded, 
                'Data Validator', 
                'Kelola akun admin dan validator', 
                const Color(0xFFF59E0B),
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur Data Validator segera hadir!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
        ),
      ),
    );
  }
}