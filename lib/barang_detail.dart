import 'package:flutter/material.dart';
import 'models/barang.dart';
import 'services/api_service.dart';
import 'peminjaman_create.dart';

class BarangDetailPage extends StatelessWidget {
  final Barang barang;
  final String accessToken;

  const BarangDetailPage({super.key, required this.barang, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              color: Colors.blueAccent,
              child: const Text(
                "Detail Barang",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
                children: [
                  barang.image != null
                      ? Image.network(
                          barang.image!,
                          height: 150,
                          width: double.infinity, // Make image take full width
                          fit: BoxFit.contain, // Use BoxFit.contain
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image);
                          },
                        )
                      : Container(
                          height: 150,
                          width: double.infinity, // Make container take full width
                          color: Colors.grey[300],
                          child: const Center(child: Text("No Image")),
                        ),
                  const SizedBox(height: 12),
                  Text(barang.nama, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Kondisi: ${barang.kondisi}"),
                  Text("Kategori: ${barang.categoryName ?? '-'}"),
                  const SizedBox(height: 8),
                  Text(
                    "Stock Tersedia: ${barang.quantity}",
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 20),
                  if (barang.quantity <= 0) // Check if stock is 0 or less
                    const Text(
                      "Barang Tidak Bisa Dipinjam (Stok Habis)",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        final apiService = ApiService(
                          baseUrl: 'http://localhost:8000',
                          accessToken: accessToken,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PeminjamanCreatePage(apiService: apiService),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        elevation: 4,
                      ),
                      child: const Text("Ke Form Peminjaman", style: TextStyle(color: Colors.black)),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

