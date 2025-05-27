import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/barang.dart';
import 'services/api_service.dart';

class PeminjamanCreatePage extends StatefulWidget {
  final ApiService apiService;

  const PeminjamanCreatePage({Key? key, required this.apiService}) : super(key: key);

  @override
  _PeminjamanCreatePageState createState() => _PeminjamanCreatePageState();
}

class _PeminjamanCreatePageState extends State<PeminjamanCreatePage> {
  final _formKey = GlobalKey<FormState>();

  List<Barang> _barangList = [];
  Barang? _selectedBarang;
  final TextEditingController _kelasController = TextEditingController();
  final TextEditingController _alasanController = TextEditingController();
  DateTime? _selectedDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBarang();
  }

  Future<void> _fetchBarang() async {
    try {
      final barangList = await widget.apiService.fetchBarang();
      setState(() {
        _barangList = barangList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data barang: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBarang == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih barang')),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal peminjaman')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.apiService.ajukanPeminjaman(
        barangId: _selectedBarang!.id,
        kelas: _kelasController.text,
        alasan: _alasanController.text,
        tanggal: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Peminjaman berhasil diajukan')),
      );
      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengajukan peminjaman: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _kelasController.dispose();
    _alasanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Peminjaman Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<Barang>(
                      decoration: const InputDecoration(
                        labelText: 'Barang',
                        border: OutlineInputBorder(),
                      ),
                      items: _barangList
                          .map((barang) => DropdownMenuItem(
                                value: barang,
                                child: Text(barang.nama),
                              ))
                          .toList(),
                      value: _selectedBarang,
                      onChanged: (value) {
                        setState(() {
                          _selectedBarang = value;
                        });
                      },
                      validator: (value) => value == null ? 'Silakan pilih barang' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _kelasController,
                      decoration: const InputDecoration(
                        labelText: 'Kelas Peminjam',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Kelas peminjam harus diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _alasanController,
                      decoration: const InputDecoration(
                        labelText: 'Alasan Peminjam',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Alasan peminjam harus diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Peminjaman',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'Pilih tanggal'
                              : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                          style: TextStyle(
                            color: _selectedDate == null ? Colors.grey.shade600 : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Ajukan Peminjaman'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
