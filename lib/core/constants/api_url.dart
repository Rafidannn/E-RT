class ApiUrl {
 // IP Wi-Fi Laptop lu (pastiin tetep 1.26 ya cok)
 static const String baseUrl = 'http://192.168.1.26/api';

 // ===== ENDPOINT AUTH =====
 static const String login = '$baseUrl/auth/login.php';
 static const String register = "$baseUrl/auth/register.php";

 // ===== ENDPOINT PENGUMUMAN =====
 static const String pengumuman = '$baseUrl/pengumuman/get.php';
 static const String postPengumuman = '$baseUrl/pengumuman/create.php';

 // ===== ENDPOINT WARGA & KELUARGA =====
 static const String getWarga = '$baseUrl/warga/get.php';
 static const String totalWarga = '$baseUrl/warga/get_total.php';
 static const String totalLansia = '$baseUrl/warga/get_total_lansia.php';
 static const String totalKeluarga = '$baseUrl/keluarga/get_total.php';
 static const String listKeluargaDropdown = '$baseUrl/keluarga/get_list_dropdown.php';
 static const String getDetailKeluarga = '$baseUrl/keluarga/get_detail.php';
 static const String updateKeluarga = '$baseUrl/keluarga/update.php';
 static const String deleteKeluarga = '$baseUrl/keluarga/delete.php';

 // TAMBAHIN INI: Untuk ngambil list keluarga di Dropdown Jumantik
 static const String getKeluarga = '$baseUrl/keluarga/get.php';

 // ===== ENDPOINT JUMANTIK =====
 // Hapus salah satu (static const String jumantik) biar gak bingung, pake yang lebih jelas namanya
 static const String postJumantik = '$baseUrl/jumantik/create.php';
 static const String getJumantik = '$baseUrl/jumantik/get.php';

 // ===== ENDPOINT LAINNYA =====
 static const String iuran = '$baseUrl/iuran/get_by_user.php';
 static const String posyandu = '$baseUrl/posyandu/create.php';
 static const String getPosyandu = '$baseUrl/posyandu/get.php';
}