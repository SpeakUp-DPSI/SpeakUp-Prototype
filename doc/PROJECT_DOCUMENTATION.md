# Project Documentation
## SpeakUp — Sistem Pelaporan dan Penanganan Kasus Perundungan

**Platform:** Hybrid Mobile & Web
**Backend:** Laravel REST API (Sanctum + Spatie Permission) + Firebase Cloud Messaging
**Program Studi:** Sistem Informasi — Universitas Ahmad Dahlan Yogyakarta
**Mata Kuliah:** Desain dan Pengembangan Sistem Informasi
**Status Dokumen:** Living document — diperbarui seiring progres desain & development

---

## 1. Ringkasan Proyek

SpeakUp adalah aplikasi hybrid (mobile + web) untuk pelaporan dan penanganan kasus perundungan di lingkungan sekolah. Aplikasi menghubungkan lima peran pengguna dalam satu alur penanganan kasus end-to-end: siswa melapor → guru BK memvalidasi & menindaklanjuti → kepala sekolah memantau → orang tua terlibat dalam mediasi → admin mengelola akun dan akses.

**Prinsip utama:** privasi (opsi anonim), transparansi status laporan, dan proses penanganan yang terstruktur (validasi → mediasi → tindak lanjut → selesai).

---

## 2. Struktur Dokumentasi

Proyek ini didokumentasikan dalam tiga dokumen inti + satu folder aset:

| Dokumen | Isi |
|---|---|
| [`SRS.md`](./SRS.md) | Software Requirements Specification — kebutuhan fungsional (FR) per modul, kebutuhan non-fungsional, endpoint API, daftar endpoint yang masih perlu ditambahkan ke backend |
| [`Information_Architecture.md`](./Information_Architecture.md) | Sitemap lengkap per role, user flow, data model, hak akses (RBAC) |
| [`Design_System.md`](./Design_System.md) | Design tokens (warna, tipografi, spacing, komponen), berdasarkan UI yang sudah dibuat di Figma |
| `speakup-assets/` | Folder aset ilustrasi/icon/image, terorganisir per role sesuai sitemap |

**Cara pakai:** SRS menjawab "apa yang harus dibangun & endpoint apa yang dipanggil", Information Architecture menjawab "bagaimana alur & struktur navigasinya", Design System menjawab "seperti apa tampilannya secara konsisten".

---

## 3. Tech Stack

```
Frontend (Hybrid)
├── Mobile App   — Flutter (implementasi Modul 6, dsb.)
└── Web App      — React/Vue (responsif, role Kepsek & Admin diutamakan)

Backend
├── Framework    — Laravel REST API
├── Auth         — Laravel Sanctum (token-based)
├── RBAC         — Spatie Permission
└── Push Notif   — Firebase Cloud Messaging (FCM)

Database
└── MySQL — users, reports, evidences, validations, mediations,
            follow_ups, notifications, audit_logs
```

---

## 4. Peran Pengguna (Role)

| Role (Backend) | Platform Utama | Peran |
|---|---|---|
| `siswa` | Mobile & Web | Pelapor — buat laporan, pantau status, opsi anonim |
| `guru_bk` | Mobile & Web | Pengelola — validasi, mediasi, tindak lanjut |
| `kepsek` | Web (utama), Mobile read-only | Pemantau — statistik, tren, kebijakan |
| `ortu` | Mobile & Web | Pendamping — notifikasi, konfirmasi kehadiran mediasi |
| `admin` | Web only | Pengelola sistem — akun, hak akses, audit log |

Detail hak akses lengkap ada di `Information_Architecture.md` §8.

---

## 5. Status Desain UI (Figma)

Status per 1 Juli 2026, berdasarkan ekspor `UI_Design.zip`. Tabel ini mengikuti sitemap di `Information_Architecture.md` §3 — update manual setiap kali ada screen baru yang selesai didesain.

### 5.1 Auth — ✅ Selesai (6/6 screen)

| Screen | Status |
|---|---|
| Login | ✅ |
| Daftar (Signup) | ✅ |
| Verifikasi Akun (pilih metode) | ✅ |
| Verifikasi — Kode Salah | ✅ |
| Verifikasi Berhasil | ✅ |
| Pendaftaran Berhasil | ✅ |

