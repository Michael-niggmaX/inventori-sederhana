class User {
  final String id;
  final String username;
  final String password;
  final String nama;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.nama,
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'password': password,
    'nama': nama,
    'role': role,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    username: json['username'],
    password: json['password'],
    nama: json['nama'],
    role: json['role'],
  );
}
