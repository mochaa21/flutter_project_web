// Aby
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'master_data_screen.dart'; // Import halaman baru
import 'profil_screen.dart';      // Import halaman baru

class MainScreen extends StatefulWidget {
  final String role;
  
  const MainScreen({super.key, required this.role});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Susun daftar halaman yang akan ditampilkan saat tab diklik
    _screens = [
      DashboardScreen(role: widget.role),
      const MasterDataScreen(),
      ProfilScreen(role: widget.role),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), // Background luar (untuk Web)
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480), // Kunci layout ukuran HP
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
                  items: const [
                    BottomNavigationBarItem(
                      icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.dashboard_rounded)),
                      label: 'Dashboard',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.storage_rounded)),
                      label: 'Master Data',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_rounded)),
                      label: 'Profil',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}