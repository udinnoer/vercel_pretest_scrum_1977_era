// Isi dengan URL & key dari project Supabase kamu:
// Supabase dashboard → Project Settings → Data API
// - SUPABASE_URL: bagian "Project URL"
// - SUPABASE_ANON_KEY: pakai key "Publishable" (sb_publishable_...),
//   BUKAN yang "Secret" (sb_secret_...). Kalau project lama masih
//   pakai istilah "anon public key" (format eyJ...), itu juga masih bisa dipakai.
const SUPABASE_URL = "https://icqbcpfysslnrdalsrsv.supabase.co"; // contoh: https://abcxyzcompany.supabase.co
const SUPABASE_ANON_KEY = "sb_publishable_EVEmDwfn5RNAb4fQ_PBhqw_-zlqrITQ";

// Password untuk login admin/dashboard/kelompok (disimpan sebagai hash SHA-256, bukan teks polos).
// Default saat ini: scrum2026
// Cara ganti password: buka Console browser (F12) di halaman mana saja, lalu jalankan:
//   crypto.subtle.digest("SHA-256", new TextEncoder().encode("password-baru-kamu"))
//     .then(b => console.log([...new Uint8Array(b)].map(x=>x.toString(16).padStart(2,"0")).join("")))
// Salin hasilnya (64 karakter) ke ADMIN_PASSWORD_HASH di bawah ini.
const ADMIN_PASSWORD_HASH = "536e024eabcff064995fe1eb23c4b8dbe40d81a0b4f555c4c24487ad6386819e";
