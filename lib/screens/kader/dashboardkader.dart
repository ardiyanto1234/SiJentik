import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sijentik/api/api.dart';
import 'package:sijentik/component/app_theme.dart';
import 'history_page.dart';
import 'add_report.dart';
import 'reports_page.dart';
import 'profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String address = '';

  Map<String, dynamic>? dashboardData;

  // 🔥 TAMBAHKAN INI
  List<dynamic> recentReports = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchDashboard();
    fetchRecentReports();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      address = prefs.getString('address') ?? '';
    });
  }

  Future<void> fetchDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    print("ID DARI STORAGE: $userId");

    if (userId == null) {
      print("ID NULL DARI STORAGE ❌");
      return;
    }

    final response = await http.get(
      Uri.parse('http://192.168.1.6:8000/api/dashboard/$userId'),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        dashboardData = data;
      });
    }
  }

  Future<void> fetchRecentReports() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    if (userId == null) return;

    final response = await http.get(Uri.parse('$baseUrl/laporan/user/$userId'));

    print("RECENT STATUS: ${response.statusCode}");
    print("RECENT BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        recentReports = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = dashboardData?['stats'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER (GRADIENT) =====
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF206E97), Color(0xFF4BA3C3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat Datang 👋',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.user['name'] ?? 'Kader',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Wilayah: ${dashboardData?['user']['wilayah'] ?? '-'}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Total Laporan: ${stats?['total_laporan'] ?? 0}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ===== STATISTIK =====
          const Text(
            "Statistik Laporan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildStatCard(
                title: 'Total',
                value: '${stats?['total_laporan'] ?? 0}',
                icon: Icons.assignment,
                color: Colors.blue,
              ),
              _buildStatCard(
                title: 'Disetujui',
                value: '${stats?['disetujui'] ?? 0}',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              _buildStatCard(
                title: 'Menunggu',
                value: '${stats?['menunggu'] ?? 0}',
                icon: Icons.schedule,
                color: Colors.orange,
              ),
              _buildStatCard(
                title: 'Ditolak',
                value: '${stats?['ditolak'] ?? 0}',
                icon: Icons.cancel,
                color: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 25),

          // ===== PROGRESS =====
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: (stats?['persentase_disetujui'] ?? 0) / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF206E97),
                        ),
                      ),
                    ),
                    Text(
                      '${stats?['persentase_disetujui'] ?? 0}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Text(
                    "Persentase laporan yang telah disetujui",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          recentReports.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Belum ada laporan",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : Column(
                  children: recentReports.map((report) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.home, color: Colors.blue),

                        // 🔥 FIX FIELD DARI API
                        title: Text(report['judul'] ?? '-'),
                        subtitle: Text(report['alamat'] ?? '-'),

                        trailing: _buildStatusBadge(report['status']),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;

    switch (status) {
      case 'diterima':
        color = Colors.green;
        break;
      case 'proses':
        color = Colors.orange;
        break;
      case 'ditolak':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status ?? '-',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
