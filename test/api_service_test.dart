import 'package:flutter_test/flutter_test.dart';
import 'package:ert/core/api/api_service.dart';

void main() {
  const String baseUrl = 'http://10.49.210.193/api/warga';

  group('Testing API Warga -', () {

    // 1. Tes Ambil Data
    test('Test Get Warga', () async {
      final response = await ApiService.get('$baseUrl/get.php');
      print('Hasil Get: $response');
      expect(response['status'], 'success');
    });

    // 2. Tes Tambah Warga
    test('Test Create Warga', () async {
      final body = {
        'id_keluarga': 1,
        'nama': 'Tester Ganteng',
        'nik': '123456789',
        'tempat_lahir': 'Jakarta',
        'tanggal_lahir': '2000-01-01',
        'jenis_kelamin': 'L',
        'pendidikan': 'S1',
        'pekerjaan': 'Developer',
        'status_perkawinan': 'belum_kawin',
        'status_kesehatan_khusus': 'umum',
        'bpjs_aktif': 1
      };

      final response = await ApiService.post('$baseUrl/create.php', body);
      print('Hasil Create: $response');
      expect(response['status'], 'success');
    });
  });
}