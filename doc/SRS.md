# Software Requirements Specification (SRS)
## SpeakUp — Sistem Pelaporan dan Penanganan Kasus Perundungan
**Versi:** 2.0 (Revised)
**Tanggal:** Juli 2026
**Platform:** Hybrid Mobile & Web
**Backend:** Laravel (REST API) + Firebase Push Notification
**Program Studi:** Sistem Informasi — Universitas Ahmad Dahlan Yogyakarta
**Mata Kuliah:** Desain dan Pengembangan Sistem Informasi
**Dosen Pengampu:** Farid Suryanto, S.Pd., MT.

---

## 1. Pendahuluan

### 1.1 Tujuan Dokumen
Dokumen SRS ini mendefinisikan seluruh kebutuhan fungsional dan non-fungsional dari aplikasi **SpeakUp** versi hybrid (mobile + web). Dokumen ini diselaraskan dengan struktur API Laravel backend yang telah ada dan desain UI mobile-first yang telah dirancang.

### 1.2 Ruang Lingkup Sistem
SpeakUp adalah aplikasi **hybrid (mobile & web)** dengan backend Laravel REST API yang memfasilitasi:
- Pelaporan kasus perundungan oleh siswa (termasuk opsi anonim)
- Validasi dan penanganan laporan oleh Guru BK
- Monitoring statistik kasus oleh Kepala Sekolah
- Keterlibatan Orang Tua/Wali dalam proses mediasi
- Notifikasi real-time via Firebase Cloud Messaging (FCM)
- Pengelolaan akun dan hak akses oleh Admin

### 1.3 Arsitektur Sistem

```
┌─────────────────────────────────────────┐
│         FRONTEND (Hybrid)               │
│  Mobile App (Flutter/React Native)      │
│  Web App (React/Vue)                    │
└────────────────┬────────────────────────┘
                 │ HTTPS / REST API
┌────────────────▼────────────────────────┐
│      BACKEND (Laravel API)              │
│  Auth: Laravel Sanctum                  │
│  Role: Spatie Permission                │
│  Push: Firebase Cloud Messaging         │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│           DATABASE (MySQL)              │
│  users, reports, evidences,             │
│  validations, mediations, follow_ups,   │
│  notifications, audit_logs              │
└─────────────────────────────────────────┘
```

### 1.4 Definisi dan Singkatan

| Istilah | Keterangan |
|---|---|
| SRS | Software Requirements Specification |
| SpeakUp | Nama aplikasi sistem pelaporan perundungan |
| Guru BK | Guru Bimbingan dan Konseling |
| NIS | Nomor Induk Siswa |
| Kode Laporan | Kode unik format `SPK-YYYY-NNNNN` dihasilkan sistem |
| Anonim | Pelaporan tanpa mencantumkan identitas pelapor |
| Mediasi | Pertemuan antara pihak yang terlibat untuk menyelesaikan kasus |
| FCM | Firebase Cloud Messaging — layanan push notification |
| OTP | One-Time Password — kode verifikasi akun 6 digit |
| Sanctum | Laravel Sanctum — autentikasi berbasis token API |

### 1.5 Referensi
- Desain UI SpeakUp (Figma) — mobile-first dark theme
- Backend Laravel SpeakUp Prototype (`routes/api.php`, Controllers, Models)
- Dokumen Arsitektur Informasi SpeakUp v1.0

---

## 2. Deskripsi Umum Sistem

### 2.1 Platform
SpeakUp dikembangkan sebagai aplikasi **hybrid** yang dapat diakses melalui:
- **Mobile App** — tampilan utama, mobile-first dark theme
- **Web App** — versi responsif untuk akses melalui browser desktop/tablet

Keduanya mengonsumsi backend yang sama melalui REST API Laravel.

### 2.2 Karakteristik Pengguna

| Role (Backend) | Tampilan | Peran | Kebutuhan Utama |
|---|---|---|---|
| `siswa` | Mobile & Web | Pelapor | Membuat laporan, pantau status, akses anonim |
| `guru_bk` | Mobile & Web | Pengelola | Validasi, mediasi, tindak lanjut, rekapitulasi |
| `kepsek` | Web (utama) | Pemantau | Statistik, tren, monitoring, kebijakan |
| `ortu` | Mobile & Web | Pendamping | Notifikasi, jadwal mediasi, konfirmasi kehadiran |
| `admin` | Web | Pengelola Sistem | Manajemen akun, hak akses, audit log |

