import 'package:flutter/material.dart';
import 'package:sijentik/component/app_theme.dart';
import 'package:sijentik/models/report_model.dart';

class VerifikasiKaderDetailPage extends StatelessWidget {
  final Map<String, dynamic> kader;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const VerifikasiKaderDetailPage({
    super.key,
    required this.kader,
    required this.onAccept,
    required this.onReject,
  });

  void _confirmAccept(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Terima Kader"),
          content: const Text(
              "Apakah anda yakin ingin menerima kader ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onAccept();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text("Terima"),
            ),
          ],
        );
      },
    );
  }

  void _confirmReject(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tolak Kader"),
          content: const Text(
              "Apakah anda yakin ingin menolak kader ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onReject();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Tolak"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.button,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Detail Verifikasi',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.button,
                  child: Text(
                    kader['nama'] != null
                        ? kader['nama']!
                            .toString()
                            .split(' ')
                            .map((e) => e[0])
                            .join()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        kader['nama'] ?? '-',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${kader['id'] ?? '-'}',
                        style:
                            const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            TextFormField(
              initialValue: kader['nama'] ?? '-',
              readOnly: true,
              decoration: _buildInputDecoration('Nama'),
            ),

            const SizedBox(height: 12),

            TextFormField(
              initialValue:
                  kader['rt'] ?? kader['wilayah'] ?? '-',
              readOnly: true,
              decoration: _buildInputDecoration('RT'),
            ),

            const SizedBox(height: 12),

            TextFormField(
              initialValue: kader['email'] ?? '-',
              readOnly: true,
              decoration: _buildInputDecoration('Email'),
            ),

            const SizedBox(height: 12),

            TextFormField(
              initialValue: kader['alamat'] ?? '-',
              readOnly: true,
              maxLines: 3,
              decoration: _buildInputDecoration(
                'Alamat lengkap',
                alignTop: true,
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            const Text(
              'Keterangan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              kader['keterangan'] ??
                  'Tidak ada keterangan tambahan.',
            ),

            const SizedBox(height: 16),

            Row(
              children: [

                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _confirmReject(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Tolak'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmAccept(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Terima'),
                  ),
                ),

              ],
            ),

          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label,
      {bool alignTop = false}) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      alignLabelWithHint: alignTop,
      isDense: true,
    );
  }
}