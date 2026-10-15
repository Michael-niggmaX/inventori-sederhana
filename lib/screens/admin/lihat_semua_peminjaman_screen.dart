import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/storage_service.dart';
import '../../models/peminjaman.dart';

class LihatSemuaPeminjamanScreen extends StatefulWidget {
  const LihatSemuaPeminjamanScreen({super.key});

  @override
  State<LihatSemuaPeminjamanScreen> createState() =>
      _LihatSemuaPeminjamanScreenState();
}

class _LihatSemuaPeminjamanScreenState
    extends State<LihatSemuaPeminjamanScreen> {
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
    setState(() {
      _list = data.reversed.toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Peminjaman'),
        backgroundColor: Colors.indigo,
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
                        Text('Peminjam: ${p.namaPeminjam}'),
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
                    trailing: Chip(
                      label: Text(p.sudahKembali ? 'Selesai' : 'Aktif'),
                      backgroundColor: p.sudahKembali
                          ? Colors.grey.shade200
                          : Colors.orange.shade100,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
