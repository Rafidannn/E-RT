class PengumumanModel {
  final int idPengumuman;
  final String judul;
  final String isi;
  final String tanggal;
  final String pembuat;

  PengumumanModel({
    required this.idPengumuman,
    required this.judul,
    required this.isi,
    required this.tanggal,
    required this.pembuat,
  });

  factory PengumumanModel.fromJson(Map<String, dynamic> json) {
    return PengumumanModel(
      idPengumuman: int.parse(json['id_pengumuman'].toString()),
      judul: json['judul'],
      isi: json['isi'],
      tanggal: json['tanggal'],
      pembuat: json['pembuat'] ?? 'Admin',
    );
  }
}