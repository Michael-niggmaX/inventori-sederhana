import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/inventaris.dart';
import '../../models/peminjaman.dart';
import '../../models/user.dart';
import '../../services/storage_service.dart';

class FormPeminjamanScreen extends StatefulWidget {
  final User user;
  const FormPeminjamanScreen({super.key, required this.user});

  @override
  State<FormPeminjamanScreen> createState() => _FormPeminjamanScreenState();
}

class _FormPeminjamanScreenState extends State<FormPeminjamanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _service = StorageService();

  List<Inventaris> _inventarisList = [];
  Inventaris? _selected;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await _service.getInventaris();
    if (!mounted) return;
    setState(() {
      _inventarisList = data.where((e) => e.stok > 0).toList();
      _loading = false;
    });
  }

  Widget _buildThumb(Inventaris item, {double size = 32}) {
    if (item.fotoBase64 != null) {
      try {
        final bytes = base64Decode(item.fotoBase64!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {}
    }
    return SizedBox(width: size, height: size);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih barang terlebih dahulu')),
      );
      return;
    }

    final jumlah = int.parse(_jumlahController.text);
    if (jumlah > _selected!.stok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok tidak cukup! Tersedia: ${_selected!.stok}'),
        ),
      );
      return;
    }

    final allInv = await _service.getInventaris();
    final updatedInv = allInv.map((item) {
      if (item.id == _selected!.id) {
        return Inventaris(
          id: item.id,
          nama: item.nama,
          kategori: item.kategori,
          stok: item.stok - jumlah,
          fotoBase64: item.fotoBase64,
        );
      }
      return item;
    }).toList();
    await _service.saveInventaris(updatedInv);

    final allPmj = await _service.getPeminjaman();
    allPmj.add(
      Peminjaman(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        inventarisId: _selected!.id,
        namaInventaris: _selected!.nama,
        namaPeminjam: widget.user.nama,
        userId: widget.user.id,
        jumlah: jumlah,
        tanggalPinjam: DateTime.now(),
      ),
    );
    await _service.savePeminjaman(allPmj);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Peminjaman berhasil!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinjam Barang'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _inventarisList.isEmpty
          ? const Center(child: Text('Tidak ada barang tersedia'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Peminjam',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: widget.user.nama,
                      enabled: false,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pilih Barang',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Inventaris>(
                      value: _selected,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      hint: const Text('Pilih barang'),
                      items: _inventarisList.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Row(
                            children: [
                              _buildThumb(item),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${item.nama} (Stok: ${item.stok})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selected = v),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Jumlah',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan jumlah',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Wajib diisi';
                        }
                        final n = int.tryParse(v);
                        if (n == null || n <= 0) {
                          return 'Harus angka > 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Peminjaman'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
