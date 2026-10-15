class Inventaris {
  final String id;
  final String nama;
  final String kategori;
  final int stok;
  final String? fotoBase64;

  Inventaris({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.stok,
    this.fotoBase64,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'kategori': kategori,
    'stok': stok,
    'fotoBase64': fotoBase64,
  };

  factory Inventaris.fromJson(Map<String, dynamic> json) => Inventaris(
    id: json['id'],
    nama: json['nama'],
    kategori: json['kategori'],
    stok: json['stok'],
    fotoBase64: json['fotoBase64'],
  );
}
