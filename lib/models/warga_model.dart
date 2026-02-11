class WargaModel {
  final int idWarga;
  final int idKeluarga;
  final String nama;
  final String nik;
  final String tempatLahir;
  final String tanggalLahir;
  final String jenisKelamin; // Enum: 'L', 'P'
  final String pendidikan;
  final String pekerjaan;
  final String statusPerkawinan; // Enum: 'kawin', 'belum_kawin', dll
  final String statusKesehatanKhusus; // Enum: 'umum', 'bumil', dll
  final bool bpjsAktif; // tinyint(1) di database jadi bool di Dart

  WargaModel({
    required this.idWarga,
    required this.idKeluarga,
    required this.nama,
    required this.nik,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.pendidikan,
    required this.pekerjaan,
    required this.statusPerkawinan,
    required this.statusKesehatanKhusus,
    required this.bpjsAktif,
  });

  // Fungsi untuk mengubah JSON dari API (PHP) menjadi Objek Dart
  factory WargaModel.fromJson(Map<String, dynamic> json) {
    return WargaModel(
      idWarga: int.parse(json['id_warga'].toString()),
      idKeluarga: int.parse(json['id_keluarga'].toString()),
      nama: json['nama'],
      nik: json['nik'],
      tempatLahir: json['tempat_lahir'],
      tanggalLahir: json['tanggal_lahir'],
      jenisKelamin: json['jenis_kelamin'],
      pendidikan: json['pendidikan'],
      pekerjaan: json['pekerjaan'],
      statusPerkawinan: json['status_perkawinan'],
      statusKesehatanKhusus: json['status_kesehatan_khusus'],
      // Di MySQL tinyint(1) biasanya bernilai 1 (true) atau 0 (false)
      bpjsAktif: json['bpjs_aktif'].toString() == '1',
    );
  }

  // Fungsi untuk mengubah Objek Dart kembali ke JSON (jika ingin dikirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'id_warga': idWarga,
      'id_keluarga': idKeluarga,
      'nama': nama,
      'nik': nik,
      'tempat_lahir': tempatLahir,
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
      'pendidikan': pendidikan,
      'pekerjaan': pekerjaan,
      'status_perkawinan': statusPerkawinan,
      'status_kesehatan_khusus': statusKesehatanKhusus,
      'bpjs_aktif': bpjsAktif ? 1 : 0,
    };
  }
}