### 2.3 Asumsi dan Ketergantungan
- Backend Laravel tersedia dan dapat diakses via HTTPS
- Firebase project aktif untuk push notification (FCM)
- Pengguna memiliki smartphone atau browser modern
- Email aktif diperlukan untuk proses verifikasi OTP saat registrasi
- File upload (bukti) disimpan di storage Laravel (lokal atau cloud)

---

## 3. Kebutuhan Fungsional

### 3.1 Autentikasi & Akun

#### FR-AUTH-01: Login
- `POST /api/login`
- Input: `email`, `password`
- Output: token Sanctum + data user + role
- Error: kredensial salah → pesan "Email atau password tidak sesuai"

#### FR-AUTH-02: Registrasi (Perlu Ditambah ke Backend)
- `POST /api/register`
- Input: `name`, `email`, `password`, `password_confirmation`, `phone`, `role`
- Sistem generate OTP 6 digit dan kirim ke email
- Akun belum aktif sebelum verifikasi OTP

#### FR-AUTH-03: Verifikasi OTP (Perlu Ditambah ke Backend)
- `POST /api/verify-otp`
- Input: `email`, `otp`
- Jika benar → akun diaktifkan, tampilkan halaman "Pendaftaran Berhasil"
- Jika salah → tampilkan error "Kode Verifikasi Salah" (sesuai UI)
- OTP dapat di-resend via `POST /api/resend-otp`

#### FR-AUTH-04: Logout
- `POST /api/logout` (auth:sanctum)
- Hapus token Sanctum saat ini

#### FR-AUTH-05: Profil Pengguna
- `GET /api/profile` — lihat profil + role
- `PUT /api/profile` — update `name`, `phone`, `avatar`
- `PUT /api/profile/password` — ubah password (validasi `current_password`)
- `POST /api/profile/fcm-token` — simpan FCM token untuk push notification

---

### 3.2 Laporan (Reports)

#### FR-RPT-01: Buat Laporan
- `POST /api/reports` (auth:sanctum, role: semua)
- Input:
  - `title` (required) — judul singkat laporan
  - `description` (required) — kronologi kejadian
  - `category` — jenis perundungan: `fisik`, `verbal`, `sosial`, `cyberbullying`
  - `incident_location` — lokasi kejadian
  - `incident_date` — tanggal kejadian
  - `is_anonymous` (boolean) — jika `true`, identitas pelapor disembunyikan
  - `participants[]` — array korban/terlapor/saksi dengan field: `role` (korban/terlapor/saksi), `name`, `class_name`, `notes`
  - `evidences[]` — file bukti (foto/video/dokumen)
- Output: data laporan + `report_code` (format `SPK-YYYY-NNNNN`)
- Status awal: `submitted`

#### FR-RPT-02: Daftar Laporan
- `GET /api/reports` (auth:sanctum)
- Role `siswa` → hanya laporan milik sendiri
- Role `guru_bk`, `kepsek`, `admin` → semua laporan
- Role `ortu` → laporan anak-anak yang terhubung (`parent_child`)
- Filter tersedia: `status`, `category`, `date_from`, `date_to`
- Pagination dengan `limit` dan `page`

#### FR-RPT-03: Detail Laporan
- `GET /api/reports/{id}` (auth:sanctum)
- Load relasi: `participants`, `statusHistories`, `validations.validator`, `mediations.mediator`, `followUps.executor`, `evidences`
- Role `siswa` → hanya bisa akses laporan sendiri (403 jika bukan miliknya)

#### FR-RPT-04: Update Status Laporan
- `PUT /api/reports/{id}/status` (auth:sanctum, role: `guru_bk`, `admin`)
- Input: `status`, `notes`
- Status valid: `draft` → `submitted` → `waiting_validation` → `valid` / `rejected` → `processing` → `mediation` → `follow_up` → `completed`
- Setiap update otomatis membuat entri `report_status_histories`

#### FR-RPT-05: Cek Status via Kode Laporan (Publik)
- `GET /api/reports/check?code={report_code}` **(Perlu Ditambah ke Backend)**
- Tanpa auth — gunakan `report_code`
- Output terbatas: status, tahap penanganan, catatan umum, riwayat status (tanpa identitas pihak)

---

### 3.3 Validasi Laporan

