import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LaporanPetugasPage extends StatefulWidget {
  const LaporanPetugasPage({super.key});

  @override
  State<LaporanPetugasPage> createState() => _LaporanPetugasPageState();
}

class _LaporanPetugasPageState extends State<LaporanPetugasPage> {
  static const String baseUrl = 'http://192.168.1.6:8000/api';

  List<dynamic> laporanList = [];
  bool isLoading = false;

  String _filterStatus = 'Semua';

  final List<String> _statusList = ['Semua', 'proses', 'diterima', 'ditolak'];

  @override
  void initState() {
    super.initState();
    fetchLaporan();
  }

  // =========================
  // GET LAPORAN
  // =========================
  Future<void> fetchLaporan() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse('$baseUrl/laporan'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          laporanList = data['data'];
        });
      } else {
        _showMessage('Gagal mengambil data', success: false);
      }
    } catch (e) {
      _showMessage('Error: $e', success: false);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // =========================
  // UPDATE STATUS
  // =========================
  Future<void> updateStatus(int id, String status, {String? catatan}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/laporan/$id/status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'status': status,
          if (catatan != null) 'catatan_petugas': catatan,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showMessage(data['message']);
        fetchLaporan();
      } else {
        _showMessage(data['message'] ?? 'Gagal update status', success: false);
      }
    } catch (e) {
      _showMessage('Error: $e', success: false);
    }
  }

  // =========================
  // MESSAGE
  // =========================
  void _showMessage(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // =========================
  // FILTER
  // =========================
  List<dynamic> get filteredLaporan {
    if (_filterStatus == 'Semua') return laporanList;

    return laporanList.where((lap) {
      return lap['status'] == _filterStatus;
    }).toList();
  }

  // =========================
  // STATUS COLOR
  // =========================
  Color getStatusColor(String status) {
    switch (status) {
      case 'proses':
        return Colors.orange;

      case 'diterima':
        return Colors.green;

      case 'ditolak':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // =========================
  // UPDATE STATUS DIALOG
  // =========================
  void showUpdateDialog(dynamic lap, String newStatus) {
    final TextEditingController noteController = TextEditingController();

    bool needNote = newStatus == 'ditolak';

    if (!needNote) {
      updateStatus(lap['id'], newStatus);
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Catatan Penolakan'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Masukkan catatan...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              updateStatus(lap['id'], newStatus, catatan: noteController.text);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // =========================
  // DETAIL LAPORAN
  // =========================
  void showDetailDialog(dynamic lap) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Detail Laporan ${lap['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Judul: ${lap['judul'] ?? '-'}'),
              Text(
                'Tanggal: ${lap['tanggal'] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(lap['tanggal'])) : '-'}',
              ),
              Text('Alamat: ${lap['alamat'] ?? '-'}'),
              Text('Status: ${lap['status'] ?? '-'}'),

              if (lap['catatan_petugas'] != null &&
                  lap['catatan_petugas'].isNotEmpty)
                Text('Catatan: ${lap['catatan_petugas']}'),

              if (lap['gambar_url'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Image.network(
                    lap['gambar_url'],
                    height: 150,
                    fit: BoxFit.cover,
                  ),
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
      ),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Petugas'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // FILTER STATUS
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _statusList.length,
              itemBuilder: (context, index) {
                final status = _statusList[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: _filterStatus == status,
                    onSelected: (_) {
                      setState(() {
                        _filterStatus = status;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredLaporan.length,
                    itemBuilder: (context, index) {
                      final lap = filteredLaporan[index];

                     return Card(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  child: Padding(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// HEADER
        Row(
          children: [
            const Icon(
              Icons.report_problem,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),

            Expanded(
              child: Text(
                lap['judul'] ?? '-',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: getStatusColor(lap['status']).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                lap['status'],
                style: TextStyle(
                  color: getStatusColor(lap['status']),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),

        const SizedBox(height: 10),

        /// ALAMAT
        Row(
          children: [
            const Icon(Icons.location_on, size: 18, color: Colors.grey),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                lap['alamat'] ?? '-',
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        /// TANGGAL
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
            const SizedBox(width: 6),
            Text(
              lap['tanggal'] != null
                  ? DateFormat('dd MMM yyyy')
                      .format(DateTime.parse(lap['tanggal']))
                  : '-',
            ),
          ],
        ),

        /// GAMBAR
        if (lap['gambar_url'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                lap['gambar_url'],
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

        const SizedBox(height: 12),

        /// BUTTON ACTION
        Row(
          children: [

            /// PROSES
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => showUpdateDialog(lap, 'proses'),
                icon: const Icon(Icons.sync),
                label: const Text("Proses"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 6),

            /// TERIMA
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => showUpdateDialog(lap, 'diterima'),
                icon: const Icon(Icons.check),
                label: const Text("Terima"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 6),

            /// TOLAK
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => showUpdateDialog(lap, 'ditolak'),
                icon: const Icon(Icons.close),
                label: const Text("Tolak"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        /// DETAIL BUTTON
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => showDetailDialog(lap),
            icon: const Icon(Icons.visibility),
            label: const Text("Lihat Detail"),
          ),
        )
      ],
    ),
  ),
); 
                    },
          ),
          ),
        ],
      ),
    );
  }
}
