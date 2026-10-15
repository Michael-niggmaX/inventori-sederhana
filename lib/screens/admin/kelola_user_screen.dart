import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/storage_service.dart';
import 'form_user_screen.dart';

class KelolaUserScreen extends StatefulWidget {
  const KelolaUserScreen({super.key});

  @override
  State<KelolaUserScreen> createState() => _KelolaUserScreenState();
}

class _KelolaUserScreenState extends State<KelolaUserScreen> {
  final _service = StorageService();
  List<User> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getUsers();
    setState(() {
      _list = data;
      _loading = false;
    });
  }

  Future<void> _hapus(User user) async {
    if (user.username == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin utama tidak bisa dihapus')),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Yakin ingin menghapus ${user.nama}?'),
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
    final updated = _list.where((e) => e.id != user.id).toList();
    await _service.saveUsers(updated);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola User'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormUserScreen()),
          );
          _load();
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _list.length,
              itemBuilder: (context, i) {
                final user = _list[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.isAdmin
                          ? Colors.red.shade100
                          : Colors.blue.shade100,
                      child: Icon(
                        user.isAdmin
                            ? Icons.admin_panel_settings
                            : Icons.person,
                        color: user.isAdmin ? Colors.red : Colors.blue,
                      ),
                    ),
                    title: Text(
                      user.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '@${user.username} • ${user.role.toUpperCase()}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FormUserScreen(user: user),
                              ),
                            );
                            _load();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _hapus(user),
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
