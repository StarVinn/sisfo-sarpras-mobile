import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'services/api_service.dart';

class PengembalianFormPage extends StatefulWidget {
  final int peminjamanId;
  final String accessToken;
  final String tanggalPeminjaman;

  const PengembalianFormPage({
    Key? key,
    required this.peminjamanId,
    required this.accessToken,
    required this.tanggalPeminjaman,
  }) : super(key: key);

  @override
  _PengembalianFormPageState createState() => _PengembalianFormPageState();
}

class _PengembalianFormPageState extends State<PengembalianFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _kondisiController = TextEditingController();
  DateTime? _tanggalDikembalikan;

  File? _imageFile;          // for Mobile
  Uint8List? _imageBytes;    // for Web
  String? _fileName;

  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      setState(() {
        _imageBytes = bytes;
        _fileName = pickedFile.name;
        if (!kIsWeb) {
          _imageFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _selectTanggalDikembalikan(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalDikembalikan ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _tanggalDikembalikan = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalDikembalikan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal dikembalikan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final apiService = ApiService(
      baseUrl: 'http://localhost:8000',
      accessToken: widget.accessToken,
    );

    try {
      File? fileToSend;

      // Untuk Web, simpan bytes sebagai file sementara
      if (kIsWeb && _imageBytes != null && _fileName != null) {
        // Flutter Web tidak punya File, tapi MultipartFile.fromBytes bisa dipanggil di API
        await apiService.ajukanPengembalian(
          peminjamanId: widget.peminjamanId,
          kondisi: _kondisiController.text,
          tanggal: DateFormat('yyyy-MM-dd').format(_tanggalDikembalikan!),
          imageBytes: _imageBytes!,
          imageFileName: _fileName!,
        );
      } else {
        await apiService.ajukanPengembalian(
          peminjamanId: widget.peminjamanId,
          kondisi: _kondisiController.text,
          tanggal: DateFormat('yyyy-MM-dd').format(_tanggalDikembalikan!),
          image: _imageFile,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengembalian berhasil diajukan')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengajukan pengembalian: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _kondisiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Pengembalian')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _kondisiController,
                      decoration: const InputDecoration(
                        labelText: 'Kondisi Barang',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Kondisi barang harus diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Peminjaman',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(widget.tanggalPeminjaman),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectTanggalDikembalikan(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Dikembalikan',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _tanggalDikembalikan == null
                              ? 'Pilih tanggal'
                              : DateFormat('dd/MM/yyyy')
                                  .format(_tanggalDikembalikan!),
                          style: TextStyle(
                            color: _tanggalDikembalikan == null
                                ? Colors.grey.shade600
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Pilih Bukti Gambar'),
                        ),
                        const SizedBox(width: 16),
                        if (_imageBytes != null)
                          Image.memory(
                            _imageBytes!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        else if (_imageFile != null)
                          Image.file(
                            _imageFile!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        else
                          const Text('Belum ada gambar'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Ajukan Pengembalian'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
