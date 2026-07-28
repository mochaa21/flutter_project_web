// Aby
import 'package:flutter/material.dart';
import '../services/master_service.dart';

class MahasiswaListScreen extends StatefulWidget {
  const MahasiswaListScreen({super.key});

  @override
  State<MahasiswaListScreen> createState() => _MahasiswaListScreenState();
}

class _MahasiswaListScreenState extends State<MahasiswaListScreen> {
  final MasterService _masterService = MasterService();
  List<dynamic> _mahasiswaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMahasiswa();
  }

  Future<void> _fetchMahasiswa() async {
    try {
      final data = await _masterService.getMahasiswa();
      if (mounted) {
        setState(() {
          _mahasiswaList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data mahasiswa'), backgroundColor: Colors.red),
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
        title: const Text('Data Mahasiswa', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchMahasiswa,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: _mahasiswaList.length,
                    itemBuilder: (context, index) {
                      final item = _mahasiswaList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                            child: const Icon(Icons.person_rounded, color: Color(0xFF10B981)),
                          ),
                          title: Text(item['nama_lengkap'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          subtitle: Text("NIM: ${item['nim'] ?? '-'}", style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                          trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
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