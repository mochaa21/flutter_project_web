// // Aby
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
// import '../services/prestasi_service.dart';
// import 'login_screen.dart';
// import 'input_prestasi_screen.dart';

// class DashboardScreen extends StatefulWidget {
//   final String role;
  
//   const DashboardScreen({super.key, required this.role});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   final AuthService _authService = AuthService();
//   final PrestasiService _prestasiService = PrestasiService();

//   List<dynamic> _prestasiList = [];
//   bool _isLoading = true;
  
//   int _totalData = 0;
//   int _menunggu = 0;
//   int _disetujui = 0;
//   int _ditolak = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   Future<void> _fetchData() async {
//     try {
//       final data = await _prestasiService.getRiwayatPrestasi();
//       final List<dynamic> fetchedList = data['data'];
      
//       int menunggu = 0;
//       int disetujui = 0;
//       int ditolak = 0;
      
//       for (var item in fetchedList) {
//         if (item['status_validasi'] == 'Menunggu') menunggu++;
//         else if (item['status_validasi'] == 'Disetujui' || item['status_validasi'] == 'Valid') disetujui++;
//         else if (item['status_validasi'] == 'Ditolak') ditolak++;
//       }

//       if (mounted) {
//         setState(() {
//           _prestasiList = fetchedList;
//           _totalData = data['meta'] != null ? data['meta']['total'] : (data['total'] ?? 0);
//           _menunggu = menunggu;
//           _disetujui = disetujui;
//           _ditolak = ditolak;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Gagal memuat data')),
//         );
//       }
//     }
//   }

//   void _updateStatus(Map<String, dynamic> item, String status) async {
//     try {
//       await _prestasiService.updateStatus(item['id'], status, item);
//       _fetchData(); 
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Status berhasil diubah ke $status', style: const TextStyle(color: Colors.white)),
//             backgroundColor: (status == 'Disetujui' || status == 'Valid') ? const Color(0xFF10B981) : const Color(0xFFEF4444),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }

//   void _confirmDelete(int id) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: const Text('Konfirmasi Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
//           content: const Text('Apakah Anda yakin ingin menghapus riwayat prestasi ini? Data yang dihapus tidak dapat dikembalikan.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Batal', style: TextStyle(color: Colors.grey)),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); 
//                 _deleteData(id); 
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
//               child: const Text('Hapus', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _deleteData(int id) async {
//     try {
//       await _prestasiService.deletePrestasi(id);
//       _fetchData(); 
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Data berhasil dihapus'), backgroundColor: Colors.green),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }

//   void _handleLogout() async {
//     await _authService.logout();
//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE2E8F0), 
//       body: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 480), 
//           child: Container(
//             color: const Color(0xFFF8FAFC), 
//             child: Stack(
//               children: [
//                 Positioned(
//                   top: -50,
//                   right: -50,
//                   child: Container(
//                     width: 200,
//                     height: 200,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: const Color(0xFF2563EB).withOpacity(0.15),
//                       boxShadow: [
//                         BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.2), blurRadius: 100),
//                       ],
//                     ),
//                   ),
//                 ),
                
//                 SafeArea(
//                   child: RefreshIndicator(
//                     onRefresh: _fetchData, 
//                     color: const Color(0xFF2563EB),
//                     backgroundColor: Colors.white,
//                     child: CustomScrollView(
//                       physics: const AlwaysScrollableScrollPhysics(), 
//                       slivers: [
//                         _buildSliverAppBar(),
//                         SliverToBoxAdapter(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _buildGreetingSection(),
//                                 const SizedBox(height: 32),
//                                 _buildBentoGrid(),
//                                 const SizedBox(height: 40),
//                                 const Text(
//                                   "Daftar Transaksi Terbaru",
//                                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 _buildTransactionList(),
//                                 const SizedBox(height: 80), 
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
                
