# Information Architecture
## SpeakUp — Sistem Pelaporan dan Penanganan Kasus Perundungan
**Versi:** 2.0 (Revised — Hybrid Mobile & Web)
**Tanggal:** Juli 2026
**Backend:** Laravel REST API
**Program Studi:** Sistem Informasi — Universitas Ahmad Dahlan Yogyakarta

---

## 1. Gambaran Umum Arsitektur

SpeakUp adalah aplikasi **hybrid** (mobile + web) yang mengonsumsi satu backend Laravel API. Arsitektur dibagi berdasarkan dua dimensi:

1. **Platform** — Mobile App vs Web App
2. **Role Pengguna** — Siswa, Guru BK, Kepala Sekolah, Orang Tua/Wali, Admin

```
SPEAKUP
│
├── AUTH AREA              ← Semua platform, sebelum login
│   ├── Login
│   ├── Daftar (Register)
│   ├── Verifikasi OTP
│   └── Verifikasi Berhasil
│
├── AREA SISWA             ← Mobile (utama) + Web
├── AREA GURU BK           ← Mobile + Web
├── AREA KEPALA SEKOLAH    ← Web (utama) + Mobile (read-only)
├── AREA ORANG TUA/WALI    ← Mobile (utama) + Web
└── AREA ADMIN             ← Web only
```

---

## 2. Auth Flow

```
┌─────────────────────────────────────────────────────┐
│                    AUTH AREA                        │
│  (Semua pengguna, sebelum login)                    │
│                                                     │
│  Login ──────────────────────────────► Dashboard    │
│                                                     │
│  Daftar                                             │
│    ↓                                                │
│  Verifikasi OTP                                     │
│    ↓ (benar)         ↓ (salah)                      │
│  Verifikasi          Error: "Kode Verifikasi Salah" │
│  Berhasil            → Coba lagi / Kirim ulang OTP  │
│    ↓                                                │
│  Login → Dashboard                                  │
└─────────────────────────────────────────────────────┘
```

### API Endpoints Auth

| Screen | Method | Endpoint |
|---|---|---|
| Login | POST | `/api/login` |
| Daftar | POST | `/api/register` *(perlu ditambah)* |
| Verifikasi OTP | POST | `/api/verify-otp` *(perlu ditambah)* |
| Kirim Ulang OTP | POST | `/api/resend-otp` *(perlu ditambah)* |
| Logout | POST | `/api/logout` |

---

## 3. Sitemap Lengkap

