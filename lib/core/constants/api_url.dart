class ApiUrl {
  // Pakai IP Wi-Fi laptop lu yang 10.49.210.193
  // Sesuaikan path foldernya (misal /ert/api atau /api_dawis)
  //static const String baseUrl = 'http://10.119.235.193/api';
 static const String baseUrl = 'http://192.168.1.26/api';
  // ===== ENDPOINT =====
  // Ini sudah benar, otomatis ngikutin baseUrl di atas
  static const String login = '$baseUrl/auth/login.php';
  static const String register = "$baseUrl/auth/register.php";
  static const String pengumuman = '$baseUrl/pengumuman/get.php';
  static const String postPengumuman = '$baseUrl/pengumuman/create.php';
  static const String iuran = '$baseUrl/iuran/get_by_user.php';
  static const String jumantik = '$baseUrl/jumantik/create.php';
  static const String posyandu = '$baseUrl/posyandu/create.php';
  static const String getWarga = '$baseUrl/warga/get.php';

}