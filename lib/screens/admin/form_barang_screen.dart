import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/inventaris.dart';
import '../../services/storage_service.dart';

class FormBarangScreen extends StatefulWidget {
  final Inventaris? inventaris;
  const FormBarangScreen({super.key, this.inventaris});

  @override
  State<FormBarangScreen> createState() => _FormBarangScreenState();
}

class _FormBarangScreenState extends State<FormBarangScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _stokController = TextEditingController();
  final _service = StorageService();
  final _picker = ImagePicker();

  Uint8List? _fotoBaru; 
  String? _fotoBase64Lama; 

  bool get isEdit => widget.inventaris != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _namaController.text = widget.inventaris!.nama;
      _kategoriController.text = widget.inventaris!.kategori;
      _stokController.text = widget.inventaris!.stok.toString();
      _fotoBase64Lama = widget.inventaris!.fotoBase64;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kategoriController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 800,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() => _fotoBaru = bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memilih foto: $e')));
    }
  }

  void _showPilihanFoto() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _pilihFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pilihFoto(ImageSource.gallery);
              },
            ),
            if (_fotoBaru != null || _fotoBase64Lama != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Hapus Foto',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _fotoBaru = null;
                    _fotoBase64Lama = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewFoto() {
    if (_fotoBaru != null) {
      return Image.memory(_fotoBaru!, fit: BoxFit.cover);
    }
    if (_fotoBase64Lama != null) {
      try {
        final bytes = base64Decode(_fotoBase64Lama!);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return const Icon(Icons.broken_image, size: 48, color: Colors.grey);
      }
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
        SizedBox(height: 8),
        Text('Tambah Foto', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    String? fotoBase64;
    if (_fotoBaru != null) {
      fotoBase64 = base64Encode(_fotoBaru!);
    } else {
      fotoBase64 = _fotoBase64Lama; 
    }

    final all = await _service.getInventaris();

    if (isEdit) {
      final idx = all.indexWhere((e) => e.id == widget.inventaris!.id);
      if (idx == -1) return;
      all[idx] = Inventaris(
        id: widget.inventaris!.id,
        nama: _namaController.text,
        kategori: _kategoriController.text,
        stok: int.parse(_stokController.text),
        fotoBase64: fotoBase64,
      );
    } else {
      all.add(
        Inventaris(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nama: _namaController.text,
          kategori: _kategoriController.text,
          stok: int.parse(_stokController.text),
          fotoBase64: fotoBase64,
        ),
      );
    }

    await _service.saveInventaris(all);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEdit ? 'Barang diperbarui' : 'Barang ditambahkan'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Barang' : 'Tambah Barang'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _showPilihanFoto,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildPreviewFoto(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Tap untuk ubah foto',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  prefixIcon: Icon(Icons.inventory),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kategoriController,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stokController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  final n = int.tryParse(v);
                  if (n == null || n < 0) return 'Harus angka ≥ 0';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _simpan,
                icon: const Icon(Icons.save),
                label: const Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
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
