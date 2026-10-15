import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'kelola_barang_screen.dart';
import 'kelola_user_screen.dart';
import 'lihat_semua_peminjaman_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

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
        title: const Text('Dashboard Admin'),
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
              title: 'Kelola Barang',
              subtitle: 'Tambah, edit, hapus inventaris',
              color: Colors.blue,
              screen: const KelolaBarangScreen(),
            ),
            const SizedBox(height: 12),
            _menuCard(
              context,
              icon: Icons.people,
              title: 'Kelola User',
              subtitle: 'Tambah, edit, hapus akun',
              color: Colors.purple,
              screen: const KelolaUserScreen(),
            ),
            const SizedBox(height: 12),
            _menuCard(
              context,
              icon: Icons.history,
              title: 'Semua Peminjaman',
              subtitle: 'Lihat riwayat semua user',
              color: Colors.orange,
              screen: const LihatSemuaPeminjamanScreen(),
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
