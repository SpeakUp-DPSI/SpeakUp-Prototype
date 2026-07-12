# SpeakUp Prototype

SpeakUp adalah aplikasi pelaporan dan penanganan perundungan (bullying) di sekolah. Aplikasi ini terdiri dari dua bagian utama:
1. **SpeakUp Backend**: API berbasis Laravel.
2. **SpeakUp Mobile**: Aplikasi mobile berbasis Flutter.

## Perubahan Terbaru (Update Terkini)
Sejak pull terakhir, berikut adalah fitur dan perbaikan yang ditambahkan:

### 1. Manajemen Pengguna (Admin)
- Menambahkan **CRUD Penuh Pengguna** untuk role Admin (Tambah, Edit, Hapus, dan Ubah Role).
- Menambahkan Action Menu pada daftar pengguna agar Admin dapat mengubah data diri dan kata sandi pengguna dengan mudah.
- Penyesuaian layout tab Admin: Menghapus tab "Pengaturan" pada *bottom navigation* karena pengaturan akun dipindahkan secara eksklusif ke halaman Profil.
- Ikon "Notifikasi" untuk Admin telah dipindahkan ke sudut kanan atas (*AppBar*) mengikuti desain Kepala Sekolah dan Orang Tua.

### 2. Fitur Laporan & Mediasi
- Menyempurnakan antarmuka Detail Laporan.
- Menambahkan fitur penyelesaian mediasi (`Selesaikan Mediasi`).
- Menerapkan pembatasan wewenang validasi dan penyelesaian laporan agar **hanya bisa dilakukan oleh Guru BK** (Admin tidak dapat memvalidasi/menyelesaikan laporan).

### 3. Halaman & UI Baru
- Penambahan halaman Statistik/Tren (`Trend Chart`) untuk Kepala Sekolah.
- Penambahan halaman Pengaturan Notifikasi dan Edit Profil di sub-menu Profil.

