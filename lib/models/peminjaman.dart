class Peminjaman {
  final String id;
  final String inventarisId;
  final String namaInventaris;
  final String namaPeminjam;
  final String userId;
  final int jumlah;
  final DateTime tanggalPinjam;
  final DateTime? tanggalKembali;
  final bool sudahKembali;

  Peminjaman({
    required this.id,
    required this.inventarisId,
    required this.namaInventaris,
    required this.namaPeminjam,
    required this.userId,
    required this.jumlah,
    required this.tanggalPinjam,
    this.tanggalKembali,
    this.sudahKembali = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'inventarisId': inventarisId,
    'namaInventaris': namaInventaris,
    'namaPeminjam': namaPeminjam,
    'userId': userId,
    'jumlah': jumlah,
    'tanggalPinjam': tanggalPinjam.toIso8601String(),
    'tanggalKembali': tanggalKembali?.toIso8601String(),
    'sudahKembali': sudahKembali,
  };

  factory Peminjaman.fromJson(Map<String, dynamic> json) => Peminjaman(
    id: json['id'],
    inventarisId: json['inventarisId'],
    namaInventaris: json['namaInventaris'],
    namaPeminjam: json['namaPeminjam'],
    userId: json['userId'],
    jumlah: json['jumlah'],
    tanggalPinjam: DateTime.parse(json['tanggalPinjam']),
    tanggalKembali: json['tanggalKembali'] != null
        ? DateTime.parse(json['tanggalKembali'])
        : null,
    sudahKembali: json['sudahKembali'] ?? false,
  );
}
