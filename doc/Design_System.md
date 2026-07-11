# Design System
## SpeakUp — Sistem Pelaporan dan Penanganan Kasus Perundungan
**Versi:** 3.0 (Revised — Light Theme & Role Accent)
**Tanggal:** Juli 2026
**Platform:** Hybrid Mobile & Web
**Program Studi:** Sistem Informasi — Universitas Ahmad Dahlan Yogyakarta

---

## 1. Filosofi Desain

SpeakUp menggunakan pendekatan **Mobile-First Light Theme** dengan prinsip:

- **Empati & Keamanan** — Menggunakan warna biru cerah yang memberikan kesan profesional, terpercaya, dan aman bagi siswa untuk melapor.
- **Bersih & Fokus** — Layout minimalis dengan kontras tinggi agar siswa dapat bernavigasi tanpa distraksi kognitif.
- **Mobile-First** — Didesain utama untuk smartphone (Siswa, Orang Tua, Guru), lalu diadaptasi secara responsif ke Web (Kepala Sekolah, Admin, Guru).
- **Konsisten** — Standardisasi komponen lintas platform dengan pemisahan aksen visual berbasis Role.

---

## 2. Brand Identity

### 2.1 Nama & Tagline
**SpeakUp** — *"Berani Bicara, Bersama Kita Selesaikan"*

### 2.2 Logo
- Wordmark **SpeakUp** + ikon gelembung bicara (speech bubble).
- Teks utama menggunakan warna Primary Blue (`#3069CD`) dengan ikon aksen pendukung.
- Minimum lebar logo: 100px (digital).

---

## 3. Color System

### 3.1 Background & Surface (Light Theme)

| Token | Hex | Penggunaan |
|---|---|---|
| `--color-bg-base` | `#F8FAFC` | Background utama aplikasi / halaman belakang |
| `--color-bg-surface` | `#FFFFFF` | Card default, modal, input background, top bar |
| `--color-bg-elevated` | `#F1F5F9` | Hover state, alternate row tabel, dropdown menu |
| `--color-bg-subtle` | `#E2E8F0` | Border light, disabled background |

### 3.2 Primary / Accent (Blue)

| Token | Hex | Penggunaan |
|---|---|---|
| `--color-primary` | `#3069CD` | Warna utama, tombol primer, ikon aktif, link highlight |
| `--color-primary-dark` | `#1E4BB0` | Hover / pressed state tombol primer |
| `--color-primary-dim` | `rgba(48,105,205,0.12)`| Background badge aktif, focus ring input, active list tile |
| `--color-primary-subtle` | `rgba(48,105,205,0.06)`| Background card hover, area dropzone file |

### 3.3 Role Accent (Header & Identity)

| Role | Token | Hex / Gradient | Penggunaan |
|---|---|---|---|
| Siswa / Guru | `--color-role-light` | `#FFFFFF` / Light Card | Header & background standar |
| Kepala Sekolah | `--color-role-dark` | Linear Gradient (`#1E293B` to `#0F172A`) | Dark-navy gradient khusus header dashboard Kepsek |

### 3.4 Text & Typography Colors

| Token | Hex | Penggunaan |
|---|---|---|
| `--color-text-primary` | `#0F172A` | Heading besar, body text utama, teks input |
| `--color-text-secondary` | `#475569` | Subtext, label form, placeholder text |
| `--color-text-tertiary` | `#94A3B8` | Helper text di bawah input, disabled text |
| `--color-text-accent` | `#3069CD` | Text link, nilai highlight, teks status aktif |
| `--color-text-inverse` | `#FFFFFF` | Teks di atas tombol primary atau dark header |

### 3.5 Border & Divider

| Token | Hex | Penggunaan |
|---|---|---|
| `--color-border` | `#E2E8F0` | Border card default, divider, garis pemisah |
| `--color-border-focus` | `#3069CD` | Border saat input dalam keadaan fokus / aktif |
| `--color-border-error` | `#DC2626` | Border input ketika terjadi error validasi |

### 3.6 Semantic / Status Colors (Standardized)

