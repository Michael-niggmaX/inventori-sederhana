import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/storage_service.dart';

class FormUserScreen extends StatefulWidget {
  final User? user;
  const FormUserScreen({super.key, this.user});

  @override
  State<FormUserScreen> createState() => _FormUserScreenState();
}

class _FormUserScreenState extends State<FormUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _service = StorageService();
  String _role = 'user';

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _namaController.text = widget.user!.nama;
      _usernameController.text = widget.user!.username;
      _passwordController.text = widget.user!.password;
      _role = widget.user!.role;
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final all = await _service.getUsers();
    final usernameExist = all.any(
      (u) =>
          u.username == _usernameController.text.trim() &&
          (!isEdit || u.id != widget.user!.id),
    );

    if (usernameExist) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username sudah dipakai'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isEdit) {
      final idx = all.indexWhere((e) => e.id == widget.user!.id);
      all[idx] = User(
        id: widget.user!.id,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        nama: _namaController.text,
        role: _role,
      );
    } else {
      all.add(
        User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          nama: _namaController.text,
          role: _role,
        ),
      );
    }

    await _service.saveUsers(all);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit User' : 'Tambah User'),
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
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.length < 5 ? 'Minimal 5 karakter' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.security),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setState(() => _role = v!),
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
