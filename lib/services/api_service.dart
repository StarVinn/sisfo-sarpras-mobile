import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/barang.dart';
import '../models/peminjaman.dart';
import '../models/pengembalian.dart';
import 'dart:typed_data';


class ApiService {
  final String baseUrl;
  final String accessToken;

  ApiService({required this.baseUrl, required this.accessToken});

  Map<String, String> get headers => {
    'Authorization': 'Bearer $accessToken',
    'Accept': 'application/json',
    'Access-Control-Allow-Origin': '*',
  };

  Future<Map<String, dynamic>> fetchHomeData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/home'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load home data: ${response.statusCode}');
    }
  }
  /// ✅ Barang
  Future<List<Barang>> fetchBarang() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/barang'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      List<dynamic> jsonList = decoded['data'];
      return jsonList.map((json) => Barang.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load barang: ${response.body}');
    }
  }

  /// ✅ Riwayat Peminjaman
  Future<List<Peminjaman>> fetchRiwayatPeminjaman() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/peminjaman/riwayat'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      print ('Response: ${response.body}');
      // Adjusted to parse raw list without 'data' key
      List<dynamic> jsonList = decoded is List ? decoded : decoded['data'] ?? [];
      return jsonList.map((json) => Peminjaman.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat peminjaman: ${response.body}');
    }
  }

  /// ✅ Ajukan Peminjaman
  Future<void> ajukanPeminjaman({
    required int barangId,
    required String kelas,
    required String alasan,
    required String tanggal,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/peminjaman'),
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'barang_id': barangId,
        'kelas_peminjam': kelas,
        'alasan_peminjam': alasan,
        'tanggal_peminjaman': tanggal,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Gagal mengajukan peminjaman: ${response.body}');
    }
  }

  /// ✅ Ajukan Pengembalian
  Future<void> ajukanPengembalian({
  required int peminjamanId,
  required String kondisi,
  required String tanggal,
  File? image,
  Uint8List? imageBytes,
  String? imageFileName,
}) async {
  var uri = Uri.parse('$baseUrl/api/pengembalian/$peminjamanId');
  var request = http.MultipartRequest('POST', uri);
  request.headers['Authorization'] = 'Bearer $accessToken';
  request.headers['Accept'] = 'application/json';

  request.fields['kondisi_barang'] = kondisi;
  request.fields['tanggal_dikembalikan'] = tanggal;

  if (image != null) {
    request.files.add(await http.MultipartFile.fromPath('image_bukti', image.path));
  } else if (imageBytes != null && imageFileName != null) {
    request.files.add(http.MultipartFile.fromBytes(
      'image_bukti',
      imageBytes,
      filename: imageFileName,
    ));
  }

  final response = await request.send();
  if (response.statusCode != 200) {
    final body = await response.stream.bytesToString();
    throw Exception('Gagal mengajukan pengembalian: $body');
  }
}


  /// ✅ Detail Pengembalian
  Future<Pengembalian?> fetchDetailPengembalian(int peminjamanId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/pengembalian/$peminjamanId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      // Cek apakah 'data' tidak null
      if (decoded['data'] != null) {
        return Pengembalian.fromJson(decoded['data']);
      } else {
        return null; // Tidak ada data pengembalian
      }
    } else {
      throw Exception('Gagal memuat detail pengembalian: ${response.body}');
    }
  }


}
