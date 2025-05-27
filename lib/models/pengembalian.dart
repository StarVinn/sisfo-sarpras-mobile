import 'peminjaman.dart';
import 'denda.dart';

class Pengembalian {
  final int id;
  final int peminjamanId;
  final int? dendaId;
  final String kondisiBarang;
  final String tanggalDikembalikan;
  final String? imageBukti;
  final Peminjaman peminjaman;
  final Denda? denda;

  Pengembalian({
    required this.id,
    required this.peminjamanId,
    this.dendaId,
    required this.kondisiBarang,
    required this.tanggalDikembalikan,
    this.imageBukti,
    required this.peminjaman,
    this.denda,
  });

  factory Pengembalian.fromJson(Map<String, dynamic> json) {
    return Pengembalian(
      id: json['id'],
      peminjamanId: json['peminjaman_id'],
      dendaId: json['denda_id'],
      kondisiBarang: json['kondisi_barang'],
      tanggalDikembalikan: json['tanggal_dikembalikan'],
      imageBukti: json['image_bukti'],
      peminjaman: Peminjaman.fromJson(json['peminjaman']),
      denda: json['denda'] != null ? Denda.fromJson(json['denda']) : null,
    );
  }
}
