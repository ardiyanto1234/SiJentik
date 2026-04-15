import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sijentik/api/api.dart' as Api;
import 'package:sijentik/component/app_theme.dart';
import 'package:sijentik/api/api.dart';

class VerifikasiKaderPage extends StatefulWidget {
  const VerifikasiKaderPage({super.key});

  @override
  State<VerifikasiKaderPage> createState() => _VerifikasiKaderPageState();
}

class _VerifikasiKaderPageState extends State<VerifikasiKaderPage> {
  List kaderList = [];
  bool isLoadingList = false;

  @override
  void initState() {
    super.initState();
    fetchKader();
  }

  // FETCH KADER

  Future<void> fetchKader() async {
    if (!mounted) return;
    setState(() => isLoadingList = true);

    try {
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/kader/pending"),
        headers: {'Accept': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          kaderList = data['data'];
        });
      } else {
        _showMessage(data['message'] ?? 'Gagal mengambil data', success: false);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Error: $e', success: false);
    } finally {
      if (!mounted) return;
      setState(() => isLoadingList = false);
    }
  }

  // APPROVE

  Future<void> approveKader(int id) async {
    try {
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/kader/approve/$id"),
        headers: {'Accept': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showMessage(data['message'] ?? 'Kader diterima');
        fetchKader();
      } else {
        _showMessage(data['message'] ?? 'Gagal menerima kader', success: false);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Error: $e', success: false);
    }
  }

  // =========================
  // REJECT
  // =========================
  Future<void> rejectKader(int id) async {
    try {
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/kader/reject/$id"),
        headers: {'Accept': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showMessage(data['message'] ?? 'Kader ditolak');
        fetchKader();
      } else {
        _showMessage(data['message'] ?? 'Gagal menolak kader', success: false);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Error: $e', success: false);
    }
  }

  // =========================
  // MESSAGE (ANTI ERROR)
  // =========================
  void _showMessage(String message, {bool success = true}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // =========================
  // UI LIST
  // =========================
  Widget buildKaderList() {
    if (isLoadingList) {
      return const Center(child: CircularProgressIndicator());
    }

    if (kaderList.isEmpty) {
      return const Center(child: Text('Tidak ada kader menunggu verifikasi'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: kaderList.length,
      itemBuilder: (context, index) {
        final kader = kaderList[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kader['name'] ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Email: ${kader['email'] ?? '-'}'),
                Text('RT/RW: ${kader['rtrw'] ?? '-'}'),
                const SizedBox(height: 6),
                Text('Alamat: ${kader['address'] ?? '-'}'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () => approveKader(kader['id']),
                        child: const Text(
                          'Terima',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => rejectKader(kader['id']),
                        child: const Text(
                          'Tolak',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verifikasi Kader',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),

        backgroundColor: AppColors.button,
      ),
      body: buildKaderList(),
    );
  }
}
