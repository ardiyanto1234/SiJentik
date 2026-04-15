import 'package:flutter/material.dart';
import 'package:sijentik/component/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sijentik/screens/auth/dashboardService.dart';
import 'package:sijentik/screens/petugas/laporanpetugas.dart';
import 'package:sijentik/screens/petugas/daftarkader.dart';
import 'package:sijentik/screens/petugas/verifikasikader.dart';
import 'package:sijentik/screens/auth/login.dart';

class DashboardPetugas extends StatefulWidget {
  const DashboardPetugas({super.key});

  @override
  State<DashboardPetugas> createState() => _DashboardPetugasState();
}

class _DashboardPetugasState extends State<DashboardPetugas> {
  int _currentIndex = 0;

  Map<String, dynamic> stats = {};
  List<Map<String, dynamic>> recentReports = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await DashboardService.getDashboard();

      if (result == null) {
        setState(() {
          isLoading = false;
          errorMessage = "Gagal mengambil data dashboard.";
        });
        return;
      }

      final rawStats = result['stats'];
      final rawReports = result['recentReports'];

      setState(() {
        stats = rawStats is Map<String, dynamic>
            ? rawStats
            : rawStats is Map
            ? Map<String, dynamic>.from(rawStats)
            : {};

        recentReports = rawReports is List
            ? rawReports
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()
            : [];

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Terjadi kesalahan: $e";
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "diterima":
        return Colors.green;
      case "proses":
        return Colors.orange;
      case "ditolak":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case "diterima":
        return "Selesai";
      case "proses":
        return "Diproses";
      case "ditolak":
        return "Ditolak";
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: AppColors.button,
              centerTitle: true,
              title: const Text(
                "Dashboard Petugas",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardContent(),
          const LaporanPetugasPage(),
          const VerifikasiKaderPage(),
          const DaftarKaderPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDashboardContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: fetchDashboard,
                child: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 20),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildRecentReports(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.button,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.button,
            backgroundImage: AssetImage('assets/images/logo_petugas.png'),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Selamat Datang", style: TextStyle(color: Colors.white)),
                Text(
                  "Petugas Kesehatan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          icon: FontAwesomeIcons.file,
          title: "Total Laporan",
          value: (stats['totalLaporan'] ?? 0).toString(),
          color: Colors.blue,
          subtitle: "Semua laporan",
        ),
        _buildStatCard(
          icon: FontAwesomeIcons.spinner,
          title: "Diproses",
          value: (stats['laporanDiproses'] ?? 0).toString(),
          color: Colors.orange,
          subtitle: "${stats['prosesPercent'] ?? 0}% dari total",
        ),
        _buildStatCard(
          icon: FontAwesomeIcons.check,
          title: "Selesai",
          value: (stats['laporanSelesai'] ?? 0).toString(),
          color: Colors.green,
          subtitle: "${stats['selesaiPercent'] ?? 0}% dari total",
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(icon, color: color),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Laporan Terbaru",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (recentReports.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text("Belum ada laporan")),
          )
        else
          ...recentReports.map((report) => _buildReportCard(report)),
      ],
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final status = (report['status'] ?? '').toString();
    final color = getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          FaIcon(FontAwesomeIcons.clipboardCheck, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Laporan #${(report['id'] ?? '-').toString()}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text((report['judul'] ?? '-').toString()),
                Text(
                  (report['alamat'] ?? '-').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text((report['tanggal'] ?? '').toString()),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  getStatusLabel(status),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.dashboard, "Dashboard", 0),
            _buildNavItem(Icons.list_alt, "Laporan", 1),
            _buildNavItem(Icons.verified_user, "Verifikasi", 2),
            _buildNavItem(Icons.people, "Kader", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: _currentIndex == index ? AppColors.button : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: _currentIndex == index ? AppColors.button : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Keluar"),
        content: const Text("Apakah anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
  }
}