```
SPEAKUP
│
├── AUTH
│   ├── Login
│   ├── Daftar
│   │   ├── Form: nama, email, password, phone, role
│   │   └── Submit → OTP dikirim ke email
│   ├── Verifikasi OTP
│   │   ├── 6 kotak input kode
│   │   ├── State: Default / Salah / Berhasil
│   │   └── Link: Kirim Ulang Kode
│   └── Pendaftaran Berhasil
│
├── SISWA
│   │
│   ├── Beranda
│   │   ├── Greeting (nama pengguna)
│   │   ├── Stat Cards
│   │   │   ├── Laporan Dibuat
│   │   │   ├── Sedang Diproses
│   │   │   └── Selesai
│   │   ├── Aksi Cepat: Buat Laporan Baru
│   │   └── Laporan Terbaru (3 item)
│   │
│   ├── Buat Laporan (Multi-Step)
│   │   ├── Step 1: Data Kejadian
│   │   │   ├── Jenis Perundungan (fisik/verbal/sosial/cyberbullying)
│   │   │   ├── Judul Laporan
│   │   │   ├── Tanggal & Waktu Kejadian
│   │   │   ├── Lokasi Kejadian
│   │   │   ├── Kronologi / Deskripsi
│   │   │   └── Data Pihak Terlibat
│   │   │       ├── Korban (nama, kelas)
│   │   │       ├── Terlapor (nama, kelas)
│   │   │       └── Saksi (opsional)
│   │   ├── Step 2: Bukti & Identitas
│   │   │   ├── Upload Bukti (foto/video/dokumen, maks 10MB)
│   │   │   └── Pilihan Identitas Pelapor
│   │   │       ├── Lapor dengan Identitas
│   │   │       └── Lapor Secara Anonim (is_anonymous: true)
│   │   ├── Step 3: Review & Kirim
│   │   │   ├── Ringkasan semua data
│   │   │   └── Tombol Kirim Laporan
│   │   └── Konfirmasi Pengiriman
│   │       ├── Kode Laporan (SPK-YYYY-NNNNN)
│   │       └── Instruksi cek status
│   │
│   ├── Riwayat Laporan
│   │   ├── Filter Status (chip horizontal)
│   │   ├── List Laporan (card per item)
│   │   │   ├── Kode Laporan
│   │   │   ├── Judul
│   │   │   ├── Tanggal
│   │   │   └── Badge Status
│   │   └── Detail Laporan
│   │       ├── Informasi Lengkap Laporan
│   │       ├── Status Saat Ini
│   │       ├── Timeline Riwayat Status
│   │       └── Catatan dari Guru BK (terbatas)
│   │
│   ├── Notifikasi
│   │   ├── List notifikasi (paginate)
│   │   ├── Badge unread count
│   │   └── Tandai dibaca (per item / semua)
│   │
│   └── Profil
│       ├── Data Akun (nama, email, foto)
│       ├── Edit Profil
│       ├── Ubah Password
│       └── Logout
│
├── GURU BK
│   │
│   ├── Dashboard Utama
│   │   ├── Greeting + tanggal
│   │   ├── Stat Cards
│   │   │   ├── Total Laporan
│   │   │   ├── Menunggu Validasi
│   │   │   ├── Sedang Diproses
│   │   │   └── Selesai
│   │   └── Laporan Terbaru (5 item)
│   │
│   ├── Manajemen Laporan
│   │   ├── Tab Filter: Semua / Menunggu / Diproses / Mediasi / Selesai
│   │   ├── List Laporan
│   │   │   ├── Kode Laporan
│   │   │   ├── Judul & Kategori
│   │   │   ├── Tanggal
│   │   │   └── Badge Status
│   │   └── Detail Laporan
│   │       ├── Data Lengkap Laporan
│   │       │   ├── Judul, Kronologi, Lokasi, Tanggal
│   │       │   ├── Kategori Perundungan
│   │       │   ├── Identitas Pelapor (hidden jika anonim)
│   │       │   └── Data Pihak: Korban, Terlapor, Saksi
│   │       ├── Bukti Pendukung
│   │       │   ├── Preview file (foto/video/dokumen)
│   │       │   └── Download bukti
│   │       ├── Validasi Laporan
│   │       │   ├── Tombol: Valid / Tolak
│   │       │   └── Kolom catatan validasi
│   │       ├── Update Status Laporan
│   │       │   └── Dropdown status + catatan
│   │       ├── Riwayat Status (timeline)
│   │       └── Aksi Lanjutan
│   │           ├── Buat Jadwal Mediasi
│   │           └── Catat Tindak Lanjut
│   │
│   ├── Mediasi
│   │   ├── List Jadwal Mediasi
│   │   │   ├── Mendatang
│   │   │   ├── Berlangsung
│   │   │   └── Selesai
│   │   ├── Buat Jadwal Mediasi
│   │   │   ├── Pilih Laporan
│   │   │   ├── Tanggal & Waktu
│   │   │   ├── Lokasi
│   │   │   └── Peserta (korban, terlapor, orang tua)
│   │   └── Detail Mediasi
│   │       ├── Info jadwal
│   │       ├── Daftar peserta + status konfirmasi kehadiran
│   │       ├── Update status mediasi (ongoing/completed/cancelled)
│   │       └── Input hasil/kesepakatan mediasi
│   │
│   ├── Tindak Lanjut
│   │   ├── List tindak lanjut per laporan
│   │   └── Form catat tindak lanjut
│   │       ├── Pilih laporan
│   │       ├── Tindakan yang diambil
│   │       └── Catatan
│   │
│   ├── Riwayat Perilaku Siswa
│   │   ├── Cari siswa (by name/NIS)
│   │   ├── Data siswa: nama, kelas, kontak orang tua
│   │   └── Riwayat kasus: korban / terlapor / saksi
│   │
│   ├── Laporan & Rekapitulasi
│   │   ├── Rekap Harian / Mingguan / Bulanan
│   │   ├── Grafik per kategori perundungan
│   │   ├── Grafik per status
│   │   └── Export (PDF / Excel)
│   │
│   ├── Notifikasi
│   └── Profil & Pengaturan
│
├── KEPALA SEKOLAH
│   │
│   ├── Dashboard Utama
│   │   ├── Stat Cards (2×2 grid)
│   │   │   ├── Total Kasus
│   │   │   ├── Kasus Baru (bulan ini)
│   │   │   ├── Sedang Diproses
│   │   │   └── Selesai
│   │   ├── Grafik Donut: per Kategori Perundungan
│   │   └── Grafik Bar/Line: Tren Bulanan
│   │
│   ├── Rekapitulasi Kasus
│   │   ├── Filter: periode, kategori, status, kelas
│   │   ├── Tabel rekap
│   │   └── Export PDF/Excel
│   │
│   ├── Monitoring Penanganan
│   │   ├── Daftar kasus aktif
│   │   ├── Progress per kasus
│   │   └── Kasus yang memerlukan perhatian (lama tidak ada update)
│   │
│   ├── Laporan Kebijakan
│   │   ├── Ringkasan kasus per periode
│   │   ├── Analisis kategori dominan
│   │   └── Rekomendasi pencegahan
│   │
│   ├── Notifikasi
│   └── Profil & Pengaturan
│
├── ORANG TUA/WALI
│   │
│   ├── Beranda
│   │   ├── Notifikasi terbaru
│   │   └── Status keterlibatan anak
│   │
│   ├── Informasi Anak
│   │   ├── Data anak (nama, kelas)
│   │   ├── Status keterlibatan dalam kasus
│   │   ├── Ringkasan kasus (terbatas)
│   │   └── Catatan terbatas dari Guru BK
│   │
│   ├── Jadwal Mediasi
│   │   ├── List jadwal mendatang
│   │   ├── Detail jadwal: tanggal, waktu, lokasi, agenda
│   │   └── Konfirmasi Kehadiran
│   │       ├── Hadir
│   │       ├── Tidak Hadir
│   │       └── Ajukan Perubahan Jadwal
│   │
│   ├── Hasil Tindak Lanjut
│   │   ├── Ringkasan hasil mediasi
│   │   ├── Rekomendasi Guru BK
│   │   └── Status penyelesaian kasus
│   │
│   ├── Notifikasi
│   └── Profil & Pengaturan
│
└── ADMIN (Web Only)
    │
    ├── Dashboard Admin
    │   └── Ringkasan sistem
    │
    ├── Manajemen Pengguna
    │   ├── Daftar pengguna (filter by role)
    │   ├── Tambah / Edit / Hapus pengguna
    │   ├── Assign role
    │   └── Hubungkan orang tua-anak (parent_child)
    │
    ├── Audit Log
    │   ├── Daftar semua aktivitas sistem
    │   ├── Filter: action, model_type, user_id
    │   └── Detail log
    │
    └── Pengaturan Sistem
```

