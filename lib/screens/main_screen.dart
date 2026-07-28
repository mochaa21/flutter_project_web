// Aby
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'master_data_screen.dart'; 
import 'profil_screen.dart';      

class MainScreen extends StatefulWidget {
  final String role;
  
  const MainScreen({super.key, required this.role});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  // Ubah jadi variabel biasa, jangan 'late final' biar gampang diisi dinamis
  List<Widget> _screens = [];
  List<BottomNavigationBarItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    _setupNavigation();
  }

  // --- LOGIKA BARU: Atur Menu Sesuai Role ---
  void _setupNavigation() {
    // Cek apakah yang login adalah mahasiswa atau user biasa
    bool isMahasiswa = widget.role.toLowerCase() == 'mahasiswa' || widget.role.toLowerCase() == 'user';

    // 1. Susun Halaman
    _screens = [
      DashboardScreen(role: widget.role),
      if (!isMahasiswa) const MasterDataScreen(), // Cuma muncul kalau BUKAN mahasiswa
      ProfilScreen(role: widget.role),
    ];

    // 2. Susun Tombol Navigasi Bawah
    _navItems = [
      const BottomNavigationBarItem(
        icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.dashboard_rounded)),
        label: 'Dashboard',
      ),
      if (!isMahasiswa) // Cuma muncul kalau BUKAN mahasiswa
        const BottomNavigationBarItem(
          icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.storage_rounded)),
          label: 'Master Data',
        ),
      const BottomNavigationBarItem(
        icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_rounded)),
        label: 'Profil',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), 
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480), 
          child: Scaffold(
            body: _screens[_selectedIndex],
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedItemColor: const Color(0xFF2563EB),
                  unselectedItemColor: const Color(0xFF94A3B8),
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
                  type: BottomNavigationBarType.fixed,
                  elevation: 0,
                  items: _navItems, // Panggil list nav dinamis di sini
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}