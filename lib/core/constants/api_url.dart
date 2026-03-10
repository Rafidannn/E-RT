class ApiUrl {
 // IP Wi-Fi Laptop (Pastiin laptop & HP satu jaringan)
 static const String baseUrl = 'http://192.168.1.26/api';
 // static const String baseUrl = 'http://10.0.2.2/api'; // Emulator Android

 // ===== ENDPOINT AUTH =====
 static const String login = '$baseUrl/auth/login.php';
 static const String register = '$baseUrl/auth/register.php';

 // ===== ENDPOINT PENGUMUMAN =====
 static const String pengumuman = '$baseUrl/pengumuman/get.php';
 static const String postPengumuman = '$baseUrl/pengumuman/create.php';

 // ===== ENDPOINT WARGA =====
 static const String getWarga = '$baseUrl/warga/get.php';
 static const String postWarga = '$baseUrl/warga/create.php';
 static const String updateWarga = '$baseUrl/warga/update.php';
 static const String deleteWarga = '$baseUrl/warga/delete.php';
 static const String totalWarga = '$baseUrl/warga/get_total.php';
 static const String totalLansia = '$baseUrl/warga/get_total_lansia.php';
 static const String getWargaIuran = '$baseUrl/warga/get_warga.php'; // Dropdown Iuran

 // ===== ENDPOINT KELUARGA =====
 static const String getKeluarga = '$baseUrl/keluarga/get.php';
 static const String getDetailKeluarga = '$baseUrl/keluarga/get_detail.php';
 static const String updateKeluarga = '$baseUrl/keluarga/update.php';
 static const String deleteKeluarga = '$baseUrl/keluarga/delete.php';
 static const String totalKeluarga = '$baseUrl/keluarga/get_total.php';
 static const String listKeluargaDropdown = '$baseUrl/keluarga/get_list_dropdown.php';

 // ===== ENDPOINT JUMANTIK =====
 static const String postJumantik = '$baseUrl/jumantik/create.php';
 static const String getJumantik = '$baseUrl/jumantik/get.php';

 // ===== ENDPOINT POSYANDU =====
 static const String postPosyandu = '$baseUrl/posyandu/create.php';
 static const String getPosyandu = '$baseUrl/posyandu/get.php';
 static const String getHistoryPosyandu = '$baseUrl/posyandu/get_history.php';
 static const String getWargaPosyandu = '$baseUrl/posyandu/get_warga.php';

 // ===== ENDPOINT IURAN =====
 static const String iuran = '$baseUrl/iuran/get_by_user.php';
 static const String getIuranByUser = '$baseUrl/iuran/get_history_user.php';
 static const String postIuran = '$baseUrl/iuran/user_pay.php';
 static const String getRekapIuran = '$baseUrl/iuran/get_rekap.php';
}