---

## 4. Navigasi per Platform & Role

### 4.1 Mobile — Bottom Navigation

| Role | Tab 1 | Tab 2 | Tab 3 | Tab 4 |
|---|---|---|---|---|
| Siswa | Beranda | Buat Laporan | Riwayat | Profil |
| Guru BK | Dashboard | Laporan | Mediasi | Profil |
| Orang Tua/Wali | Beranda | Info Anak | Jadwal | Profil |

> Kepala Sekolah dan Admin: tidak menggunakan bottom nav — primary via sidebar (web) atau hamburger menu (mobile).

### 4.2 Web — Sidebar Navigation

**Guru BK:**
```
Dashboard
Manajemen Laporan
  ├── Semua Laporan
  ├── Menunggu Validasi
  └── Laporan Aktif
Mediasi
Tindak Lanjut
Riwayat Perilaku Siswa
Laporan & Rekapitulasi
── divider ──
Notifikasi
Pengaturan
Logout
```

**Kepala Sekolah:**
```
Dashboard
Rekapitulasi Kasus
Monitoring Penanganan
Laporan Kebijakan
── divider ──
Notifikasi
Pengaturan
Logout
```

**Admin:**
```
Dashboard
Manajemen Pengguna
Audit Log
Pengaturan Sistem
── divider ──
Logout
```