//                 Positioned(
//                   bottom: 24,
//                   right: 24,
//                   child: FloatingActionButton.extended(
//                     onPressed: () async {
//                       final result = await Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => const InputPrestasiScreen()),
//                       );
//                       if (result == true) {
//                         _fetchData(); 
//                       }
//                     },
//                     backgroundColor: const Color(0xFF2563EB),
//                     elevation: 4,
//                     icon: const Icon(Icons.add, color: Colors.white),
//                     label: const Text("Input Prestasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSliverAppBar() {
//     return SliverAppBar(
//       expandedHeight: 70.0,
//       floating: true,
//       pinned: true,
//       backgroundColor: Colors.white.withOpacity(0.8),
//       elevation: 0,
//       flexibleSpace: ClipRect(
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: const FlexibleSpaceBar(background: SizedBox()),
//         ),
//       ),
//       title: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(10)),
//             child: const Text("UM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//           ),
//           const SizedBox(width: 12),
//           const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('SKPI Informatika', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B))),
//               Text('Universitas Muhammadiyah', style: TextStyle(fontSize: 11, color: Colors.grey)),
//             ],
//           ),
//         ],
//       ),
//       actions: [
//         Padding(
//           padding: const EdgeInsets.only(right: 16.0),
//           child: InkWell(
//             onTap: _handleLogout,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
//               child: const Row(
//                 children: [
//                   Text("LOGOUT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
//                   SizedBox(width: 6),
//                   Icon(Icons.logout, color: Colors.red, size: 16),
//                 ],
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _buildGreetingSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Validasi Prestasi", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B).withOpacity(0.9))),
//         const SizedBox(height: 8),
//         Text("Dashboard pengelolaan dan verifikasi data SKPI.\nAnda login sebagai: ${widget.role.toUpperCase()}", style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5)),
//       ],
//     );
//   }

//   Widget _buildBentoGrid() {
//     if (_isLoading) return const Center(child: CircularProgressIndicator());
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       mainAxisSpacing: 16,
//       crossAxisSpacing: 16,
//       childAspectRatio: 1.1,
//       children: [
//         _buildStatCard("Total Data", _totalData.toString(), Icons.folder_copy_rounded, const Color(0xFF2563EB)),
//         _buildStatCard("Menunggu", _menunggu.toString(), Icons.hourglass_top_rounded, const Color(0xFFF59E0B)),
//         _buildStatCard("Disetujui", _disetujui.toString(), Icons.check_circle_rounded, const Color(0xFF10B981)),
//         _buildStatCard("Ditolak", _ditolak.toString(), Icons.cancel_rounded, const Color(0xFFEF4444)),
//       ],
//     );
//   }

//   Widget _buildStatCard(String title, String count, IconData icon, Color color) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
//       ),
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
//             child: Icon(icon, color: color, size: 24),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
//               Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransactionList() {
//     if (_isLoading) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
//     if (_prestasiList.isEmpty) return const Center(child: Text("Belum ada data prestasi."));

//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _prestasiList.length,
//       itemBuilder: (context, index) {
//         final item = _prestasiList[index];
//         final String status = item['status_validasi'];
//         Color statusColor = const Color(0xFFF59E0B); 
        
//         if (status == 'Disetujui' || status == 'Valid') statusColor = const Color(0xFF10B981);
//         if (status == 'Ditolak') statusColor = const Color(0xFFEF4444);

//         return Container(
//           margin: const EdgeInsets.only(bottom: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.015),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 48,
//                       height: 48,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFF8FAFC),
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       child: Text(
//                         "0${index + 1}", 
//                         style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), fontSize: 16),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             item['mahasiswa']['nama_lengkap'], 
//                             style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E293B)),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             item['nama_kompetisi'], 
//                             style: const TextStyle(color: Color(0xFF2563EB), fontSize: 13, fontWeight: FontWeight.w500),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//                     Text(
//                       "${item['kategori']['poin_skpi']} Pts", 
//                       style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B)),
//                     ),
//                   ],
//                 ),
                
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 12.0),
//                   child: Divider(height: 1, color: Color(0xFFF1F5F9)),
//                 ),
                
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: statusColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor)),
//                           const SizedBox(width: 6),
//                           Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                     ),
                    