#### FR-VAL-01: Buat Validasi
- `POST /api/reports/{report}/validations` (role: `guru_bk`, `admin`)
- Input: `status` (`valid` / `rejected`), `notes`
- Jika `valid` → status laporan otomatis jadi `processing`
- Jika `rejected` → status laporan otomatis jadi `rejected`
- Otomatis buat notifikasi ke pelapor + FCM push notification

#### FR-VAL-02: Daftar Validasi
- `GET /api/reports/{report}/validations`
- Menampilkan riwayat validasi beserta data validator

---

### 3.4 Mediasi

#### FR-MED-01: Buat Jadwal Mediasi
- `POST /api/reports/{report}/mediations` (role: `guru_bk`, `admin`)
- Input: `schedule_date`, `location`
- Otomatis update status laporan ke `mediation`
- Otomatis buat notifikasi + FCM push ke pelapor

#### FR-MED-02: Daftar Mediasi per Laporan
- `GET /api/reports/{report}/mediations` **(Perlu Ditambah ke Backend)**

#### FR-MED-03: Detail Mediasi
- `GET /api/mediations/{id}` **(Perlu Ditambah ke Backend)**
- Load: `mediator`, `participants`, `report`

#### FR-MED-04: Update Status Mediasi
- `PUT /api/mediations/{id}/status` **(Perlu Ditambah ke Backend)**
- Input: `status` (`scheduled`, `ongoing`, `completed`, `cancelled`), `result`
- Jika `completed` → status laporan otomatis ke `follow_up`

#### FR-MED-05: Konfirmasi Kehadiran (Orang Tua/Wali)
- `PUT /api/mediations/{id}/participants/{userId}/confirm` **(Perlu Ditambah ke Backend)**
- Input: `status` (`hadir`, `tidak_hadir`, `minta_ubah`)

---

### 3.5 Tindak Lanjut (Follow-Up)

#### FR-FUP-01: Catat Tindak Lanjut
- `POST /api/reports/{report}/follow-ups` (role: `guru_bk`, `admin`)
- Input: `action_taken`, `notes`
- Otomatis buat notifikasi + FCM push ke pelapor

#### FR-FUP-02: Daftar Tindak Lanjut
- `GET /api/reports/{report}/follow-ups` **(Perlu Ditambah ke Backend)**

---

### 3.6 Notifikasi

#### FR-NOT-01: Daftar Notifikasi
- `GET /api/notifications` — list notifikasi pengguna, paginate

#### FR-NOT-02: Jumlah Belum Dibaca
- `GET /api/notifications/unread-count` → `{ count: N }`

#### FR-NOT-03: Tandai Dibaca
- `PUT /api/notifications/{id}/read` — satu notifikasi
- `PUT /api/notifications/read-all` — semua notifikasi

#### FR-NOT-04: Push Notification (FCM)
- Sistem kirim FCM push saat: laporan divalidasi, mediasi dijadwalkan, tindak lanjut dicatat
- FCM token disimpan via `POST /api/profile/fcm-token`

---

### 3.7 Dashboard & Statistik

#### FR-DSH-01: Statistik Dashboard
- `GET /api/dashboard/statistics` (auth:sanctum)
- Response berbeda per role:
  - `siswa` → statistik laporan sendiri
  - `ortu` → statistik laporan anak-anak
  - `guru_bk`, `kepsek`, `admin` → statistik semua laporan
- Berisi: total, hari ini, bulan ini, per-status, per-kategori, laporan terbaru, notifikasi belum dibaca

#### FR-DSH-02: Statistik Tren (Perlu Ditambah ke Backend)
- `GET /api/dashboard/trend?period=daily|monthly` (role: `guru_bk`, `kepsek`, `admin`)
- Untuk grafik tren pada dashboard Kepsek

#### FR-DSH-03: Rekapitulasi Export (Perlu Ditambah ke Backend)
- `GET /api/reports/export?format=pdf|excel` (role: `guru_bk`, `admin`)

---

### 3.8 Audit Log

#### FR-AUD-01: Daftar Audit Log
- `GET /api/audit-logs` (role: `admin` only)
- Filter: `action`, `model_type`, `user_id`

#### FR-AUD-02: Detail Audit Log
- `GET /api/audit-logs/{id}` (role: `admin` only)

---

### 3.9 Admin — Manajemen Pengguna (Perlu Ditambah ke Backend)

#### FR-ADM-01: Daftar Pengguna
- `GET /api/admin/users`

#### FR-ADM-02: Buat/Edit/Hapus Pengguna
- `POST /api/admin/users`
- `PUT /api/admin/users/{id}`
- `DELETE /api/admin/users/{id}`

