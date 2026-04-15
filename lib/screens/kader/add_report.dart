import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sijentik/models/report_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sijentik/api/api.dart';

class AddReportPage extends StatefulWidget {
  const AddReportPage({super.key, required userId});

  @override
  State<AddReportPage> createState() => _AddReportPageState();
}

class _AddReportPageState extends State<AddReportPage> {
  final TextEditingController judulController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();

  bool? adaJentik;
  File? selectedImage;
  DateTime? selectedDate;
  double? latitude;
  double? longitude;
  String? alamat;
  bool isLoading = false;

  final ImagePicker picker = ImagePicker();

  Future<void> simpanLaporan() async {
    if (judulController.text.trim().isEmpty) {
      _showMessage('Judul laporan wajib diisi');
      return;
    }

    if (adaJentik == null) {
      _showMessage('Pilih status jentik');
      return;
    }

    if (selectedDate == null) {
      _showMessage('Tanggal wajib dipilih');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // 🔥 AMBIL TOKEN
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getInt('id'); // 🔥

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/laporan'),
      );

      request.headers['Accept'] = 'application/json';

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // 🔥 TAMBAH INI
      request.fields['user_id'] = userId.toString();

      request.fields['judul'] = judulController.text.trim();
      request.fields['ada_jentik'] = adaJentik! ? '1' : '0';
      request.fields['tanggal'] = DateFormat(
        'yyyy-MM-dd',
      ).format(selectedDate!);
      request.fields['latitude'] = latitude?.toString() ?? '';
      request.fields['longitude'] = longitude?.toString() ?? '';
      request.fields['alamat'] = alamatController.text;

      if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('gambar', selectedImage!.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Map<String, dynamic>? data;
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }

      if (response.statusCode == 201) {
        _showMessage(data?['message'] ?? 'Laporan berhasil disimpan');

        // reset form
        judulController.clear();
        alamatController.clear();
        setState(() {
          adaJentik = null;
          selectedImage = null;
          selectedDate = null;
          latitude = null;
          longitude = null;
          alamat = null;
        });
      } else {
        if (data != null && data['errors'] != null) {
          _showMessage(data['errors'].toString());
        } else {
          _showMessage(data?['message'] ?? 'Gagal menyimpan laporan');
        }
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> ambilLokasi() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return _showMessage('GPS belum aktif');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied)
      permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return _showMessage('Izin lokasi ditolak');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    String alamatLengkap = '';

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        alamatLengkap =
            '${p.street ?? ''}, ${p.subLocality ?? ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''}, ${p.country ?? ''}';
      }
    } catch (_) {}

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      alamat = alamatLengkap;
    });

    _showMessage('Lokasi berhasil diambil');
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => selectedImage = File(image.path));
  }

  Widget buildRadioJentik({
    required bool value,
    required String title,
    required String subtitle,
    required Color iconColor,
    required IconData icon,
  }) {
    return RadioListTile<bool>(
      contentPadding: EdgeInsets.zero,
      value: value,
      groupValue: adaJentik,
      onChanged: (val) => setState(() => adaJentik = val),
      title: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      subtitle: Text(subtitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tanggalText = selectedDate == null
        ? 'Pilih tanggal'
        : DateFormat('dd-MM-yyyy').format(selectedDate!);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan'),
        backgroundColor: const Color(0xFF2D7AA1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: judulController,
              decoration: InputDecoration(
                hintText: 'Judul Laporan',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Apakah terdapat jentik?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            buildRadioJentik(
              value: true,
              title: 'Ya, terdapat jentik',
              subtitle: 'Lokasi ini terdapat jentik nyamuk',
              iconColor: Colors.green,
              icon: Icons.check_circle,
            ),
            buildRadioJentik(
              value: false,
              title: 'Tidak ada jentik',
              subtitle: 'Lokasi ini aman dari jentik nyamuk',
              iconColor: Colors.red,
              icon: Icons.cancel,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: alamatController,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: 'Alamat lengkap',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF2D7AA1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(tanggalText),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: ambilLokasi,
              icon: const Icon(Icons.location_on),
              label: const Text('Ambil Lokasi'),
            ),
            const SizedBox(height: 8),
            if (latitude != null && longitude != null)
              Text(
                'Latitude: $latitude\nLongitude: $longitude\nAlamat: ${alamat ?? '-'}',
              ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF2D7AA1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: selectedImage == null
                    ? const Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 48,
                          color: Color(0xFF2D7AA1),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          selectedImage!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : simpanLaporan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D7AA1),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan Laporan',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
