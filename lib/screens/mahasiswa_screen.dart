// Aby
import 'package:flutter/material.dart';
import '../services/mahasiswa_service.dart';

class MahasiswaScreen extends StatefulWidget {
  const MahasiswaScreen({super.key});

  @override
  State<MahasiswaScreen> createState() => _MahasiswaScreenState();
}

class _MahasiswaScreenState extends State<MahasiswaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MahasiswaService _mahasiswaService = MahasiswaService();
  
  bool _isLoading = true;
  List<dynamic> _mahasiswaList = [];
  List<dynamic> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fungsi narik data dari API
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _mahasiswaService.getMahasiswa();
      if (mounted) {
        setState(() {
          _mahasiswaList = data;
          _filteredList = data; // Awalnya tampilkan semua
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  // Fungsi Filter Pencarian
  void _filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredList = _mahasiswaList;
      } else {
        _filteredList = _mahasiswaList.where((item) {
          // Amankan dari null dan sesuaikan kalau nama kolom di db lu 'nama_lengkap' atau 'nama'
          final nama = (item['nama_lengkap'] ?? item['nama'] ?? '').toString().toLowerCase();
          final nim = (item['nim'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();
          
          return nama.contains(searchLower) || nim.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF2563EB)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form Tambah Mahasiswa segera hadir!')));
            },
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              // Search Bar Area
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterData,
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau NIM mahasiswa...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                  ),
                ),
              ),
              
              // List Area
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchData, // Bisa ditarik ke bawah buat refresh
                  color: const Color(0xFF2563EB),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
                      : _filteredList.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 100),
                                Center(child: Text("Data mahasiswa tidak ditemukan", style: TextStyle(color: Color(0xFF64748B))))
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredList.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = _filteredList[index];
                                
                                // Deteksi nama kolom secara dinamis (Anti-Error)
                                final String namaLengkap = item['nama_lengkap'] ?? item['nama'] ?? 'Tanpa Nama';
                                final String nim = item['nim'] ?? '-';
                                final String prodi = item['program_studi'] ?? item['prodi'] ?? 'Informatika';
                                final String inisial = namaLengkap.isNotEmpty ? namaLengkap.substring(0, 1).toUpperCase() : '?';

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFFEEF2FF),
                                      child: Text(
                                        inisial,
                                        style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(namaLengkap, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(nim, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                        Text(prodi, style: const TextStyle(color: Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFCBD5E1)),
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Detail $namaLengkap ditekan')));
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}