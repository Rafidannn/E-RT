class ApiUrl {
  // Ganti IP ini kalau ngetes pake HP asli (pake IP Wi-Fi Laptop)
  // static const String baseUrl = 'http://192.168.1.XX/api';
  // static const String baseUrl = 'http://192.168.111.173/api';
  static const String baseUrl = 'http://192.168.1.12/api'; // IP Wi-Fi Laptop
  // static const String baseUrl = 'http://10.25.19.114/api'; //Hp Wifi Ghatan

  // ===== ENDPOINT AUTH =====
  static const String login = '$baseUrl/auth/login.php';
  static const String register = '$baseUrl/auth/register.php';

  // ===== ENDPOINT VERIFIKASI (BARU) =====
  static const String getPendingUsers = '$baseUrl/verifikasi/get_pending_users.php';
  static const String verifyUser = '$baseUrl/verifikasi/verify_user.php';

  // ===== ENDPOINT PENGUMUMAN =====
  static const String pengumuman = '$baseUrl/pengumuman/get.php';
  static const String postPengumuman = '$baseUrl/pengumuman/create.php';
  static const String getAgenda = '$baseUrl/pengumuman/get_agenda.php';

  // ===== ENDPOINT WARGA =====
  static const String getWarga = '$baseUrl/warga/get.php';
  static const String postWarga = '$baseUrl/warga/create.php';
  static const String updateWarga = '$baseUrl/warga/update.php';
  static const String deleteWarga = '$baseUrl/warga/delete.php';
  static const String totalWarga = '$baseUrl/warga/get_total.php';
  static const String totalLansia = '$baseUrl/warga/get_total_lansia.php';
  static const String getProfilByNik = '$baseUrl/warga/get_profil_by_nik.php';
  static const String getProfilLengkap = '$baseUrl/warga/get_profil_lengkap.php';
  static const String getWargaIuran = '$baseUrl/warga/get_warga.php'; // Dropdown Iuran
  static const String getTanpaKK = '$baseUrl/warga/get_tanpa_kk.php';

  // URL untuk dropdown di halaman Input Iuran
  static const String getKeluargaIuran = '$baseUrl/keluarga/get_dropdown_keluarga.php';

  // ===== ENDPOINT KELUARGA =====
  static const String getKeluarga = '$baseUrl/keluarga/get.php';
  static const String getDetailKeluarga = '$baseUrl/keluarga/get_detail.php';
  static const String updateKeluarga = '$baseUrl/keluarga/update.php';
  static const String deleteKeluarga = '$baseUrl/keluarga/delete.php';
  static const String totalKeluarga = '$baseUrl/keluarga/get_total.php';
  static const String listKeluargaDropdown = '$baseUrl/keluarga/get_list_dropdown.php';
  static const String postKeluarga = '$baseUrl/keluarga/create.php';

  // ===== ENDPOINT JUMANTIK =====
  static const String postJumantik = '$baseUrl/jumantik/create.php';
  static const String getJumantik = '$baseUrl/jumantik/get.php';

  // ===== ENDPOINT POSYANDU =====
  static const String postPosyandu = '$baseUrl/posyandu/create.php';
  static const String getPosyandu = '$baseUrl/posyandu/get.php';
  static const String getHistoryPosyandu = '$baseUrl/posyandu/get_history.php';
  static const String getWargaPosyandu = '$baseUrl/posyandu/get_warga.php';

  // ===== ENDPOINT IURAN (FIXED) =====
  // Untuk simpan pembayaran iuran baru
  static const String postIuran = '$baseUrl/iuran/pay.php';

  // Untuk ambil rekap iuran (tampilan Riwayat Admin)
  static const String getRekapIuran = '$baseUrl/iuran/get_rekap.php';

  // Untuk riwayat iuran spesifik per keluarga/user
  static const String getIuranByUser = '$baseUrl/iuran/get_history_user.php';

  // Cadangan kalau butuh method GET per user
  static const String iuran = '$baseUrl/iuran/get_by_user.php';

  // ===== ENDPOINT LAPORAN =====
  static const String postLaporan = '$baseUrl/laporan/post_laporan.php';
  static const String getLaporan = '$baseUrl/laporan/get_laporan.php';

  // ===== ENDPOINT SURAT PENGANTAR =====
  static const String postSurat = '$baseUrl/surat/post_surat.php';
  static const String getSurat = '$baseUrl/surat/get_surat.php';

  // ===== ENDPOINT KELUARGA =====
  static const String getInfoKeluarga = '$baseUrl/keluarga/get_keluarga.php';
}
