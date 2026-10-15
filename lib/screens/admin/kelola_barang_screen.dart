import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/inventaris.dart';
import '../../services/storage_service.dart';
import 'form_barang_screen.dart';

class KelolaBarangScreen extends StatefulWidget {
  const KelolaBarangScreen({super.key});

  @override
  State<KelolaBarangScreen> createState() => _KelolaBarangScreenState();
}

class _KelolaBarangScreenState extends State<KelolaBarangScreen> {
  final _service = StorageService();
  List<Inventaris> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getInventaris();
    if (!mounted) return;
    setState(() {
      _list = data;
      _loading = false;
    });
  }

  Future<void> _hapus(Inventaris item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Yakin ingin menghapus ${item.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final updated = _list.where((e) => e.id != item.id).toList();
    await _service.saveInventaris(updated);
    _load();
  }

  Widget _buildThumbnail(Inventaris item) {
    if (item.fotoBase64 != null) {
      try {
        final bytes = base64Decode(item.fotoBase64!);
        return Image.memory(bytes, width: 56, height: 56, fit: BoxFit.cover);
      } catch (_) {
        // fallback
      }
    }
    return Container(
      width: 56,
      height: 56,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Barang'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormBarangScreen()),
          );
          _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
          ? const Center(child: Text('Belum ada barang'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _list.length,
              itemBuilder: (context, i) {
                final item = _list[i];
                return Card(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildThumbnail(item),
                    ),
                    title: Text(
                      item.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${item.kategori} • Stok: ${item.stok}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FormBarangScreen(inventaris: item),
                              ),
                            );
                            _load();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _hapus(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