#### FR-ADM-03: Assign Role
- `PUT /api/admin/users/{id}/role`
- Assign role: `siswa`, `guru_bk`, `kepsek`, `ortu`, `admin`

#### FR-ADM-04: Hubungkan Orang Tua-Anak
- `POST /api/admin/parent-child` → hubungkan `parent_id` dan `child_id`

---

## 4. Alur Status Laporan (Sesuai Backend)

```
submitted
    ↓
waiting_validation
    ↓
valid ───────── rejected
    ↓
processing
    ↓
mediation
    ↓
follow_up
    ↓
completed
```

| Status (Backend) | Label UI | Aktor |
|---|---|---|
| `draft` | Draft | Siswa (belum kirim) |
| `submitted` | Laporan Masuk | Sistem (saat kirim) |
| `waiting_validation` | Menunggu Validasi | Guru BK |
| `valid` | Valid | Guru BK |
| `rejected` | Ditolak | Guru BK |
| `processing` | Diproses | Guru BK |
| `mediation` | Mediasi | Guru BK |
| `follow_up` | Tindak Lanjut | Guru BK |
| `completed` | Selesai | Guru BK |

---

## 5. Kebutuhan Non-Fungsional

### 5.1 Keamanan
- Semua endpoint (kecuali login, register, cek status publik) dilindungi `auth:sanctum`
- Role-based access control via Spatie Permission
- HTTPS wajib untuk semua komunikasi
- Laporan anonim: `is_anonymous = true` → `reporter_id` disembunyikan dari response non-admin
- OTP berlaku 10 menit, satu kali pakai
- Audit log mencatat semua aksi penting (validasi, mediasi, update profil, ganti password)

### 5.2 Performa
- Response API ≤ 500ms pada kondisi normal
- Upload file bukti maks 10 MB per file, format: jpg, png, mp4, pdf, docx
- Pagination default 20 item per halaman
- Dashboard statistik dapat di-cache dengan TTL 5 menit

### 5.3 Notifikasi
- FCM push notification terkirim dalam ≤ 5 detik setelah event terjadi
- Fallback: notifikasi tersimpan di tabel `notifications` dan bisa dipoll via `GET /api/notifications`

### 5.4 Kompatibilitas Hybrid
- Mobile: Android (min API 21 / Android 5.0), iOS (min iOS 12)
- Web: Chrome, Firefox, Safari, Edge versi terbaru
- API response konsisten JSON untuk semua platform

### 5.5 Privasi
- `is_anonymous = true`: `reporter_id` dan data identitas pelapor tidak dikembalikan ke role selain `guru_bk` dan `admin`
- Orang tua hanya melihat data laporan anak yang terhubung via `parent_child`
- Siswa hanya bisa melihat laporan milik sendiri

---

## 6. Endpoint yang Perlu Ditambah ke Backend

| Endpoint | Method | Keterangan |
|---|---|---|
| `/api/register` | POST | Registrasi akun baru |
| `/api/verify-otp` | POST | Verifikasi OTP |
| `/api/resend-otp` | POST | Kirim ulang OTP |
| `/api/reports/check` | GET | Cek status via kode laporan (publik) |
| `/api/reports/{id}/follow-ups` | GET | Daftar tindak lanjut |
| `/api/reports/{id}/mediations` | GET | Daftar mediasi per laporan |
| `/api/mediations/{id}` | GET | Detail mediasi |
| `/api/mediations/{id}/status` | PUT | Update status mediasi |
| `/api/mediations/{id}/participants/{userId}/confirm` | PUT | Konfirmasi kehadiran |
| `/api/dashboard/trend` | GET | Data tren untuk grafik |
| `/api/reports/export` | GET | Export rekap PDF/Excel |
| `/api/admin/users` | GET/POST | Manajemen pengguna |
| `/api/admin/users/{id}` | PUT/DELETE | Edit/hapus pengguna |
| `/api/admin/users/{id}/role` | PUT | Assign role |
| `/api/admin/parent-child` | POST | Hubungkan orang tua-anak |

---

*Dokumen ini disusun sebagai bagian dari tugas mata kuliah Desain dan Pengembangan Sistem Informasi, Program Studi Sistem Informasi, Fakultas Sains dan Teknologi Terapan, Universitas Ahmad Dahlan Yogyakarta, Tahun Ajaran 2025/2026.*
