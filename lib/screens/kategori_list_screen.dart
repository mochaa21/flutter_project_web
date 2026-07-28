// Aby
import 'package:flutter/material.dart';
import '../services/master_service.dart';

class KategoriListScreen extends StatefulWidget {
  const KategoriListScreen({super.key});

  @override
  State<KategoriListScreen> createState() => _KategoriListScreenState();
}

class _KategoriListScreenState extends State<KategoriListScreen> {
  final MasterService _masterService = MasterService();
  List<dynamic> _kategoriList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKategori();
  }

  Future<void> _fetchKategori() async {
    try {
      final data = await _masterService.getKategori();
      if (mounted) {
        setState(() {
          _kategoriList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data kategori'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: const Text('Kategori Prestasi', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchKategori,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: _kategoriList.length,
                    itemBuilder: (context, index) {
                      final item = _kategoriList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.category_rounded, color: Color(0xFF2563EB)),
                          ),
                          title: Text(item['nama_kategori'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          subtitle: Text("Tingkat: ${item['tingkat'] ?? '-'}", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Text("${item['poin_skpi']} Pts", style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}