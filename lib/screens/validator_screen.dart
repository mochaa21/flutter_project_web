// Aby
import 'package:flutter/material.dart';
import '../services/validator_service.dart';

class ValidatorScreen extends StatefulWidget {
  const ValidatorScreen({super.key});

  @override
  State<ValidatorScreen> createState() => _ValidatorScreenState();
}

class _ValidatorScreenState extends State<ValidatorScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ValidatorService _validatorService = ValidatorService();
  
  bool _isLoading = true;
  List<dynamic> _pendingList = [];
  List<dynamic> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _validatorService.getPendingUsers();
      if (mounted) {
        setState(() {
          _pendingList = data;
          _filteredList = data;
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

  // Fungsi saat tombol ACC ditekan
  Future<void> _accAkun(int id, String nama) async {
    try {
      await _validatorService.accAkun(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Akun $nama berhasil di-ACC!'), backgroundColor: const Color(0xFF10B981)));
        _fetchData(); // Refresh list otomatis setelah ACC berhasil
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal ACC: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredList = _pendingList;
      } else {
        _filteredList = _pendingList.where((item) {
          final nama = (item['name'] ?? item['nama'] ?? '').toString().toLowerCase();
          final email = (item['email'] ?? '').toString().toLowerCase();
          return nama.contains(query.toLowerCase()) || email.contains(query.toLowerCase());
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
        title: const Text('Approval Akun', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterData,
                  decoration: InputDecoration(
                    hintText: 'Cari akun pending...',
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
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchData,
                  color: const Color(0xFF2563EB),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
                      : _filteredList.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 100),
                                Center(child: Text("Tidak ada akun yang menunggu approval", style: TextStyle(color: Color(0xFF64748B))))
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredList.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = _filteredList[index];
                                final int id = item['id'];
                                final String nama = item['name'] ?? item['nama'] ?? 'Tanpa Nama';
                                final String email = item['email'] ?? '-';
                                final String inisial = nama.isNotEmpty ? nama.substring(0, 1).toUpperCase() : '?';

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFFFFF7ED),
                                      child: Text(inisial, style: const TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.bold)),
                                    ),
                                    title: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                    subtitle: Text(email, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                    
                                    // TOMBOL ACC HIJAU
                                    trailing: ElevatedButton(
                                      onPressed: () => _accAkun(id, nama),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF10B981),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        minimumSize: Size.zero,
                                      ),
                                      child: const Text('ACC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
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