### 4.3 Contextual Navigation

| Konteks | Aksi Kontekstual |
|---|---|
| Siswa: setelah kirim laporan | Simpan kode laporan, lihat status, kembali beranda |
| Siswa: detail laporan | Lihat riwayat status (timeline), hubungi Guru BK |
| Guru BK: detail laporan | Validasi, periksa bukti, update status, jadwal mediasi, tindak lanjut |
| Guru BK: selesai validasi | Buat jadwal mediasi (jika valid), arsip (jika ditolak) |
| Orang tua: notif mediasi | Buka jadwal, konfirmasi kehadiran |
| Kepsek: buka grafik | Filter periode, lihat detail rekap, export |

---

## 5. API Endpoint Mapping per Screen

### 5.1 Auth

| Screen | Method | Endpoint |
|---|---|---|
| Login | POST | `/api/login` |
| Register | POST | `/api/register` *(tambah)* |
| Verify OTP | POST | `/api/verify-otp` *(tambah)* |
| Resend OTP | POST | `/api/resend-otp` *(tambah)* |
| Logout | POST | `/api/logout` |

### 5.2 Siswa

| Screen | Method | Endpoint |
|---|---|---|
| Beranda (stats) | GET | `/api/dashboard/statistics` |
| Buat Laporan | POST | `/api/reports` |
| Daftar Laporan | GET | `/api/reports` |
| Detail Laporan | GET | `/api/reports/{id}` |
| Cek Status Publik | GET | `/api/reports/check?code=SPK-...` *(tambah)* |
| Notifikasi | GET | `/api/notifications` |
| Unread Count | GET | `/api/notifications/unread-count` |
| Tandai Dibaca | PUT | `/api/notifications/{id}/read` |
| Profil | GET | `/api/profile` |
| Edit Profil | PUT | `/api/profile` |
| Ubah Password | PUT | `/api/profile/password` |
| Simpan FCM Token | POST | `/api/profile/fcm-token` |

### 5.3 Guru BK

| Screen | Method | Endpoint |
|---|---|---|
| Dashboard (stats) | GET | `/api/dashboard/statistics` |
| Semua Laporan | GET | `/api/reports` |
| Detail Laporan | GET | `/api/reports/{id}` |
| Update Status | PUT | `/api/reports/{id}/status` |
| Validasi Laporan | POST | `/api/reports/{report}/validations` |
| Daftar Validasi | GET | `/api/reports/{report}/validations` |
| Buat Mediasi | POST | `/api/reports/{report}/mediations` |
| Daftar Mediasi | GET | `/api/reports/{report}/mediations` *(tambah)* |
| Detail Mediasi | GET | `/api/mediations/{id}` *(tambah)* |
| Update Status Mediasi | PUT | `/api/mediations/{id}/status` *(tambah)* |
| Catat Tindak Lanjut | POST | `/api/reports/{report}/follow-ups` |
| Daftar Tindak Lanjut | GET | `/api/reports/{report}/follow-ups` *(tambah)* |
| Export Rekap | GET | `/api/reports/export?format=pdf` *(tambah)* |
| Tren Dashboard | GET | `/api/dashboard/trend` *(tambah)* |

### 5.4 Kepala Sekolah

| Screen | Method | Endpoint |
|---|---|---|
| Dashboard (stats) | GET | `/api/dashboard/statistics` |
| Tren Grafik | GET | `/api/dashboard/trend` *(tambah)* |
| Semua Laporan (read) | GET | `/api/reports` |
| Export Rekap | GET | `/api/reports/export` *(tambah)* |

### 5.5 Orang Tua/Wali

| Screen | Method | Endpoint |
|---|---|---|
| Dashboard (stats anak) | GET | `/api/dashboard/statistics` |
| Laporan Anak | GET | `/api/reports` (filter by children) |
| Detail Laporan | GET | `/api/reports/{id}` |
| Jadwal Mediasi | GET | `/api/reports/{report}/mediations` *(tambah)* |
| Konfirmasi Kehadiran | PUT | `/api/mediations/{id}/participants/{userId}/confirm` *(tambah)* |
| Notifikasi | GET | `/api/notifications` |