### 5.2 Siswa — 🟡 Sebagian (5/8 screen)

| Screen | Status |
|---|---|
| Beranda | ✅ |
| Buat Laporan — Step 1 (Identitas & Data Kejadian) | ✅ |
| Buat Laporan — Step 2 (Bukti) | ✅ |
| Buat Laporan — Step 3 (Review & Kirim) | ✅ |
| Riwayat Laporan (list) | ✅ |
| Detail Laporan (timeline status) | ⬜ belum |
| Notifikasi | ⬜ belum |
| Profil | ⬜ belum |

### 5.3 Guru BK — 🟡 Sebagian (2/~10 screen)

| Screen | Status |
|---|---|
| Beranda / Dashboard | ✅ |
| Daftar Laporan (Manajemen Laporan) | ✅ |
| Detail Laporan + Validasi | ⬜ belum |
| Mediasi (list & buat jadwal & detail) | ⬜ belum |
| Tindak Lanjut | ⬜ belum |
| Riwayat Perilaku Siswa | ⬜ belum |
| Rekapitulasi & Export | ⬜ belum |
| Notifikasi | ⬜ belum |
| Profil & Pengaturan | ⬜ belum |

### 5.4 Kepala Sekolah — 🔴 Baru mulai (1/~5 screen)

| Screen | Status |
|---|---|
| Beranda / Dashboard | ✅ |
| Rekapitulasi Kasus (tabel + export) | ⬜ belum |
| Monitoring Penanganan | ⬜ belum |
| Laporan Kebijakan | ⬜ belum |
| Notifikasi & Profil | ⬜ belum |

### 5.5 Orang Tua/Wali — 🔴 Belum mulai (0 screen)

Seluruh screen (Beranda, Informasi Anak, Jadwal Mediasi, Konfirmasi Kehadiran, Hasil Tindak Lanjut) belum didesain.

### 5.6 Admin — 🔴 Belum mulai (0 screen)

Seluruh screen (Manajemen Pengguna, Assign Role, Audit Log) belum didesain — platform web only.

---

## 6. Temuan Desain Penting

Catatan dari review langsung terhadap Figma export (menggantikan asumsi versi lama `Design_System.md`):

- **Tema aktual adalah light theme dengan aksen biru** (bukan dark mode teal seperti draft awal). Warna primary terverifikasi dari sampling pixel: `#3069CD`.
- Ilustrasi karakter (siswa, guru, kepsek) dipakai konsisten di header/hero card tiap role — lihat `speakup-assets/illustrations/`.
- Status badge memakai warna semantik berbeda per konteks (contoh: "Diproses" biru di Siswa, oranye di beberapa konteks Guru BK/Kepsek) — perlu standardisasi satu mapping status→warna di `Design_System.md` supaya konsisten lintas role.
- Kepsek memakai header dark-navy gradient (beda dari Siswa/Guru BK yang light card) — kemungkinan pattern "role accent" yang perlu didefinisikan sebagai token terpisah.

*(Analisis warna & komponen lengkap sedang dituangkan ke `Design_System.md`.)*

---

## 7. Rencana Selanjutnya (Next Steps)

- [ ] Selesaikan update `Design_System.md` mengikuti UI aktual (warna, tipografi, komponen)
- [ ] Desain screen Kepsek yang tersisa: Rekapitulasi, Monitoring, Laporan Kebijakan
- [ ] Desain lengkap Guru BK: Detail Laporan, Mediasi, Tindak Lanjut, Rekapitulasi
- [ ] Mulai desain Orang Tua/Wali dan Admin
- [ ] Tambahkan endpoint backend yang masih ditandai *"Perlu Ditambah"* di `SRS.md` §6
- [ ] Isi `speakup-assets/` dengan ilustrasi final per role

---

## 8. Informasi Akademik

*Dokumen ini disusun sebagai bagian dari tugas mata kuliah Desain dan Pengembangan Sistem Informasi, Program Studi Sistem Informasi, Fakultas Sains dan Teknologi Terapan, Universitas Ahmad Dahlan Yogyakarta, Tahun Ajaran 2025/2026.*
