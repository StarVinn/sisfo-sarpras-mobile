class User {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id']),
      name: json['name'],
      email: json['email'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class Barang {
  final int id;
  final String nama;
  final int quantity;
  final String kondisi;
  final String? image;
  final String? categoryName;

  Barang({
    required this.id,
    required this.nama,
    required this.quantity,
    required this.kondisi,
    this.image,
    this.categoryName,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'] is int ? json['id'] : int.parse(json['id']),
      nama: json['nama'],
      quantity: json['quantity'] is int ? json['quantity'] : int.parse(json['quantity']),
      kondisi: json['kondisi'],
      image: json['image'],
      categoryName: json['category_name'],
    );
  }
}

class Peminjaman {
  final int id;
  final int userId;
  final int barangId;
  final String kelasPeminjam;
  final String alasanPeminjam;
  final DateTime tanggalPeminjaman;
  final String status;
  final User user;
  final Barang barang;

  Peminjaman({
    required this.id,
    required this.userId,
    required this.barangId,
    required this.kelasPeminjam,
    required this.alasanPeminjam,
    required this.tanggalPeminjaman,
    required this.status,
    required this.user,
    required this.barang,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      id: json['id'] is int ? json['id'] : int.parse(json['id']),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id']),
      barangId: json['barang_id'] is int ? json['barang_id'] : int.parse(json['barang_id']),
      kelasPeminjam: json['kelas_peminjam'],
      alasanPeminjam: json['alasan_peminjam'],
      tanggalPeminjaman: DateTime.parse(json['tanggal_peminjaman']),
      status: json['status'],
      user: User.fromJson(json['user']),
      barang: Barang.fromJson(json['barang']),
    );
  }
}
