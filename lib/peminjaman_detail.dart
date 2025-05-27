import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/peminjaman.dart';
import 'models/pengembalian.dart';
import 'services/api_service.dart';
import 'pengembalian.dart';

class PeminjamanDetailPage extends StatefulWidget {
  final Peminjaman peminjaman;
  final String accessToken;

  const PeminjamanDetailPage({
    Key? key,
    required this.peminjaman,
    required this.accessToken,
  }) : super(key: key);

  @override
  _PeminjamanDetailPageState createState() => _PeminjamanDetailPageState();
}

class _PeminjamanDetailPageState extends State<PeminjamanDetailPage> {
  late Future<Pengembalian?> _futurePengembalian;

  @override
  void initState() {
    super.initState();
    final apiService = ApiService(
      baseUrl: 'http://localhost:8000',
      accessToken: widget.accessToken,
    );

    if (widget.peminjaman.status.toLowerCase() == 'dikembalikan') {
      _futurePengembalian = apiService
          .fetchDetailPengembalian(widget.peminjaman.id)
          .then((value) => value)
          .catchError((e) {
        print("Error di catchError: $e");
        return null; // karena tipe nya Future<Pengembalian?>
      });
    } else {
      _futurePengembalian = Future.value(null); // fallback biar tidak error
    }
  }

  String formatTanggal(dynamic date) {
    if (date is DateTime) {
      return DateFormat('dd/MMM/yyyy').format(date);
    } else if (date is String) {
      try {
        DateTime parsedDate = DateTime.parse(date);
        return DateFormat('dd/MMM/yyyy').format(parsedDate);
      } catch (e) {
        return date;
      }
    } else {
      return date.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peminjaman.status.toLowerCase() == 'dikembalikan'
            ? 'Detail Pengembalian'
            : 'Detail Peminjaman'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Nama Peminjam: ${widget.peminjaman.user?.name ?? 'Unknown'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Kelas: ${widget.peminjaman.kelasPeminjam}'),
            Text('Status: ${widget.peminjaman.status}'),
            Text('Barang: ${widget.peminjaman.barang?.nama ?? 'Unknown'}'),
            Text('Alasan: ${widget.peminjaman.alasanPeminjam}'),
            Text(
                'Tanggal Peminjaman: ${formatTanggal(widget.peminjaman.tanggalPeminjaman)}'),
            const SizedBox(height: 8),
            // <- garis pemisah
          
            if (widget.peminjaman.status.toLowerCase() ==
                    'peminjaman ditolak' &&
                widget.peminjaman.alasanPenolakan != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Alasan Penolakan: ${widget.peminjaman.alasanPenolakan}',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              )
            else if (widget.peminjaman.status.toLowerCase() ==
                    'pengembalian ditolak' &&
                widget.peminjaman.alasanPenolakan != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Alasan Penolakan: ${widget.peminjaman.alasanPenolakan}',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),

            

            

            const SizedBox(height: 16),
            if (widget.peminjaman.status.toLowerCase() ==
                'pengembalian ditolak')
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PengembalianFormPage(
                        peminjamanId: widget.peminjaman.id,
                        accessToken: widget.accessToken,
                        tanggalPeminjaman:
                            formatTanggal(widget.peminjaman.tanggalPeminjaman),
                      ),
                    ),
                  );
                  if (result == true) {
                    Navigator.of(context).pop(true);
                  }
                },
                child: const Text('Ajukan Pengembalian Ulang'),
              ),

            if (widget.peminjaman.status.toLowerCase() == 'dikembalikan')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(), // <- garis pemisah sebelum detail pengembalian
                  FutureBuilder<Pengembalian?>(
                    future: _futurePengembalian,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text(
                            'Gagal memuat detail pengembalian: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Text('Detail pengembalian tidak tersedia');
                      }

                      final pengembalian = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Pengembalian',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Kondisi Barang: ${pengembalian.kondisiBarang}'),
                          Text(
                              'Tanggal Dikembalikan: ${formatTanggal(pengembalian.tanggalDikembalikan)}'),
                          const SizedBox(height: 8),
                          pengembalian.imageBukti != null
                              ? Image.network(
                                  'http://localhost:8000/storage/${pengembalian.imageBukti!}',
                                  width: 150,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                              : const Text('Tidak ada bukti gambar'),
                          const SizedBox(height: 16),
                          if (pengembalian.denda != null &&
                              pengembalian.dendaId != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(), // <- garis pemisah sebelum detail denda
                                const Text(
                                  'Detail Denda',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                ),
                                const SizedBox(height: 8),
                                Text('Nama: ${pengembalian.denda!.name}'),
                                Text(
                                    'Deskripsi: ${pengembalian.denda!.description}'),
                                Builder(
                                  builder: (context) {
                                    String nominalRaw =
                                        pengembalian.denda!.nominal.trim();
                                    String normalized =
                                        nominalRaw.replaceAll(',', '.');
                                    double nominalValue =
                                        double.tryParse(normalized) ?? 0.0;
                                    String formattedNominal =
                                        NumberFormat.currency(
                                      locale: 'id_ID',
                                      symbol: 'Rp',
                                      decimalDigits: 0,
                                    ).format(nominalValue);

                                    return Text('Nominal: $formattedNominal');
                                  },
                                ),
                                const SizedBox(height: 16,),
                                const Text(
                                  'Untuk Pembayaran Silahkan Ke Ruang Tata Usaha',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                  ),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
