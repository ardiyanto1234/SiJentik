import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sijentik/component/app_theme.dart';

class DaftarKaderPage extends StatefulWidget {
  const DaftarKaderPage({super.key});

  @override
  State<DaftarKaderPage> createState() => _DaftarKaderPageState();
}

class _DaftarKaderPageState extends State<DaftarKaderPage> {
  List<dynamic> kaderList = [];
  bool isLoading = true;

  final String baseUrl = "http://192.168.1.6:8000/api";

  @override
  void initState() {
    super.initState();
    fetchKader();
  }

  Future<void> fetchKader() async {
    final response = await http.get(Uri.parse("$baseUrl/users/kader"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        kaderList = data['data'];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.button,
        title: const Text("Daftar Kader"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kaderList.length,
              itemBuilder: (context, index) {
                final kader = kaderList[index];
                return buildKaderCard(kader);
              },
            ),
    );
  }

  Widget buildKaderCard(dynamic kader) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(kader['name'][0])),

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

                      const SizedBox(height: 4),

                      Text(
                        kader['email'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showEditDialog(kader);
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 5),

                Text("RT/RW : ${kader['rtrw']}"),
              ],
            ),

            const SizedBox(height: 5),

            Text("Alamat : ${kader['address']}"),
          ],
        ),
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
}
