import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sijentik/models/report_model.dart';
import 'package:sijentik/component/app_theme.dart';

class DetailHistoryPage extends StatelessWidget {
  final Report report;

  const DetailHistoryPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.button,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Detail Riwayat Laporan',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.button, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // HEADER
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [

                    Text(
                      'ID: ${report.id}',
                      style: AppTextStyles.pageTitle.copyWith(
                        fontSize: 18,
                        color: AppColors.button,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            report.statusColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        report.status,
                        style:
                            AppTextStyles.smallText.copyWith(
                          color: report.statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // INFORMASI UTAMA
            _buildInfoSection(
              title: 'Informasi Utama',
              children: [

                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: 'Tanggal Laporan',
                  value: report.date,
                  labelFontSize: 14,
                ),

                _buildInfoRow(
                  icon: Icons.location_on,
                  label: 'Alamat',
                  value: report.address,
                  labelFontSize: 14,
                ),

              ],
            ),

            const SizedBox(height: 20),

            // DETAIL TEMUAN
            _buildInfoSection(
              title: 'Detail Temuan',
              children: [

                _buildInfoRow(
                  icon: Icons.description,
                  label: 'Judul Laporan',
                  value: report.judul,
                ),

                _buildInfoRow(
                  icon: Icons.search,
                  label: 'Temuan',
                  value: report.finding,
                ),

              ],
            ),

            const SizedBox(height: 20),

            // FOTO
            _buildInfoSection(
              title: 'Foto Laporan',
              children: [

                _buildImageSection(
                  imageUrl: report.imageUrl,
                  images: report.images,
                ),

              ],
            ),

            const SizedBox(height: 20),

            // LOKASI
            _buildInfoSection(
              title: 'Lokasi Pemeriksaan',
              children: [

                _buildLocationSection(
                  latitude: report.latitude,
                  longitude: report.longitude,
                ),

              ],
            ),

            const SizedBox(height: 20),

            // CATATAN PETUGAS
            _buildInfoSection(
              title: 'Catatan Petugas',
              children: [

                Text(
                  report.notes ?? "Tidak ada catatan",
                  style: AppTextStyles.bodyMedium,
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  // INFO SECTION
  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          title,
          style: AppTextStyles.pageTitle.copyWith(
            fontSize: 16,
            color: AppColors.button,
          ),
        ),

        const SizedBox(height: 8),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  // INFO ROW
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required dynamic value,
    double labelFontSize = 12,
    double valueFontSize = 14,
    FontWeight labelFontWeight = FontWeight.w600,
    FontWeight valueFontWeight = FontWeight.w600,
  }) {
    final String displayValue = value is DateTime
        ? '${value.day}/${value.month}/${value.year}'
        : value.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Icon(icon, size: 20, color: AppColors.textGrey),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: labelFontSize,
                    fontWeight: labelFontWeight,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  displayValue,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: valueFontSize,
                    fontWeight: valueFontWeight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // IMAGE SECTION
  Widget _buildImageSection({
    List<String>? images,
    String? imageUrl,
  }) {

    if (images != null && images.isNotEmpty) {

      return SizedBox(
        height: 150,

        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,

          itemBuilder: (context, index) {

            return Container(
              margin: const EdgeInsets.only(right: 8),
              width: 150,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey300),
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImage(images[index]),
              ),
            );
          },
        ),
      );
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildImage(imageUrl, height: 200),
      );
    }

    return Text(
      'Tidak ada foto laporan',
      style: AppTextStyles.smallText,
    );
  }

  // IMAGE BUILDER
  Widget _buildImage(String path, {double height = 150}) {

    return path.startsWith('http')
        ? Image.network(
            path,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imageError(),
          )
        : Image.file(
            File(path),
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imageError(),
          );
  }

  // IMAGE ERROR
  Widget _imageError() {

    return Container(
      color: AppColors.grey100,
      child: const Center(
        child: Icon(
          Icons.broken_image,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  // LOCATION
  Widget _buildLocationSection({
    double? latitude,
    double? longitude,
  }) {

    if (latitude == null || longitude == null) {

      return Text(
        'Lokasi tidak tersedia',
        style: AppTextStyles.smallText,
      );
    }

    return Column(
      children: [

        _buildInfoRow(
          icon: Icons.location_on,
          label: 'Latitude',
          value: latitude.toStringAsFixed(6),
        ),

        _buildInfoRow(
          icon: Icons.location_on,
          label: 'Longitude',
          value: longitude.toStringAsFixed(6),
        ),

      ],
    );
  }
}