| Token | Hex | Penggunaan |
|---|---|---|
| `--color-success` | `#16A34A` | Status Selesai, Valid, Berhasil |
| `--color-success-dim` | `#DCFCE7` | Background badge sukses |
| `--color-warning` | `#EA580C` | Status Menunggu, Perlu Perhatian, Tindak Lanjut |
| `--color-warning-dim` | `#FFEDD5` | Background badge warning |
| `--color-danger` | `#DC2626` | Error, Ditolak, Aksi Hapus |
| `--color-danger-dim` | `#FEE2E2` | Background badge error |
| `--color-info` | `#2563EB` | Status Laporan Masuk, Diproses, Mediasi |
| `--color-info-dim` | `#DBEAFE` | Background badge info |

### 3.7 Status Badge Mapping (Unified Lintas Role)

| Status Backend | Label UI | Background Token | Text Color Token |
|---|---|---|---|
| `draft` | Draft | `--color-bg-elevated` | `--color-text-secondary` |
| `submitted` | Laporan Masuk | `--color-info-dim` | `--color-info` |
| `waiting_validation`| Menunggu Validasi | `--color-warning-dim` | `--color-warning` |
| `valid` | Valid | `--color-success-dim` | `--color-success` |
| `processing` | Diproses | `--color-info-dim` | `--color-info` |
| `mediation` | Mediasi | `--color-info-dim` | `--color-info` |
| `follow_up` | Tindak Lanjut | `--color-warning-dim` | `--color-warning` |
| `completed` | Selesai | `--color-success-dim` | `--color-success` |
| `rejected` | Ditolak | `--color-danger-dim` | `--color-danger` |

---

## 4. Typography

### 4.1 Font Family

```css
--font-primary: 'Inter', 'SF Pro Display', 'Roboto', sans-serif;
--font-mono:    'JetBrains Mono', monospace; /* Khusus Kode Laporan */
4.2 Type Scale (Mobile)TokenSizeWeightPenggunaan--text-xs11px400Caption, helper text kecil--text-sm13px400Label form, deskripsi sub-info--text-base15px400Body utama aplikasi--text-lg17px600Card title, section label--text-xl20px700Page title, heading utama modul--text-2xl24px700Greeting text ("Halo, Bagus! 👋")--text-3xl28px800Angka statistik dashboard besar4.3 Type Scale (Web — Desktop)TokenSizePenggunaan--text-base14pxIsi body text umum, sel pada tabel--text-lg16pxSubheading, label form desktop--text-xl20pxJudul section kontainer--text-2xl24pxJudul utama halaman web--text-3xl32pxAngka metrik statistik utama dashboard4.4 Kode LaporanCSSfont-family: var(--font-mono);
font-size: 13px;
letter-spacing: 0.08em;
color: var(--color-primary);
background: var(--color-primary-dim);
padding: 4px 10px;
border-radius: 6px;
font-weight: 600;
Contoh: SPK-2026-001425. Spacing SystemBerbasis kelipatan 4px untuk konsistensi layout responsif:TokenValuePenggunaan--space-14pxGap micro komponen (ikon ke teks)--space-28pxJarak elemen dalam satu rumpun form--space-312pxPadding komponen badge, gap internal kecil--space-416pxPadding default card, margin horizontal layar--space-520pxGap vertikal antar section konten--space-624pxPadding internal card besar / modal web--space-832pxJarak padding atas section utama halaman--space-1040pxBottom padding aman di atas batas bottom nav--space-1248pxTop safe area batas atas notch6. Border & Shadow6.1 Border RadiusTokenValuePenggunaan--radius-sm8pxInput field text, status badge, tombol kecil--radius-md12pxKomponen card utama mobile, tombol utama--radius-lg16pxKontainer web desktop, modal pop-up--radius-xl20pxCard hero bergradasi, greeting card banner--radius-full9999pxFoto profil avatar, pill filters, FAB6.2 Shadow (Light Theme — Flat Elegant Style)TokenValuePenggunaan--shadow-sm0 1px 2px rgba(15,23,42,0.04)Komponen input text field--shadow-md0 4px 12px rgba(15,23,42,0.05)Card list default aplikasi--shadow-lg0 8px 24px rgba(15,23,42,0.08)Modal dialog box, bottom sheet6.3 Border StyleCSS--border-default: 1px solid var(--color-border);       /* #E2E8F0 */
--border-focus:   1.5px solid var(--color-primary);    /* #3069CD */
--border-error:   1.5px solid var(--color-danger);     /* #DC2626` */
7. Component Library7.1 ButtonVarian Button:VarianBackgroundTextBorderShadowPrimary--color-primary--color-text-inverse—--shadow-smOutlinetransparent--color-primary--color-primary (1.5px)—Ghosttransparent--color-text-secondary——Danger--color-danger--color-text-inverse——Disabled--color-bg-subtle--color-text-tertiary——Ukuran Button (Mobile):btn-sm: height 36px, padding 8px 16px, font 13pxbtn-md (default): height 48px, padding 12px 24px, font 15px, --radius-mdbtn-lg: height 56px, padding 16px 32px, font 17px — tombol utama aksi bawah full-widthSemua tombol menggunakan radius --radius-md, durasi transisi hover 150ms ease, dan tingkat ketebalan teks font-weight: 600.7.2 Input / FormHeight (mobile):  52px
Background:       #FFFFFF
Border:           var(--border-default)
Border Radius:    var(--radius-sm)
Padding:          14px 16px
Font Size:        15px
Color:            var(--color-text-primary)
Placeholder:      var(--color-text-tertiary)

