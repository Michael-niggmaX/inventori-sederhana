import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/inventaris.dart';
import '../../services/storage_service.dart';

class DaftarInventarisScreen extends StatefulWidget {
  const DaftarInventarisScreen({super.key});

  @override
  State<DaftarInventarisScreen> createState() => _DaftarInventarisScreenState();
}

class _DaftarInventarisScreenState extends State<DaftarInventarisScreen> {
  final _service = StorageService();
  List<Inventaris> _list = [];
  bool _loading = true;
  String _query = '';

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

  Widget _buildThumbnail(Inventaris item) {
    if (item.fotoBase64 != null) {
      try {
        final bytes = base64Decode(item.fotoBase64!);
        return Image.memory(bytes, width: 56, height: 56, fit: BoxFit.cover);
      } catch (_) {}
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
    final filtered = _list
        .where(
          (e) =>
              e.nama.toLowerCase().contains(_query.toLowerCase()) ||
              e.kategori.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Inventaris'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari barang...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('Barang tidak ditemukan'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final item = filtered[i];
                            return Card(
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildThumbnail(item),
                                ),
                                title: Text(
                                  item.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text('Kategori: ${item.kategori}'),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.stok > 0
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Stok: ${item.stok}',
                                    style: TextStyle(
                                      color: item.stok > 0
                                          ? Colors.green.shade800
                                          : Colors.red.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
