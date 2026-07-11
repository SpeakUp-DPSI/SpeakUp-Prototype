<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Dibutuhkan supaya Flutter Web (browser) bisa memanggil API Laravel
    | yang berjalan di origin/port berbeda. Mobile app (Android/iOS) TIDAK
    | butuh ini karena bukan browser — CORS cuma masalah web.
    |
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    // Untuk development: izinkan semua origin dulu supaya tidak terblokir
    // saat testing dari berbagai port (flutter run -d chrome pakai port acak).
    // Untuk production: ganti '*' dengan domain web app kamu yang sebenarnya,
    // misal ['https://speakup.app'].
    'allowed_origins' => ['*'],

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    // Wajib false kalau allowed_origins masih '*' (browser akan menolak
    // kombinasi credentials:true + origin:*)
    'supports_credentials' => false,
];