Focus State:
  border:         var(--border-focus)
  box-shadow:     0 0 0 3px var(--color-primary-dim)

Error State:
  border:         var(--border-error)
  + pesan error teks font 12px menggunakan warna --color-danger di bawah input text field
Label Input:font-size: 13px
font-weight: 600
color: var(--color-text-secondary)
margin-bottom: 6px
7.3 CardBackground:    var(--color-bg-surface)
Border:        1px solid var(--color-border)
Border Radius: var(--radius-md)   /* mobile */
              var(--radius-lg)   /* web desktop */
Padding:       16px              /* mobile */
              24px              /* web desktop */
Shadow:        var(--shadow-md)
Card Statistik (Dashboard Metrik):Latar Belakang: --color-bg-surface (#FFFFFF).Kontainer lingkaran ikon kecil di pojok menggunakan warna latar belakang --color-x-dim dengan warna ikon --color-x sesuai dengan kategori status.Angka Nilai: --text-3xl, font-weight: 800, --color-text-primary.Label Keterangan: --text-sm, --color-text-secondary.7.4 Badge / Status ChipPadding:       4px 10px
Border Radius: var(--radius-full)
Font Size:     11px
Font Weight:   700
Text Transform: uppercase
Pemetaan warna wajib mengacu secara penuh ke Status Badge Mapping (Bagian 3.7).7.5 Bottom Navigation Bar (Mobile)Height:        64px + safe area bottom padding
Background:    var(--color-bg-surface)
Border Top:    1px solid var(--color-border)
Jumlah Menu:   4 tab pilihan utama (Home, Laporan, Riwayat, Profil)

Kondisi Aktif (Active State):
  icon color:  var(--color-primary)
  label color: var(--color-primary)
  font weight: 600

Kondisi Tidak Aktif (Inactive State):
  icon color:  var(--color-text-tertiary)
  label color: var(--color-text-tertiary)
  font weight: 400

Label Font Size: 10px
Icon Size:       24px
7.6 Top App Bar (Mobile)Height:           56px + status bar safe area padding
Background:       var(--color-bg-surface)
Title Typography: --text-lg, font-weight: 700, color: --color-text-primary
Back Icon:        Posisi kiri, ukuran 24px, warna: --color-text-primary
Action Buttons:   Posisi kanan, batas maksimal 2 ikon (notifikasi, profil)
Border Bottom:    1px solid var(--color-border)
7.7 Sidebar / Drawer (Web Desktop)Width Konfigurasi: 260px (lebar penuh), 72px (mode ikon terlipat)
Background:        var(--color-bg-surface)
Border Right:      1px solid var(--color-border)

Logo Brand Area:
  height:          64px
  border-bottom:   1px solid var(--color-border)

Menu Item Navigation:
  height:          48px
  margin:          4px 12px
  padding:         0 16px
  border-radius:   var(--radius-md)
  
  Kondisi Aktif:
    background:    var(--color-primary-dim)
    color:         var(--color-primary)
    icon tint:     var(--color-primary)
    
  Kondisi Hover:
    background:    var(--color-bg-elevated)
    color:         var(--color-text-primary)
7.8 Table (Platform Web)Header Row background: var(--color-bg-elevated)
Header Typography:     13px, font-weight 600, color: --color-text-secondary, text-transform uppercase
Body Row Text:         14px, color: --color-text-primary
Row border bottom:     1px solid var(--color-border)
Row Hover State:       background: var(--color-primary-subtle)
Padding per cell:      14px 16px
7.9 Modal & Bottom SheetMobile View — Bottom Sheet:Animasi transisi: slide-up arah bawah ke atas
Background:       var(--color-bg-surface)
Border Radius:    24px 24px 0 0 (hanya sudut atas)
Top Drag Handle:  Dimensi 4px × 36px, warna --color-bg-subtle, rata tengah, margin-top 12px
Padding Konten:   0 16px 32px
Dimmer Overlay:   rgba(15, 23, 42, 0.4)
Web View — Dialog Modal:Dimmer Overlay:   rgba(15, 23, 42, 0.4)
Background:       var(--color-bg-surface)
Border Radius:    var(--radius-lg)
Border:           1px solid var(--color-border)
Maksimal Lebar:   480px (tipe konfirmasi), 640px (tipe form isian), 800px (tipe detail data)
Padding Konten:   32px
Shadow Efek:      var(--shadow-lg)
7.10 OTP Input ComponentKonfigurasi: 6 kotak horizontal terpisah sejajar
Spesifikasi tiap kotak individu:
  Width / Height: 48px × 56px
  Background:     var(--color-bg-surface)
  Border:         2px solid var(--color-border)
  Border Radius:  var(--radius-sm)
  Typography:     24px, font-weight 700, text-align center

Kotak Aktif (Focused State):
  Border Color:   var(--color-primary)
  Box Shadow:     0 0 0 3px var(--color-primary-dim)

Kotak Terisi (Filled State):
  Border Color:   var(--color-primary)
  Background:     var(--color-bg-base)
  
Jarak Antar Kotak: 8px
7.11 File Upload Component (Bukti Pelaporan)Batas Garis:      2px dashed var(--color-border)
Border Radius:    var(--radius-md)
Background:       var(--color-bg-base)
Padding Internal: 24px
Penyelarasan:     Text-align center

Hover / Drag-Over State:
  border-color:   var(--color-primary)
  background:     var(--color-primary-subtle)

Ikon Aksen Utama:  Ukuran 48px, warna: --color-primary
Judul Label:      --text-base, warna: --color-text-primary
Subtext Helper:   --text-sm, warna: --color-text-tertiary
                  Info: "JPG, PNG, MP4, PDF. Maks 10MB"

Preview File Terpilih:
  Kotak Thumbnail: Ukuran 64x64px, radius --radius-sm
  Label Nama File: Teks ukuran --text-sm, warna --color-text-secondary
  Tombol Hapus:    Ikon silang (×), warna --color-danger
7.12 Alert & Toast NotificationToast Banner (Mobile View):Posisi Muncul:    Fixed layout, mengambang tepat di atas bottom nav (bottom: 80px)
Dimensi Lebar:    Minimal 280px, Maksimal 90vw dari lebar layar total
Background:       var(--color-text-primary) /* Menggunakan warna kontras gelap untuk toast */
Teks Info:        Warna --color-bg-surface (#FFFFFF), ukuran --text-sm
Border Radius:    var(--radius-md)
Padding Internal: 12px 16px
Shadow Efek:      var(--shadow-lg)
Inline Alert Banner:Tipe AlertWarna Border-LeftLatar BelakangIkonInfo--color-info--color-info-dimℹ️Success--color-success--color-success-dim✅Warning--color-warning--color-warning-dim⚠️Danger--color-danger--color-danger-dim❌Spesifikasi Struktur:
  Border Default: 1px solid (sesuai rumpun tipe token di atas)
  Border-Left:    4px solid (sesuai rumpun tipe token di atas)
  Border Radius:  var(--radius-sm)
  Padding Konten: 12px 16px
  Typography:     14px, warna mengikuti --color-text-primary
8. Layout System8.1 Mobile Layout StructureScreen Width Target: 360px – 430px
Horizontal Padding:  16px (--space-4) kanan-kiri tepi layar
Safe Area Top:       Mengikuti tinggi status bar bawaan perangkat mobile
Safe Area Bottom:    Batas padding perangkat bawaan + 64px untuk tinggi bottom nav

Hierarki Struktur Tampilan Layar:
┌──────────────────┐
│  STATUS BAR      │  ← Batas Aman Atas Notch
│  TOP APP BAR     │  ← Tinggi Tetap 56px
├──────────────────┤
│                  │
│  CONTENT AREA    │  ← Bersifat scrollable, padding internal 16px
│                  │
├──────────────────┤
│  BOTTOM NAV      │  ← Tinggi Tetap 64px + Batas Aman Bawah Perangkat
└──────────────────┘
8.2 Web Layout Structure (Desktop View)Minimum Batas Lebar: 1024px
Komponen Sidebar:    Ukuran tetap 260px di sisi kiri halaman layar

Skema Pembagian Tata Letak Web:
┌──────────┬───────────────────────────────┐
│          │  TOP BAR UTAMA (Tinggi 64px)   │
│ SIDEBAR  ├───────────────────────────────┤
│ NAVIGASI │  MAIN HUB CONTENT AREA        │
│ (260px)  │  Batas Maksimal Lebar: 1200px │
│          │  Padding Konten: 32px         │
│          │                               │
└──────────┴───────────────────────────────┘
9. Screen-Specific Design Notes (Re-mapped)9.1 Alur Autentikasi (Login & Registrasi)Halaman Login dan Registrasi didesain menggunakan latar belakang bersih --color-bg-base (#F8FAFC).Form kontainer utama dibungkus dalam card putih --color-bg-surface dengan kelengkungan sudut besar --radius-xl (20px) serta dibekali efek bayangan halus --shadow-md.Tombol aksi utama masuk menggunakan varian Primary Blue Button berdimensi penuh (full-width long button).9.2 Beranda & Dashboard UtamaSiswa View: Menampilkan struktur Greeting Banner Card dengan warna cerah netral yang menampilkan sapaan nama ("Halo, Bagus! 👋") berukuran --text-2xl tebal, serta menampilkan barisan horizontal deretan akumulasi statistik laporan kasus.Kepala Sekolah View: Bagian struktur atas berupa komponen kontainer bergradasi gelap Dark Navy Gradient (--color-role-dark) yang menampilkan ringkasan performa sistem secara elegan, berkontras dengan teks berwarna putih.10. Iconography & AccessibilityPilihan Library: Diwajibkan menggunakan set ikon Lucide Icons (varian desain outline/garis tipis).Aksesibilitas Kontras: Seluruh paduan teks gelap di atas latar terang wajib memenuhi rasio standar kontras minimal 4.5:1 (WCAG AA) demi kemudahan pembacaan bagi pengguna.Touch Target Target: Seluruh area komponen interaktif yang dapat ditekan (tombol/tab) wajib memiliki ukuran minimal area sentuh 48×48dp guna mencegah salah tekan pada perangkat berlayar sentuh.Dokumen ini disusun sebagai bagian dari tugas mata kuliah Desain dan Pengembangan Sistem Informasi, Program Studi Sistem Informasi, Fakultas Sains dan Teknologi Terapan, Universitas Ahmad Dahlan Yogyakarta, Tahun Ajaran 2025/2026.