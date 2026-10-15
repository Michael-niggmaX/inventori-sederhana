import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/inventaris.dart';
import '../../models/peminjaman.dart';
import '../../models/user.dart';
import '../../services/storage_service.dart';

class DaftarPeminjamanScreen extends StatefulWidget {
  final User user;
  const DaftarPeminjamanScreen({super.key, required this.user});

  @override
  State<DaftarPeminjamanScreen> createState() => _DaftarPeminjamanScreenState();
}

class _DaftarPeminjamanScreenState extends State<DaftarPeminjamanScreen> {
  final _service = StorageService();
  List<Peminjaman> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getPeminjaman();
    if (!mounted) return;
    setState(() {
      _list = data
          .where((p) => p.userId == widget.user.id)
          .toList()
          .reversed
          .toList();
      _loading = false;
    });
  }

  Future<void> _kembalikan(Peminjaman p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Kembalikan ${p.namaInventaris} sebanyak ${p.jumlah}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final allInv = await _service.getInventaris();
    final updatedInv = allInv.map((item) {
      if (item.id == p.inventarisId) {
        return Inventaris(
          id: item.id,
          nama: item.nama,
          kategori: item.kategori,
          stok: item.stok + p.jumlah,
          fotoBase64: item.fotoBase64, // ✅ pakai fotoBase64
        );
      }
      return item;
    }).toList();
    await _service.saveInventaris(updatedInv);

    final allPmj = await _service.getPeminjaman();
    final updatedPmj = allPmj.map((item) {
      if (item.id == p.id) {
        return Peminjaman(
          id: item.id,
          inventarisId: item.inventarisId,
          namaInventaris: item.namaInventaris,
          namaPeminjam: item.namaPeminjam,
          userId: item.userId,
          jumlah: item.jumlah,
          tanggalPinjam: item.tanggalPinjam,
          tanggalKembali: DateTime.now(),
          sudahKembali: true,
        );
      }
      return item;
    }).toList();
    await _service.savePeminjaman(updatedPmj);

    _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barang berhasil dikembalikan'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peminjaman Saya'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
          ? const Center(child: Text('Belum ada peminjaman'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _list.length,
              itemBuilder: (context, i) {
                final p = _list[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: p.sudahKembali
                          ? Colors.grey.shade300
                          : Colors.orange.shade100,
                      child: Icon(
                        p.sudahKembali ? Icons.check : Icons.schedule,
                        color: p.sudahKembali ? Colors.grey : Colors.orange,
                      ),
                    ),
                    title: Text(
                      p.namaInventaris,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jumlah: ${p.jumlah}'),
                        Text('Pinjam: ${dateFormat.format(p.tanggalPinjam)}'),
                        if (p.sudahKembali && p.tanggalKembali != null)
                          Text(
                            'Kembali: ${dateFormat.format(p.tanggalKembali!)}',
                            style: const TextStyle(color: Colors.green),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: p.sudahKembali
                        ? const Chip(
                            label: Text('Selesai'),
                            backgroundColor: Color(0xFFE0E0E0),
                          )
                        : ElevatedButton(
                            onPressed: () => _kembalikan(p),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Kembalikan'),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
