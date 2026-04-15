import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sijentik/component/app_theme.dart';
import 'package:sijentik/screens/auth/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool isLoading = true;

  // ==========================
  // GET PROFILE
  // ==========================
  Future getProfile() async {
    final response = await http.get(
      Uri.parse("http://192.168.1.6:8000/api/profile"),
      headers: {"Accept": "application/json"},
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        user = data['user'];
        isLoading = false;
      });
    } else {
      print("Error API");
    }
  }

  // ==========================
  // PICK IMAGE
  // ==========================
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imageFile = picked;
      });

      uploadPhoto();
    }
  }

  // ==========================
  // UPLOAD PHOTO
  // ==========================
  Future uploadPhoto() async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("http://192.168.1.6:8000/api/upload-photo"),
    );

    request.headers['Accept'] = 'application/json';

    request.fields['user_id'] = user!['id'].toString();

    request.files.add(
      await http.MultipartFile.fromPath('profile_photo', _imageFile!.path),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        _imageFile = null; // reset biar ambil dari server
      });
      getProfile();
    }
  }

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  // 🔥 Tambahan supaya refresh saat balik ke halaman ini
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ======================
          // HEADER PROFILE
          // ======================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.button, AppColors.button],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // PHOTO
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: _imageFile != null
                      ? FileImage(File(_imageFile!.path))
                      : user!['photo_url'] != null
                          // 🔥 CACHE BUSTER DI SINI
                          ? NetworkImage(
                              user!['photo_url'] +
                                  "?t=${DateTime.now().millisecondsSinceEpoch}",
                            )
                          : null,
                  child: user!['photo_url'] == null && _imageFile == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),

                const SizedBox(height: 12),

                Text(
                  user!['name'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  user!['role'],
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Ubah Foto"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF206E97),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ======================
          // DETAIL PROFILE
          // ======================
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text("Email"),
                  subtitle: Text(user!['email']),
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text("Alamat"),
                  subtitle: Text(user!['address'] ?? "-"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ======================
          // LOGOUT
          // ======================
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}