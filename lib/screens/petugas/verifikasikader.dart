import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sijentik/component/app_theme.dart';

class VerifikasiKaderPage extends StatefulWidget {
  const VerifikasiKaderPage({super.key});

  @override
  State<VerifikasiKaderPage> createState() => _VerifikasiKaderPageState();
}

class _VerifikasiKaderPageState extends State<VerifikasiKaderPage> {

  List kaderList = [];
  bool isLoadingList = false;

  static const String baseUrl = 'http://192.168.1.6:8000/api';

  @override
  void initState() {
    super.initState();
    fetchKader();
  }

  // =========================
  // FETCH KADER PENDING
  // =========================
  Future<void> fetchKader() async {

    setState(() => isLoadingList = true);

    try {

      final response = await http.get(
        Uri.parse('$baseUrl/kader/pending'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        setState(() {
          kaderList = data['data'];
        });

      } else {

        final data = jsonDecode(response.body);
        _showMessage(data['message'] ?? 'Gagal mengambil data');

      }

    } catch (e) {

      _showMessage('Error: $e');

    } finally {

      setState(() => isLoadingList = false);

    }

  }

  // =========================
  // TERIMA KADER
  // =========================
  Future<void> approveKader(int id) async {

    try {

      final response = await http.post(
        Uri.parse('$baseUrl/kader/approve/$id'),
        headers: {'Accept': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {

        _showMessage(data['message'] ?? 'Kader diterima');
        fetchKader();

      } else {

        _showMessage(data['message'] ?? 'Gagal menerima kader');

      }

    } catch (e) {

      _showMessage('Error: $e');

    }

  }

  // =========================
  // TOLAK KADER
  // =========================
  Future<void> rejectKader(int id) async {

    try {

      final response = await http.post(
        Uri.parse('$baseUrl/kader/reject/$id'),
        headers: {'Accept': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {

        _showMessage(data['message'] ?? 'Kader ditolak');
        fetchKader();

      } else {

        _showMessage(data['message'] ?? 'Gagal menolak kader');

      }

    } catch (e) {

      _showMessage('Error: $e');

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
  // LIST KADER
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
        title: const Text('Verifikasi Kader'),
        backgroundColor: AppColors.button,
      ),

      body: buildKaderList(),

    );

  }
}