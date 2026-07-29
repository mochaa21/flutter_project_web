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
  List<dynamic> _validatorList = [];
  List<dynamic> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _validatorService.getValidator();
      if (mounted) {
        setState(() {
          _validatorList = data;
          _filteredList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Kalau error (misal API belum siap), kita bisa tampilin notif
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredList = _validatorList;
      } else {
        _filteredList = _validatorList.where((item) {
          final nama = (item['name'] ?? item['nama'] ?? '').toString().toLowerCase();
          final email = (item['email'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return nama.contains(searchLower) || email.contains(searchLower);
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
        title: const Text('Data Validator', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF2563EB)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form Tambah Akun segera hadir!')));
            },
          )
        ],
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
                    hintText: 'Cari nama atau email...',
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
                                Center(child: Text("Data validator tidak ditemukan", style: TextStyle(color: Color(0xFF64748B))))
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredList.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = _filteredList[index];
                                final String nama = item['name'] ?? item['nama'] ?? 'Tanpa Nama';
                                final String email = item['email'] ?? '-';
                                final String role = (item['role'] ?? 'Operator').toString().toUpperCase();
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
                                      backgroundColor: const Color(0xFFFFF7ED), // Warna orange lembut
                                      child: Text(
                                        inisial,
                                        style: const TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(email, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(role, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                          )
                                        ],
                                      ),
                                    ),
                                    trailing: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFCBD5E1)),
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kelola akses: $nama')));
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