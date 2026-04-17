import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sijentik/models/report_model.dart';
import 'detail_history_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'Semua';

  final List<String> _filters = ['Semua', 'Menunggu', 'Disetujui', 'Ditolak'];

  List<Report> reports = [];

  bool isLoading = true;

  final String apiUrl = "http://192.168.0.118:8000/api/laporan";

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      print("===== FETCH REPORTS =====");
      print("API URL: $apiUrl");

      final response = await http.get(Uri.parse(apiUrl));

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY:");
      print(response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print("DECODE SUCCESS");
        print("DATA FIELD:");
        print(data['data']);

        List list = data['data'];

        print("TOTAL DATA: ${list.length}");

        setState(() {
          reports = list.map((e) {
            print("MAP DATA:");
            print(e);

            Report report = Report.fromMap(e);

            print("REPORT MODEL:");
            print(report.id);
            print(report.address);
            print(report.status);

            return report;
          }).toList();

          print("TOTAL REPORT MODEL: ${reports.length}");

          isLoading = false;
        });
      } else {
        print("ERROR STATUS CODE: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("ERROR FETCH REPORTS:");
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  List<Report> get filteredReports {
    print("FILTER: $_selectedFilter");

    if (_selectedFilter == 'Semua') return reports;

    return reports.where((report) {
      print("CHECK REPORT STATUS: ${report.status}");
      return report.status == _selectedFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(filter),
                    selectedColor: const Color(0xFF206E97),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    onSelected: (value) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredReports.isEmpty
              ? const Center(
                  child: Text(
                    "Tidak ada riwayat laporan",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];

                    return _buildReportCard(report);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildReportCard(Report report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${report.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF206E97),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: report.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    report.status,
                    style: TextStyle(
                      color: report.statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              report.address,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),

                const SizedBox(width: 4),

                Text(
                  "${report.date.day}-${report.date.month}-${report.date.year}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text("Temuan: ${report.finding}"),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF206E97),
                ),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailHistoryPage(report: report),
                    ),
                  );
                },

                child: const Text(
                  "LIHAT DETAIL",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
