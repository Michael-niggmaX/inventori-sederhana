import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/inventaris.dart';
import '../models/peminjaman.dart';
import '../models/user.dart';

class StorageService {
  static const _keyInventaris = 'data_inventaris';
  static const _keyPeminjaman = 'data_peminjaman';
  static const _keyUsers = 'data_users';
  static const _keySession = 'session_user';

  Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyUsers);
    if (data == null) {
      final seed = [
        User(
          id: '1',
          username: 'admin',
          password: 'admin123',
          nama: 'Administrator',
          role: 'admin',
        ),
        User(
          id: '2',
          username: 'user',
          password: 'user123',
          nama: 'Budi Santoso',
          role: 'user',
        ),
      ];
      await saveUsers(seed);
      return seed;
    }
    final List decoded = jsonDecode(data);
    return decoded.map((e) => User.fromJson(e)).toList();
  }

  Future<void> saveUsers(List<User> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyUsers,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> saveSession(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_keySession);
    } else {
      await prefs.setString(_keySession, jsonEncode(user.toJson()));
    }
  }

  Future<User?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keySession);
    if (data == null) return null;
    return User.fromJson(jsonDecode(data));
  }

  Future<List<Inventaris>> getInventaris() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyInventaris);
    if (data == null) {
      final seed = [
        Inventaris(
          id: '1',
          nama: 'Laptop Asus',
          kategori: 'Elektronik',
          stok: 5,
        ),
        Inventaris(
          id: '2',
          nama: 'Proyektor Epson',
          kategori: 'Elektronik',
          stok: 2,
        ),
        Inventaris(
          id: '3',
          nama: 'Meja Lipat',
          kategori: 'Furniture',
          stok: 10,
        ),
        Inventaris(
          id: '4',
          nama: 'Kursi Plastik',
          kategori: 'Furniture',
          stok: 20,
        ),
        Inventaris(id: '5', nama: 'Kabel HDMI', kategori: 'Aksesoris', stok: 8),
      ];
      await saveInventaris(seed);
      return seed;
    }
    final List decoded = jsonDecode(data);
    return decoded.map((e) => Inventaris.fromJson(e)).toList();
  }

  Future<void> saveInventaris(List<Inventaris> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyInventaris,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<Peminjaman>> getPeminjaman() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyPeminjaman);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => Peminjaman.fromJson(e)).toList();
  }

  Future<void> savePeminjaman(List<Peminjaman> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyPeminjaman,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }
}
