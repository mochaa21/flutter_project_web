// Aby
import 'dart:ui';
import 'package:flutter/material.dart';
import 'mahasiswa_screen.dart';
import 'kategori_screen.dart';
import 'validator_screen.dart';

class MasterDataScreen extends StatelessWidget {
  const MasterDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            color: const Color(0xFFF8FAFC),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(24.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const Text(
                        "Kelola Data Induk",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Atur dan sesuaikan data kategori, mahasiswa, serta validator sistem.",
                        style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      
                      _buildMasterCard(
                        context,
                        title: 'Kategori Prestasi',
                        subtitle: 'Kelola data kategori dan poin standar SKPI',
                        icon: Icons.category_rounded,
                        color: const Color(0xFF2563EB),
                        onTap: () {
                          // UBAH BAGIAN INI
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const KategoriScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildMasterCard(
                        context,
                        title: 'Data Mahasiswa',
                        subtitle: 'Kelola direktori data mahasiswa aktif',
                        icon: Icons.people_alt_rounded,
                        color: const Color(0xFF10B981),
                        onTap: () {
                          // UBAH BAGIAN INI BIAR PINDAH HALAMAN
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MahasiswaScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildMasterCard(
                        context,
                        title: 'Data Validator',
                        subtitle: 'Kelola hak akses admin dan operator',
                        icon: Icons.admin_panel_settings_rounded,
                        color: const Color(0xFFF59E0B),
                        onTap: () {
                          // UBAH BAGIAN INI
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ValidatorScreen()),
                          );
                        },
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 70.0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white.withOpacity(0.8),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: const FlexibleSpaceBar(background: SizedBox()),
        ),
      ),
      title: const Text(
        'Master Data',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF1E293B)),
      ),
      centerTitle: true,
    );
  }

  Widget _buildMasterCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          highlightColor: color.withOpacity(0.05),
          splashColor: color.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xFFCBD5E1), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}