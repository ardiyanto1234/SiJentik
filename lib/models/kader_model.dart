class Kader {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String area;
  final DateTime joinDate;
  final int totalReports;

  Kader({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.area,
    required this.joinDate,
    this.totalReports = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'area': area,
      'joinDate': joinDate.toIso8601String(),
      'totalReports': totalReports,
    };
  }

  factory Kader.fromMap(Map<String, dynamic> map) {
    return Kader(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      area: map['area'],
      joinDate: DateTime.parse(map['joinDate']),
      totalReports: map['totalReports'] ?? 0,
    );
  }
}