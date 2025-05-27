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
  late ApiService apiService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(baseUrl: 'http://localhost:8000', accessToken: widget.accessToken); // gunakan 10.0.2.2 untuk emulator
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
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching barang: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Tambahkan fungsi ini untuk menangani refresh
  Future<void> _refreshBarang() async {
    await fetchBarang(); // Panggil kembali fungsi fetchBarang
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
                    // Bungkus ListView dengan RefreshIndicator
                    child: RefreshIndicator(
                      onRefresh: _refreshBarang, // Set fungsi _refreshBarang sebagai callback
                      child: ListView(
                        children: barangList.map((barang) => Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: barang.image != null && barang.image!.isNotEmpty
                                ? Image.network(
                                    barang.image!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image);
                                    },
                                  )
                                : const Icon(Icons.image_not_supported),
                            title: Text(barang.nama),
                            subtitle: Text("Kategori: ${barang.categoryName ?? '-'}"),
                            trailing: Text("Stock: ${barang.quantity}"),
                            onTap: () {
                              if (barang.quantity == 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Barang tidak tersedia'),
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
                        )).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

