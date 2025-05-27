import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/peminjaman.dart';
import 'services/api_service.dart';
import 'pengembalian.dart';
import 'peminjaman_detail.dart';

class PeminjamanPage extends StatefulWidget {
  final ApiService apiService;
  const PeminjamanPage({super.key, required this.apiService});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  late Future<List<Peminjaman>> _futurePeminjaman;

  @override
  void initState() {
    super.initState();
    _futurePeminjaman = widget.apiService.fetchRiwayatPeminjaman();
  }

  String formatTanggal(dynamic tanggal) {
    try {
      DateTime date = DateTime.parse(tanggal.toString());
      return DateFormat('dd/MMM/yyyy').format(date);
    } catch (e) {
      return tanggal.toString();
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _futurePeminjaman = widget.apiService.fetchRiwayatPeminjaman();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.indigoAccent,
              child: const Center(
                child: Text(
                  'Peminjaman',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: FutureBuilder<List<Peminjaman>>(
                  future: _futurePeminjaman,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Terjadi kesalahan: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('Belum ada data peminjaman'));
                    }

                    final peminjamanList = snapshot.data!;
                    int? _hoveredIndex;

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: peminjamanList.length,
                            itemBuilder: (context, index) {
                              final item = peminjamanList[index];
                              final isDipinjam =
                                  item.status.toLowerCase() == 'dipinjam';
                              final isdikembalikan =
                                  item.status.toLowerCase() == 'dikembalikan';
                              final ispengembalianditolak =
                                  item.status.toLowerCase() ==
                                      'pengembalian ditolak';
                              final ispeminjamanditolak =
                                  item.status.toLowerCase() ==
                                      'peminjaman ditolak';
                              final iswaitingpeminjaman =
                                  item.status.toLowerCase() ==
                                      'waiting peminjaman';
                              final iswaitingpengembalian =
                                  item.status.toLowerCase() ==
                                      'waiting pengembalian';
                              final warnaKartu =
                                  ispengembalianditolak || ispeminjamanditolak
                                      ? Colors.red.shade100
                                      : (isDipinjam || isdikembalikan
                                          ? Colors.green.shade100
                                          : (iswaitingpengembalian ||
                                                  iswaitingpeminjaman
                                              ? Colors.yellow.shade300
                                              : Colors.white));

                              return MouseRegion(
                                onEnter: (_) {
                                  setState(() {
                                    _hoveredIndex = index;
                                  });
                                },
                                onExit: (_) {
                                  setState(() {
                                    _hoveredIndex = null;
                                  });
                                },
                                child: GestureDetector(
                                  onTap: () async {
                                    if (isDipinjam) {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PengembalianFormPage(
                                            peminjamanId: item.id,
                                            accessToken:
                                                widget.apiService.accessToken,
                                            tanggalPeminjaman: formatTanggal(
                                                item.tanggalPeminjaman),
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        _refreshData();
                                      }
                                    } else if (ispengembalianditolak ||
                                        item.status.toLowerCase() ==
                                            'dikembalikan' ||
                                        ispeminjamanditolak) {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PeminjamanDetailPage(
                                            peminjaman: item,
                                            accessToken:
                                                widget.apiService.accessToken,
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        _refreshData();
                                      }
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: warnaKartu,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Icon(Icons.local_offer_outlined,
                                            color: Colors.grey),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Nama Peminjam: ${item.user?.name ?? 'Unknown'}',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                  'Kelas: ${item.kelasPeminjam}'),
                                              Text('Status: ${item.status}'),
                                              Text(
                                                  'Barang: ${item.barang?.nama ?? 'Unknown'}'),
                                              Text(
                                                  'Alasan: ${item.alasanPeminjam}'),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              formatTanggal(
                                                  item.tanggalPeminjaman),
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          height: 30,
                          alignment: Alignment.center,
                          child: _hoveredIndex != null
                              ? Text(
                                  'Hovering: Nama Peminjam: ${peminjamanList[_hoveredIndex!].user?.name ?? 'Unknown'}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
