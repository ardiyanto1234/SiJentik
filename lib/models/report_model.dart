import 'package:flutter/material.dart';

class Report {
  final String id;
  final String judul;
  final String address;
  final String ownerName;
  final DateTime date;

  final String containerType;
  final String finding;

  final String status;

  final String? note;
  final String? notes;

  final String? imageUrl;
  final String? gambar;
  final String? gambarUrl;

  final List<String>? images;

  final String? petugasFeedback;

  final DateTime? inspectionDate;
  final String? inspectorName;

  final double? latitude;
  final double? longitude;

  final String? alamat;
  final bool? adaJentik;

  Report({
    required this.id,
    required this.judul,
    required this.address,
    required this.ownerName,
    required this.date,
    required this.containerType,
    required this.finding,
    this.status = 'Menunggu',
    this.note,
    this.notes,
    this.imageUrl,
    this.images,
    this.petugasFeedback,
    this.inspectionDate,
    this.inspectorName,
    this.latitude,
    this.longitude,
    this.alamat,
    this.gambar,
    this.gambarUrl,
    this.adaJentik,
  });

  Color get statusColor {
    switch (status) {
      case 'Disetujui':
        return Colors.green;

      case 'Ditolak':
        return Colors.red;

      case 'Menunggu':
      default:
        return Colors.orange;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'address': address,
      'ownerName': ownerName,
      'date': date.toIso8601String(),
      'containerType': containerType,
      'finding': finding,
      'status': status,
      'note': note,
      'notes': notes,
      'imageUrl': imageUrl,
      'images': images,
      'petugasFeedback': petugasFeedback,
      'inspectionDate': inspectionDate?.toIso8601String(),
      'inspectorName': inspectorName,
      'latitude': latitude,
      'longitude': longitude,
      'alamat': alamat,
      'gambar': gambar,
      'gambarUrl': gambarUrl,
      'adaJentik': adaJentik,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'].toString(),

      judul: map['judul'] ?? '',

      address: map['alamat'] ?? '',

      ownerName: '',

      date: map['tanggal'] != null
          ? DateTime.parse(map['tanggal'])
          : DateTime.now(),

      containerType: map['judul'] ?? '',

      finding: (map['ada_jentik'] ?? false) ? 'Ada Jentik' : 'Tidak Ada Jentik',

      status: _convertStatus(map['status']),

      notes: map['catatan_petugas'],

      imageUrl: map['gambar_url'],

      images: map['gambar_url'] != null ? [map['gambar_url']] : null,

      latitude: map['latitude'] != null
          ? double.tryParse(map['latitude'].toString())
          : null,

      longitude: map['longitude'] != null
          ? double.tryParse(map['longitude'].toString())
          : null,

      inspectionDate: map['tanggal'] != null
          ? DateTime.parse(map['tanggal'])
          : null,

      inspectorName: 'Petugas',

      alamat: map['alamat'],

      gambar: map['gambar'],

      gambarUrl: map['gambar_url'],

      adaJentik: map['ada_jentik'],
    );
  }

  static String _convertStatus(String? status) {
    switch (status) {
      case "proses":
        return "Menunggu";

      case "diterima":
        return "Disetujui";

      case "ditolak":
        return "Ditolak";

      default:
        return "Menunggu";
    }
  }
}