//                     Row(
//                       children: [
//                         // KODE AMAN: Semua tombol aksi HANYA muncul jika BUKAN user DAN BUKAN mahasiswa
//                         if (widget.role.toLowerCase() != 'user' && widget.role.toLowerCase() != 'mahasiswa') ...[
//                           if (status != 'Disetujui' && status != 'Valid') 
//                             InkWell(
//                               onTap: () => _updateStatus(item, 'Valid'),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                 decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//                                 child: const Row(
//                                   children: [
//                                     Icon(Icons.check, color: Colors.green, size: 16),
//                                     SizedBox(width: 4),
//                                     Text("Setujui", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           if (status != 'Disetujui' && status != 'Valid' && status != 'Ditolak')
//                             const SizedBox(width: 8),
//                           if (status != 'Ditolak')
//                             InkWell(
//                               onTap: () => _updateStatus(item, 'Ditolak'),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                 decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//                                 child: const Row(
//                                   children: [
//                                     Icon(Icons.close, color: Colors.red, size: 16),
//                                     SizedBox(width: 4),
//                                     Text("Tolak", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           const SizedBox(width: 8),
                          
//                           // TOMBOL HAPUS SEKARANG DI DALAM BLOK ADMIN
//                           InkWell(
//                             onTap: () => _confirmDelete(item['id']),
//                             child: Container(
//                               padding: const EdgeInsets.all(6),
//                               decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//                               child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
//                             ),
//                           ),
//                         ],
//                       ],
//                     )
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// Aby
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/prestasi_service.dart';
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

  List<dynamic> _prestasiList = [];
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

  Future<void> _fetchData() async {
    try {
      final data = await _prestasiService.getRiwayatPrestasi();
      // Pastikan kalau null, anggap aja list kosong biar nggak error
      final List<dynamic> fetchedList = data['data'] ?? []; 
      
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
          // Langsung hitung dari jumlah item yang diterima
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
        // Tampilkan pesan error aslinya biar gampang dilacak kalau masih ada masalah
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: Colors.red),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil dihapus'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
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
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.2), blurRadius: 100),
                      ],
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
                                _buildBentoGrid(),
                                const SizedBox(height: 40),
                                const Text(
                                  "Daftar Transaksi Terbaru",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                ),
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
                      if (result == true) {
                        _fetchData(); 
                      }
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
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
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

  Widget _buildBentoGrid() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard("Total Data", _totalData.toString(), Icons.folder_copy_rounded, const Color(0xFF2563EB)),
        _buildStatCard("Menunggu", _menunggu.toString(), Icons.hourglass_top_rounded, const Color(0xFFF59E0B)),
        _buildStatCard("Disetujui", _disetujui.toString(), Icons.check_circle_rounded, const Color(0xFF10B981)),
        _buildStatCard("Ditolak", _ditolak.toString(), Icons.cancel_rounded, const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    if (_prestasiList.isEmpty) return const Center(child: Text("Belum ada data prestasi."));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _prestasiList.length,
      itemBuilder: (context, index) {
        final item = _prestasiList[index];
        final String status = item['status_validasi'] ?? 'Menunggu';
        Color statusColor = const Color(0xFFF59E0B); 
        
        if (status == 'Disetujui' || status == 'Valid') statusColor = const Color(0xFF10B981);
        if (status == 'Ditolak') statusColor = const Color(0xFFEF4444);

        // AMAN DARI NULL: Cek dulu relasi mahasiswanya ada atau nggak
        String namaMahasiswa = 'Tanpa Nama';
        if (item['mahasiswa'] != null && item['mahasiswa']['nama_lengkap'] != null) {
          namaMahasiswa = item['mahasiswa']['nama_lengkap'];
        }

        // AMAN DARI NULL: Cek poin skpi
        String poinSkpi = '0';
        if (item['kategori'] != null && item['kategori']['poin_skpi'] != null) {
          poinSkpi = item['kategori']['poin_skpi'].toString();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        "0${index + 1}", 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            namaMahasiswa, 
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E293B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['nama_kompetisi'] ?? '-', 
                            style: const TextStyle(color: Color(0xFF2563EB), fontSize: 13, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "$poinSkpi Pts", 
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B)),
                    ),
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
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor)),
                          const SizedBox(width: 6),
                          Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    
                    Row(
                      children: [
                        if (widget.role.toLowerCase() != 'user' && widget.role.toLowerCase() != 'mahasiswa') ...[
                          if (status != 'Disetujui' && status != 'Valid') 
                            InkWell(
                              onTap: () => _updateStatus(item, 'Valid'),
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
                          if (status != 'Disetujui' && status != 'Valid' && status != 'Ditolak')
                            const SizedBox(width: 8),
                          if (status != 'Ditolak')
                            InkWell(
                              onTap: () => _updateStatus(item, 'Ditolak'),
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
        );
      },
    );
  }
}