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
  List<Peminjaman> _allPeminjaman = []; // simpan semua data asli
  List<Peminjaman> _filteredPeminjaman = [];

  String _filterNama = '';
  String _filterStatus = 'Semua';
  DateTime? _filterTanggal;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _futurePeminjaman = widget.apiService.fetchRiwayatPeminjaman();
    final data = await _futurePeminjaman;
    setState(() {
      _allPeminjaman = data;
      _filterData();
    });
  }

  String formatTanggal(dynamic tanggal) {
    try {
      DateTime date = DateTime.parse(tanggal.toString());
      return DateFormat('dd/MMM/yyyy').format(date);
    } catch (e) {
      return tanggal.toString();
    }
  }

  // Filter tanpa parameter, filter berdasarkan state filter saat ini
  void _filterData() {
    setState(() {
      _filteredPeminjaman = _allPeminjaman.where((item) {
        final matchNama = _filterNama.isEmpty ||
            (item.user?.name ?? '')
                .toLowerCase()
                .contains(_filterNama.toLowerCase());

        final matchStatus = _filterStatus == 'Semua' ||
            item.status.toLowerCase() == _filterStatus.toLowerCase();

        final matchTanggal = _filterTanggal == null ||
            (DateTime.parse(item.tanggalPeminjaman.toString()).year ==
                    _filterTanggal!.year &&
                DateTime.parse(item.tanggalPeminjaman.toString()).month ==
                    _filterTanggal!.month &&
                DateTime.parse(item.tanggalPeminjaman.toString()).day ==
                    _filterTanggal!.day);

        return matchNama && matchStatus && matchTanggal;
      }).toList();
    });
  }

  Future<void> _refreshData() async {
    final data = await widget.apiService.fetchRiwayatPeminjaman();
    setState(() {
      _allPeminjaman = data;
      _filterData();
    });
  }

  Future<void> _selectTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _filterTanggal ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _filterTanggal = picked;
      });
      _filterData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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

            // Filter Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Filter Nama
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Filter Nama ',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _filterNama = value;
                            _filterData();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Filter Status
                      DropdownButton<String>(
                        value: _filterStatus,
                        items: <String>[
                          'Semua',
                          'Dipinjam',
                          'Dikembalikan',
                          'Waiting Peminjaman',
                          'Waiting Pengembalian',
                          'Pengembalian Ditolak',
                          'Peminjaman Ditolak'
                        ].map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _filterStatus = value;
                            _filterData();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Filter Tanggal
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _filterTanggal != null
                              ? 'Tanggal: ${DateFormat('dd/MM/yyyy').format(_filterTanggal!)}'
                              : 'Pilih Tanggal',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectTanggal(context),
                        child: const Text('Pilih Tanggal'),
                      ),
                      if (_filterTanggal != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _filterTanggal = null;
                              _filterData();
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Data List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: _allPeminjaman.isEmpty
                    ? const Center(child: Text('Tidak ada Riwayat Peminjaman'))
                    : _filteredPeminjaman.isEmpty
                        ? const Center(
                            child: Text('Tidak ada data sesuai filter'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _filteredPeminjaman.length,
                            itemBuilder: (context, index) {
                              final item = _filteredPeminjaman[index];
                              final warnaKartu = (() {
                                final status = item.status.toLowerCase();
                                if (status == 'waiting peminjaman' ||
                                    status == 'waiting pengembalian') {
                                  return Colors.yellow.shade100;
                                } else if (status == 'dipinjam' ||
                                    status == 'dikembalikan') {
                                  return Colors.green.shade100;
                                } else if (status == 'peminjaman ditolak' ||
                                    status == 'pengembalian ditolak') {
                                  return Colors.red.shade100;
                                }
                                // Default warna kalau status lain
                                return Colors.grey.shade200;
                              })();


                              return GestureDetector(
                                onTap: () async {
                                  if (item.status.toLowerCase() == 'dipinjam') {
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
                                  } else {
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nama: ${item.user?.name ?? 'Unknown'}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text('Status: ${item.status}'),
                                      Text('Barang: ${item.barang?.nama ?? 'Tidak ada Nama Barang'}'),
                                      Text(
                                          'Tanggal: ${formatTanggal(item.tanggalPeminjaman)}'),
                                    ],
                                  ),
                                ),
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
