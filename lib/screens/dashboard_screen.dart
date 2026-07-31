// Aby
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Tambahan untuk Export Laporan
import '../services/auth_service.dart';
import '../services/prestasi_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart'; // Tambahan untuk baseUrl
import 'login_screen.dart';
import 'input_prestasi_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String role;
  
  const DashboardScreen({super.key, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final PrestasiService _prestasiService = PrestasiService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _prestasiList = [];
  List<dynamic> _filteredList = []; // List baru khusus untuk hasil pencarian
  bool _isLoading = true;
  
  int _totalData = 0;
  int _menunggu = 0;
  int _disetujui = 0;
  int _ditolak = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _prestasiService.getRiwayatPrestasi();
      
      List<dynamic> fetchedList = [];
      if (data is List) {
        fetchedList = data;
      } else if (data is Map && data['data'] != null) {
        fetchedList = data['data'];
      }
      
      int menunggu = 0;
      int disetujui = 0;
      int ditolak = 0;
      
      for (var item in fetchedList) {
        if (item['status_validasi'] == 'Menunggu') menunggu++;
        else if (item['status_validasi'] == 'Disetujui' || item['status_validasi'] == 'Valid') disetujui++;
        else if (item['status_validasi'] == 'Ditolak') ditolak++;
      }

      if (mounted) {
        setState(() {
          _prestasiList = fetchedList;
          _filteredList = fetchedList; // Isi awal filtered list = semua data
          _totalData = fetchedList.length; 
          _menunggu = menunggu;
          _disetujui = disetujui;
          _ditolak = ditolak;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error memuat data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- FITUR BARU: FUNGSI PENCARIAN REAL-TIME ---
  void _filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredList = _prestasiList;
      } else {
        _filteredList = _prestasiList.where((item) {
          final judul = (item['nama_kompetisi'] ?? '').toLowerCase();
          final penyelenggara = (item['penyelenggara'] ?? '').toLowerCase();
          final namaMahasiswa = (item['mahasiswa'] != null) 
              ? (item['mahasiswa']['nama_lengkap'] ?? item['mahasiswa']['nama'] ?? '').toLowerCase() 
              : '';
              
          final searchLower = query.toLowerCase();
          return judul.contains(searchLower) || penyelenggara.contains(searchLower) || namaMahasiswa.contains(searchLower);
        }).toList();
      }
    });
  }

  // --- FITUR BARU: FUNGSI EXPORT LAPORAN ---
  Future<void> _exportLaporan() async {
    // Sesuaikan URL ini dengan route web.php di Laravel lu.
    // Pastikan di Laravel ada route: Route::get('/export-csv', [RiwayatPrestasiController::class, 'exportCsv']);
    final url = Uri.parse('${ApiConfig.baseUrl.replaceAll('/api', '')}/export-csv');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication); // Buka lewat browser bawaan HP
      } else {
        throw 'Tidak dapat membuka link download';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memulai proses download laporan'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- DETAIL PRESTASI RIWAYAT DISINI ---
  // FUNCTION
  // --- DETAIL PRESTASI RIWAYAT DISINI ---
  // FUNCTION
  void _showDetailPrestasi(Map<String, dynamic> item, String role) {
    final String namaKompetisi = item['nama_kompetisi'] ?? '-';
    final String tingkat = item['tingkat'] ?? '-';
    final String penyelenggara = item['penyelenggara'] ?? '-';
    final String fileBukti = item['file_bukti'] ?? '';
    
    // Paksa jadi huruf kecil untuk pencocokan logika
    final String rawStatus = (item['status_validasi'] ?? 'menunggu').toString().toLowerCase();
    final int idPrestasi = item['id'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Detail Prestasi', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Kompetisi: $namaKompetisi', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Penyelenggara: $penyelenggara'),
              Text('Tingkat: $tingkat'),
              Text('Status: ${rawStatus.toUpperCase()}'),
              const SizedBox(height: 16),
              
              // Tombol Buka Sertifikat
              if (fileBukti.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    final imageUrl = '${ApiConfig.baseUrl.replaceAll('/api', '')}/file-bukti/$fileBukti';
                    
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            // TRIK JITU: Tarik gambar sebagai Bytes biar header Ngrok tembus!
                            FutureBuilder<http.Response>(
                              future: http.get(
                                Uri.parse(imageUrl),
                                headers: {'ngrok-skip-browser-warning': 'true'},
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 300, 
                                    child: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
                                  );
                                }
                                
                                // Jika sukses tembus Ngrok dan dapat gambar
                                if (snapshot.hasData && snapshot.data!.statusCode == 200) {
                                  return InteractiveViewer(
                                    child: Image.memory(
                                      snapshot.data!.bodyBytes,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                    ),
                                  );
                                }

                                // Jika kena blokir CORS keamanan browser
                                return Container(
                                  height: 250,
                                  width: double.infinity,
                                  color: Colors.grey[100],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.cloud_download_rounded, color: Color(0xFF2563EB), size: 50),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Preview diblokir keamanan browser', 
                                        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final url = Uri.parse(imageUrl);
                                          // Membuka URL di luar aplikasi (Browser default HP / Tab baru di Chrome)
                                          // Otomatis mendownload atau menampilkan file asli tanpa kena blokir CORS aplikasi
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url, mode: LaunchMode.externalApplication);
                                          } else {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Gagal membuka link file')),
                                              );
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                                        label: const Text('Download / Lihat File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF2563EB),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.image, color: Colors.white),
                  label: const Text('Lihat File Bukti', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                )
              else
                const Text('Tidak ada file bukti dilampirkan', style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
          ),
          
          // TOMBOL ACC / TOLAK HANYA MUNCUL JIKA BUKAN MAHASISWA DAN STATUS BELUM DISETUJUI
          if (role.toLowerCase() != 'user' && role.toLowerCase() != 'mahasiswa' && rawStatus != 'disetujui') ...[
            if (rawStatus != 'ditolak')
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateStatusPrestasi(idPrestasi, 'ditolak'); 
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Tolak', style: TextStyle(color: Colors.white)),
              ),
            
            if (rawStatus != 'disetujui')
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateStatusPrestasi(idPrestasi, 'disetujui'); 
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('ACC', style: TextStyle(color: Colors.white)),
              ),
          ]
        ],
      ),
    );
  }

  // Fungsi tembak API untuk update status (ACC / Tolak)
  Future<void> _updateStatusPrestasi(int id, String status) async {
    try {
      // 1. Ambil token untuk akses API (langsung pakai _authService yang udah ada di class lu)
      final token = await _authService.getToken();
      if (token == null) throw Exception('Sesi telah habis, silakan login ulang.');

      // 2. Munculkan indikator loading (berupa pop-up dialog yang tidak bisa ditutup manual)
      showDialog(
        context: context,
        barrierDismissible: false, 
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
        ),
      );

      // 3. Tembak API Laravel
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/riwayat-prestasi/$id/validasi'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: {
          'status_validasi': status, // isinya 'disetujui' atau 'ditolak'
        },
      );

      // 4. Tutup indikator loading
      if (mounted) Navigator.pop(context);

      // 5. Cek hasil dari server
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (mounted) {
          // Tampilkan notifikasi sukses (Hijau untuk ACC, Merah untuk Tolak)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Status berhasil diubah'),
              backgroundColor: status == 'disetujui' ? const Color(0xFF10B981) : Colors.red,
            ),
          );
          _fetchData();
          
          // Panggil fungsi untuk me-refresh data di dashboard lu biar statusnya langsung berubah
          // Contoh: _fetchDashboardData(); atau setState(() {});
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal memvalidasi prestasi');
      }
    } catch (e) {
      // Tutup indikator loading jika terjadi error (hindari dialog nyangkut)
      if (mounted && Navigator.canPop(context)) {
         Navigator.pop(context);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _updateStatus(Map<String, dynamic> item, String status) async {
    try {
      await _prestasiService.updateStatus(item['id'], status, item);
      _fetchData(); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status berhasil diubah ke $status', style: const TextStyle(color: Colors.white)),
            backgroundColor: (status == 'Disetujui' || status == 'Valid') ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Konfirmasi Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Apakah Anda yakin ingin menghapus riwayat prestasi ini? Data yang dihapus tidak dapat dikembalikan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                _deleteData(id); 
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _deleteData(int id) async {
    try {
      await _prestasiService.deletePrestasi(id);
      _fetchData(); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), 
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480), 
          child: Container(
            color: const Color(0xFFF8FAFC), 
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2563EB).withOpacity(0.15),
                      boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.2), blurRadius: 100)],
                    ),
                  ),
                ),
                
                SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _fetchData, 
                    color: const Color(0xFF2563EB),
                    backgroundColor: Colors.white,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(), 
                      slivers: [
                        _buildSliverAppBar(),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildGreetingSection(),
                                const SizedBox(height: 32),
                                _buildVisualBentoGrid(), // Grid statistik yang sudah di-upgrade visual
                                const SizedBox(height: 40),
                                
                                // --- AREA PENCARIAN (SEARCH BAR) ---
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Daftar Transaksi",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(20)),
                                      child: Text("${_filteredList.length} Data", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569))),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildSearchBar(),
                                const SizedBox(height: 16),
                                
                                _buildTransactionList(),
                                const SizedBox(height: 80), 
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InputPrestasiScreen()),
                      );
                      if (result == true) _fetchData(); 
                    },
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 4,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Input Prestasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(10)),
            child: const Text("UM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SKPI Informatika', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B))),
              Text('Universitas Muhammadiyah', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
      actions: [
        // --- TOMBOL EXPORT LAPORAN DI APPBAR ---
        if (widget.role.toLowerCase() != 'user' && widget.role.toLowerCase() != 'mahasiswa')
          IconButton(
            onPressed: _exportLaporan,
            icon: const Icon(Icons.download_rounded, color: Color(0xFF10B981)),
            tooltip: 'Download Laporan Excel/CSV',
          ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 8.0),
          child: InkWell(
            onTap: _handleLogout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Text("LOGOUT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(width: 6),
                  Icon(Icons.logout, color: Colors.red, size: 16),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Validasi Prestasi", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B).withOpacity(0.9))),
        const SizedBox(height: 8),
        Text("Dashboard pengelolaan dan verifikasi data SKPI.\nAnda login sebagai: ${widget.role.toUpperCase()}", style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5)),
      ],
    );
  }

  // --- TAMPILAN GRAFIK STATISTIK (VISUAL BENTO GRID) ---
  Widget _buildVisualBentoGrid() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    
    // Kalkulasi persentase untuk bar visual
    double progressMenunggu = _totalData == 0 ? 0 : _menunggu / _totalData;
    double progressDisetujui = _totalData == 0 ? 0 : _disetujui / _totalData;
    double progressDitolak = _totalData == 0 ? 0 : _ditolak / _totalData;

    return Column(
      children: [
        // Kotak Utama (Total & Grafik Visual)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Keseluruhan", style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.analytics_rounded, color: Color(0xFF2563EB), size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(_totalData.toString(), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              const SizedBox(height: 20),
              
              // Bar Grafik Sederhana
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    if (_disetujui > 0) Expanded(flex: _disetujui, child: Container(height: 8, color: const Color(0xFF10B981))),
                    if (_menunggu > 0) Expanded(flex: _menunggu, child: Container(height: 8, color: const Color(0xFFF59E0B))),
                    if (_ditolak > 0) Expanded(flex: _ditolak, child: Container(height: 8, color: const Color(0xFFEF4444))),
                    if (_totalData == 0) Expanded(child: Container(height: 8, color: const Color(0xFFE2E8F0))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Grid Status Bawahnya
        Row(
          children: [
            Expanded(child: _buildMiniStatCard("Menunggu", _menunggu.toString(), Icons.hourglass_top_rounded, const Color(0xFFF59E0B), progressMenunggu)),
            const SizedBox(width: 16),
            Expanded(child: _buildMiniStatCard("Disetujui", _disetujui.toString(), Icons.check_circle_rounded, const Color(0xFF10B981), progressDisetujui)),
          ],
        )
      ],
    );
  }

  Widget _buildMiniStatCard(String title, String count, IconData icon, Color color, double progress) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              Text("${(progress * 100).toInt()}%", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        ],
      ),
    );
  }

  // --- SEARCH BAR WIDGET ---
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _filterData,
      decoration: InputDecoration(
        hintText: 'Cari nama kompetisi, mahasiswa...',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Color(0xFF94A3B8), size: 18),
                onPressed: () {
                  _searchController.clear();
                  _filterData('');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    if (_filteredList.isEmpty) return const Center(child: Text("Data tidak ditemukan.", style: TextStyle(color: Color(0xFF64748B))));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredList.length,
      itemBuilder: (context, index) {
        final item = _filteredList[index];
        
        // 1. Ambil status mentah dari database, paksa jadi huruf kecil semua
        final String rawStatus = (item['status_validasi'] ?? 'menunggu').toString().toLowerCase();
        
        // 2. Siapkan label teks dan warna untuk UI
        String statusDisplay = 'MENUNGGU';
        Color statusColor = const Color(0xFFF59E0B); 
        
        if (rawStatus == 'disetujui') {
          statusDisplay = 'DISETUJUI'; 
          statusColor = const Color(0xFF10B981); // Hijau
        } else if (rawStatus == 'ditolak') {
          statusDisplay = 'DITOLAK';
          statusColor = const Color(0xFFEF4444); // Merah
        }

        String namaMahasiswa = 'Tanpa Nama';
        if (item['mahasiswa'] != null) {
          namaMahasiswa = item['mahasiswa']['nama_lengkap'] ?? item['mahasiswa']['nama'] ?? 'Tanpa Nama';
        }

        String poinSkpi = '0';
        if (item['kategori'] != null) {
          poinSkpi = (item['kategori']['poin_skpi'] ?? '0').toString();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                _showDetailPrestasi(item, widget.role);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14)),
                          child: Text("0${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), fontSize: 16)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                namaMahasiswa, 
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E293B)),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['nama_kompetisi'] ?? '-', 
                                style: const TextStyle(color: Color(0xFF2563EB), fontSize: 13, fontWeight: FontWeight.w500),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text("$poinSkpi Pts", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B))),
                      ],
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor)),
                              const SizedBox(width: 6),
                              // PAKAI statusDisplay DI SINI BIAR WARNA DAN TEKS NYAMBUNG
                              Text(statusDisplay, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        
                        Row(
                          children: [
                            if (widget.role.toLowerCase() != 'user' && widget.role.toLowerCase() != 'mahasiswa') ...[
                              
                              // TOMBOL SETUJUI (Hilang kalau statusnya udah disetujui)
                              if (rawStatus != 'disetujui') 
                                InkWell(
                                  onTap: () => _updateStatus(item, 'disetujui'), // Kirim 'disetujui' ke Laravel
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.check, color: Colors.green, size: 16),
                                        SizedBox(width: 4),
                                        Text("Setujui", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                
                              if (rawStatus != 'disetujui' && rawStatus != 'ditolak')
                                const SizedBox(width: 8),
                                
                              // TOMBOL TOLAK (Hilang kalau statusnya udah ditolak)
                              if (rawStatus != 'ditolak')
                                InkWell(
                                  onTap: () => _updateStatus(item, 'ditolak'), // Kirim 'ditolak' ke Laravel
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.close, color: Colors.red, size: 16),
                                        SizedBox(width: 4),
                                        Text("Tolak", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                
                              const SizedBox(width: 8),
                              
                              InkWell(
                                onTap: () => _confirmDelete(item['id']),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                ),
                              ),
                            ],
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}