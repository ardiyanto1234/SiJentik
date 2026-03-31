import 'package:flutter/material.dart';
import 'package:sijentik/component/app_theme.dart';

class ReportDetailPage extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback? onProcess;
  final VoidCallback? onComplete;
  final VoidCallback? onClose;

  const ReportDetailPage({
    super.key,
    required this.report,
    this.onProcess,
    this.onComplete,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.button,
        title: Text('Detail Laporan ${report['id']}', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('ID', report['id']),
            _buildRow('Kader', report['kader']),
            _buildRow('Alamat', report['alamat']),
            _buildRow('Tanggal', report['tanggal']),
            _buildRow('Jenis', report['jenis']),
            _buildRow('Status', report['status']),
            _buildRow('Prioritas', report['prioritas']),
            const SizedBox(height: 8),
            const Text('Keterangan', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(report['keterangan'] ?? '-', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            if (report['catatanPetugas'] != null && report['catatanPetugas'].toString().isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    report['status'] == 'Selesai' ? 'Catatan Penyelesaian' : 'Alasan Penolakan',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(report['catatanPetugas'], style: const TextStyle(color: Colors.grey)),
                ],
              ),
            const SizedBox(height: 12),
            Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo, size: 50, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text('Foto Bukti: ${report['id']}.jpg', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (onClose != null) onClose!();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
                const SizedBox(width: 12),
                if (report['status'] == 'Menunggu')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (onProcess != null) onProcess!();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Proses'),
                    ),
                  )
                else if (report['status'] == 'Diproses')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (onComplete != null) onComplete!();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Selesaikan'),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey))),
          Expanded(child: Text(value?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
