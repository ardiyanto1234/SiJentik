import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sijentik/component/app_theme.dart';
import 'package:sijentik/api/api.dart';

class DaftarKaderPage extends StatefulWidget {
  const DaftarKaderPage({super.key});

  @override
  State<DaftarKaderPage> createState() => _DaftarKaderPageState();
}

class _DaftarKaderPageState extends State<DaftarKaderPage> {
  List<dynamic> kaderList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchKader();
  }

  Future<void> fetchKader() async {
    final response = await http.get(Uri.parse("$baseUrl/users/kader"));

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        kaderList = data['data'];
        isLoading = false;
      });
    }
  }

  Future<void> deleteKader(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/users/$id"));

    if (response.statusCode == 200) {
      fetchKader();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Kader berhasil dihapus")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal menghapus kader")));
    }
  }

  void showDeleteDialog(dynamic kader) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Hapus Kader"),
        content: Text("Yakin ingin menghapus ${kader['name']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await deleteKader(kader['id']);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void showEditDialog(dynamic kader) {
    TextEditingController name = TextEditingController(text: kader['name']);
    TextEditingController email = TextEditingController(text: kader['email']);
    TextEditingController address = TextEditingController(
      text: kader['address'],
    );
    TextEditingController rtrw = TextEditingController(text: kader['rtrw']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Edit Data Kader"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: "Nama"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: address,
                decoration: const InputDecoration(labelText: "Alamat"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: rtrw,
                decoration: const InputDecoration(labelText: "RT/RW"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await http.put(
                Uri.parse("$baseUrl/users/${kader['id']}"),
                body: {
                  "name": name.text,
                  "email": email.text,
                  "address": address.text,
                  "rtrw": rtrw.text,
                },
              );

              Navigator.pop(context);
              fetchKader();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data berhasil diperbarui")),
              );
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Widget buildKaderCard(dynamic kader) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.button,
                child: ClipOval(
                  child:
                      kader['profile_photo'] != null &&
                          kader['profile_photo'].toString().isNotEmpty
                      ? Image.network(
                          baseImageurl + kader['profile_photo'],
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print("ERROR IMAGE: $error");
                            return Text(
                              kader['name'][0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            );
                          },
                        )
                      : Text(
                          kader['name'][0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kader['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      kader['email'],
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => showEditDialog(kader),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => showDeleteDialog(kader),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.home, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text("RT/RW: ${kader['rtrw']}"),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  kader['address'],
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.button,
        title: const Text(
          "Daftar Kader",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.button,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: Text(
                    "Total Kader: ${kaderList.length}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: kaderList.length,
                    itemBuilder: (context, index) {
                      return buildKaderCard(kaderList[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
