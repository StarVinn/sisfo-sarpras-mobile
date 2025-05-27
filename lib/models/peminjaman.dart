import 'models.dart';

class Peminjaman {
  final int id;
  final int userId;
  final int barangId;
  final String kelasPeminjam;
  final String alasanPeminjam;
  final String? alasanPenolakan;
  final DateTime tanggalPeminjaman;
  final String status;
  final User? user;
  final Barang? barang;

  Peminjaman({
    required this.id,
    required this.userId,
    required this.barangId,
    required this.kelasPeminjam,
    required this.alasanPeminjam,
    this.alasanPenolakan,
    required this.tanggalPeminjaman,
    required this.status,
    this.user,
    this.barang,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      barangId: int.parse(json['barang_id'].toString()),
      kelasPeminjam: json['kelas_peminjam'],
      alasanPeminjam: json['alasan_peminjam'],
      alasanPenolakan: json['alasan_penolakan'],
      tanggalPeminjaman: DateTime.parse(json['tanggal_peminjaman']),
      status: json['status'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      barang: json['barang'] != null ? Barang.fromJson(json['barang']) : null,
    );
  }
}
