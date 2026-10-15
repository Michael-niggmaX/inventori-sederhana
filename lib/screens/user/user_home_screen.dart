import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'daftar_inventaris_screen.dart';
import 'form_peminjaman_screen.dart';
import 'daftar_peminjaman_screen.dart';

class UserHomeScreen extends StatelessWidget {
  final User user;
  const UserHomeScreen({super.key, required this.user});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${user.nama}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _menuCard(
              context,
              icon: Icons.inventory_2,
              title: 'Daftar Inventaris',
              subtitle: 'Lihat barang yang tersedia',
              color: Colors.blue,
              screen: const DaftarInventarisScreen(),
            ),
            const SizedBox(height: 12),
            _menuCard(
              context,
              icon: Icons.add_circle_outline,
              title: 'Pinjam Barang',
              subtitle: 'Buat peminjaman baru',
              color: Colors.green,
              screen: FormPeminjamanScreen(user: user),
            ),
            const SizedBox(height: 12),
            _menuCard(
              context,
              icon: Icons.list_alt,
              title: 'Peminjaman Saya',
              subtitle: 'Lihat & kembalikan barang',
              color: Colors.orange,
              screen: DaftarPeminjamanScreen(user: user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Widget screen,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          radius: 28,
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      ),
    );
  }
}