### 5.6 Admin

| Screen | Method | Endpoint |
|---|---|---|
| Audit Log | GET | `/api/audit-logs` |
| Detail Audit Log | GET | `/api/audit-logs/{id}` |
| Daftar User | GET | `/api/admin/users` *(tambah)* |
| Tambah User | POST | `/api/admin/users` *(tambah)* |
| Edit User | PUT | `/api/admin/users/{id}` *(tambah)* |
| Hapus User | DELETE | `/api/admin/users/{id}` *(tambah)* |
| Assign Role | PUT | `/api/admin/users/{id}/role` *(tambah)* |
| Hubungkan Ortu-Anak | POST | `/api/admin/parent-child` *(tambah)* |

---

## 6. User Flow Lengkap

### 6.1 Auth — Registrasi + OTP

```
Buka App
    ↓
Screen Login
    ↓ tap "Daftar"
Screen Daftar
  Isi: nama, email, password, phone, role
    ↓ tap "Daftar"
  API: POST /api/register
    ↓ (email OTP terkirim)
Screen Verifikasi OTP
  Input 6 digit kode
    ↓
  [Benar]                [Salah]
     ↓                      ↓
Screen Verifikasi      State error merah
Berhasil               "Kode Verifikasi Salah"
     ↓                 Coba ulang / Kirim ulang
  tap "Mulai"
     ↓
Screen Login → masuk Dashboard
```

### 6.2 Siswa — Buat Laporan

```
Beranda Siswa
    ↓ tap "Buat Laporan Baru"
Step 1: Data Kejadian
  Pilih jenis, isi judul, tanggal, lokasi, kronologi, pihak terlibat
    ↓ tap "Lanjut"
Step 2: Bukti & Identitas
  Upload bukti (opsional)
  Pilih: dengan identitas / anonim
    ↓ tap "Lanjut"
Step 3: Review
  Cek semua data
    ↓ tap "Kirim Laporan"
  API: POST /api/reports
    ↓
Konfirmasi: tampil kode SPK-YYYY-NNNNN
    ↓
Laporan masuk ke antrian Guru BK
```

### 6.3 Guru BK — Validasi & Proses Laporan

```
Dashboard Guru BK
    ↓ lihat "Menunggu Validasi"
Manajemen Laporan → filter "Menunggu Validasi"
    ↓ tap laporan
Detail Laporan
  Baca kronologi, periksa pihak terlibat
    ↓ tap "Periksa Bukti"
  Preview foto/video/dokumen
    ↓ tap "Validasi"
  Pilih: Valid / Tolak + catatan
  API: POST /api/reports/{report}/validations
    ↓
  [Valid]                      [Tolak]
     ↓                            ↓
  Status → processing         Status → rejected
  Notifikasi → pelapor        Notifikasi → pelapor
     ↓
  Update Status → "Diproses"
  API: PUT /api/reports/{id}/status
     ↓
  Jadwal Mediasi (jika perlu)
  API: POST /api/reports/{report}/mediations
  FCM push → orang tua/wali
     ↓
  Setelah mediasi selesai → Tindak Lanjut
  API: POST /api/reports/{report}/follow-ups
     ↓
  Update Status → completed
  Notifikasi final → pelapor
```

### 6.4 Orang Tua — Konfirmasi Mediasi

```
Terima FCM Push: "Mediasi Dijadwalkan"
    ↓ tap notif
Dashboard Orang Tua
    ↓
Notifikasi → Jadwal Mediasi
    ↓
Detail Mediasi: tanggal, lokasi, agenda
    ↓
Konfirmasi Kehadiran
  API: PUT /api/mediations/{id}/participants/{userId}/confirm
  ├── Hadir → status confirmed
  ├── Tidak Hadir → status declined
  └── Ajukan Perubahan → notif ke Guru BK
```

### 6.5 Kepala Sekolah — Monitoring

```
Login → Dashboard Kepsek
    ↓
Stat Cards: Total / Baru / Diproses / Selesai
API: GET /api/dashboard/statistics
    ↓
Grafik Donut per Kategori
Grafik Tren Bulanan
API: GET /api/dashboard/trend
    ↓
Rekapitulasi Kasus (filter periode/kelas)
API: GET /api/reports + filter
    ↓
Export Laporan
API: GET /api/reports/export?format=pdf
```

