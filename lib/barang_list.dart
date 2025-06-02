import 'package:flutter/material.dart';
import 'barang_detail.dart';
import 'models/barang.dart';
import 'services/api_service.dart';

class BarangListWidget extends StatefulWidget {
  final String accessToken;

  const BarangListWidget({super.key, required this.accessToken});

  @override
  State<BarangListWidget> createState() => _BarangListWidgetState();
}

class _BarangListWidgetState extends State<BarangListWidget> {
  List<Barang> barangList = [];
  List<Barang> filteredBarangList = [];
  late ApiService apiService;
  bool _isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    apiService = ApiService(
        baseUrl: 'http://localhost:8000',
        accessToken: widget.accessToken); // gunakan 10.0.2.2 untuk emulator
    fetchBarang();
  }

  Future<void> fetchBarang() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Barang> fetchedBarang = await apiService.fetchBarang();
      setState(() {
        barangList = fetchedBarang;
        filteredBarangList = fetchedBarang; // awalnya semua tampil
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching barang: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshBarang() async {
    await fetchBarang();
  }

  void _filterBarang(String query) {
    setState(() {
      searchQuery = query;
      filteredBarangList = barangList.where((barang) {
        return barang.nama.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.indigoAccent,
              child: const Center(
                child: Text(
                  'Barang',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4), // transparan
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigoAccent),
              ),
              child: TextField(
                onChanged: _filterBarang,
                decoration: const InputDecoration(
                  hintText: 'Cari barang...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
            _isLoading
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshBarang,
                      child: ListView(
                        children: filteredBarangList
                            .map((barang) => Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    leading: barang.image != null &&
                                            barang.image!.isNotEmpty
                                        ? Image.network(
                                            barang.image!,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                  Icons.broken_image);
                                            },
                                          )
                                        : const Icon(Icons.image_not_supported),
                                    title: Text(barang.nama),
                                    subtitle: Text(
                                        "Kategori: ${barang.categoryName ?? '-'}"),
                                    trailing: Text("Stock: ${barang.quantity}"),
                                    onTap: () {
                                      if (barang.quantity == 0) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Barang tidak tersedia'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        return;
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BarangDetailPage(
                                            accessToken: widget.accessToken,
                                            barang: barang,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
