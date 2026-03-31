import 'package:flutter/material.dart';
import 'package:sijentik/component/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dashboardkader.dart';
import 'reports_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'add_report.dart';
import '../auth/login.dart';

class HomeKaderPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomeKaderPage({super.key, required this.user});

  @override
  State<HomeKaderPage> createState() => _HomeKaderPageState();
}

class _HomeKaderPageState extends State<HomeKaderPage> {
  int _selectedIndex = 0;
  
  // Data dummy kader
 
  // Pages untuk bottom navigation
  late final List<Widget> _pages = [
    const DashboardPage(user: {}),
    const ReportsPage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      
      // APPBAR
      appBar: AppBar(
        backgroundColor: AppColors.button,
        elevation: 4,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logodua.png',
              width: 35,
              height: 35,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SI-JENTIK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Kader: ${widget.user['name']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.button, AppColors.button],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
        ),
        actions: [
          // Notifikasi
          IconButton(
            onPressed: () {
              _showNotifications();
            },
            icon: const Icon(Icons.notifications_none),
            color: AppColors.white,
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      // BODY
      body: _pages[_selectedIndex],
      
      // FLOATING ACTION BUTTON (hanya di halaman Laporan)
      floatingActionButton: _selectedIndex == 1 
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF206E97),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddReportPage(),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      
      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF206E97),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined, size: 24),
            activeIcon: Icon(Icons.dashboard, size: 24),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 24),
            activeIcon: Icon(Icons.add_circle, size: 24),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined, size: 24),
            activeIcon: Icon(Icons.history, size: 24),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24),
            activeIcon: Icon(Icons.person, size: 24),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
  
  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Notifikasi'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildNotificationItem(
                  title: 'Laporan Disetujui',
                  message: 'Laporan LP001 telah disetujui petugas',
                  time: '2 jam lalu',
                  isRead: false,
                ),
                _buildNotificationItem(
                  title: 'Reminder Pemeriksaan',
                  message: 'Jadwal pemeriksaan rutin minggu ini',
                  time: '1 hari lalu',
                  isRead: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildNotificationItem({
    required String title,
    required String message,
    required String time,
    required bool isRead,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF206E97).withOpacity(0.1),
        child: Icon(
          Icons.notifications,
          color: const Color(0xFF206E97),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          Text(
            time,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      trailing: !isRead
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
  
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/login', 
                  (route) => false
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}