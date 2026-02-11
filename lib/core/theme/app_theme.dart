class UserModel {
  final int idUser;
  final String nama;
  final String nik;
  final String role;

  UserModel({required this.idUser, required this.nama, required this.nik, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: int.parse(json['id_user'].toString()),
      nama: json['nama'],
      nik: json['nik'],
      role: json['role'],
    );
  }
}