---

## 7. Data Model Summary

```
users
  id, name, email, password, phone, avatar, fcm_token
  roles: [siswa | guru_bk | kepsek | ortu | admin]

parent_child (pivot)
  parent_id → users.id
  child_id  → users.id

reports
  id, report_code (SPK-YYYY-NNNNN)
  reporter_id → users.id
  title, description, category
  incident_location, incident_date
  status: [draft|submitted|waiting_validation|valid|processing
           |mediation|follow_up|completed|rejected]
  is_anonymous (boolean)

report_participants
  report_id, role (korban|terlapor|saksi)
  user_id (nullable), name, class_name, notes

evidences
  report_id, file_path, file_type, original_name

validations
  report_id, validator_id → users.id
  status (valid|rejected), notes

mediations
  report_id, mediator_id → users.id
  schedule_date, location
  status (scheduled|ongoing|completed|cancelled)
  result

mediation_participants
  mediation_id, user_id → users.id
  status (pending|confirmed|declined)

follow_ups
  report_id, executor_id → users.id
  action_taken, follow_up_date, notes

report_status_histories
  report_id, user_id → users.id
  status, notes, created_at

notifications
  user_id, title, body, type, reference_id, is_read

audit_logs
  user_id, action, model_type, model_id, changes (JSON), ip_address
```

---

## 8. Hak Akses Ringkas

| Fitur | Siswa | Guru BK | Kepsek | Ortu | Admin |
|---|---|---|---|---|---|
| Buat Laporan | ✅ | ❌ | ❌ | ❌ | ❌ |
| Laporan Anonim | ✅ | ❌ | ❌ | ❌ | ❌ |
| Lihat Laporan Sendiri | ✅ | — | — | — | — |
| Lihat Semua Laporan | ❌ | ✅ | ✅* | ❌ | ✅ |
| Lihat Laporan Anak | — | — | — | ✅ | — |
| Validasi Laporan | ❌ | ✅ | ❌ | ❌ | ✅ |
| Update Status | ❌ | ✅ | ❌ | ❌ | ✅ |
| Buat Mediasi | ❌ | ✅ | ❌ | ❌ | ✅ |
| Konfirmasi Kehadiran | ❌ | ❌ | ❌ | ✅ | ❌ |
| Catat Tindak Lanjut | ❌ | ✅ | ❌ | ❌ | ✅ |
| Lihat Statistik Global | ❌ | ✅ | ✅ | ❌ | ✅ |
| Export Rekap | ❌ | ✅ | ✅ | ❌ | ✅ |
| Lihat Audit Log | ❌ | ❌ | ❌ | ❌ | ✅ |
| Manajemen Pengguna | ❌ | ❌ | ❌ | ❌ | ✅ |
| Notifikasi Push (FCM) | ✅ | ✅ | ❌ | ✅ | ❌ |

> *Kepsek: read-only, tidak bisa edit atau mengubah status laporan

---

## 9. Prinsip Arsitektur Informasi SpeakUp

| Prinsip | Implementasi |
|---|---|
| **Mobile-First** | Desain utama untuk smartphone, web sebagai perluasan |
| **Role-Driven** | Setiap role punya navigasi, endpoint, dan data yang berbeda |
| **Privacy by Design** | Anonim → `reporter_id` disembunyikan; ortu hanya lihat anak sendiri |
| **Real-time Feedback** | FCM push + in-app notification untuk setiap event penting |
| **Progressive Disclosure** | Multi-step form pelaporan mengurangi cognitive load siswa |
| **Audit Trail** | Semua aksi penting tercatat di `audit_logs` |
| **Scalable API** | Satu backend Laravel melayani mobile dan web |

---

*Dokumen ini disusun sebagai bagian dari tugas mata kuliah Desain dan Pengembangan Sistem Informasi, Program Studi Sistem Informasi, Fakultas Sains dan Teknologi Terapan, Universitas Ahmad Dahlan Yogyakarta, Tahun Ajaran 2025/2026.*
