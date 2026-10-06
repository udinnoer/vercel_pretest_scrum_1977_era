-- MIGRASI TAMBAHAN #4 — jalankan ini di SQL Editor Supabase.
-- Fitur: multi-event. Semua tabel lama (results, sessions, groups) dikaitkan ke tabel events baru.
-- Aman dijalankan berkali-kali (pakai IF NOT EXISTS / IF EXISTS) dan tidak menghapus data lama.

-- 1) Tabel events
create table if not exists events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  speaker text not null,
  start_date date not null,
  end_date date not null,
  is_active boolean not null default false,
  created_at timestamptz not null default now()
);

alter table events enable row level security;

drop policy if exists "Allow public all events" on events;
create policy "Allow public all events" on events
  for all to anon using (true) with check (true);

-- 2) Pastikan tabel sessions & groups ada (untuk jaga-jaga kalau migration-2/3 belum pernah jalan)
create table if not exists sessions (
  id uuid primary key default gen_random_uuid(),
  nik text not null,
  nama text not null,
  divisi text not null,
  mode text not null check (mode in ('pre','post')),
  status text not null default 'in_progress' check (status in ('in_progress','done')),
  started_at timestamptz not null default now(),
  finished_at timestamptz
);
alter table sessions enable row level security;
drop policy if exists "Allow public insert sessions" on sessions;
create policy "Allow public insert sessions" on sessions for insert to anon with check (true);
drop policy if exists "Allow public update sessions" on sessions;
create policy "Allow public update sessions" on sessions for update to anon using (true) with check (true);
drop policy if exists "Allow public select sessions" on sessions;
create policy "Allow public select sessions" on sessions for select to anon using (true);

create table if not exists groups (
  id uuid primary key default gen_random_uuid(),
  nik text not null,
  nama text not null,
  divisi text not null,
  group_no int not null,
  created_at timestamptz not null default now()
);
alter table groups enable row level security;
drop policy if exists "Allow public all groups" on groups;
create policy "Allow public all groups" on groups for all to anon using (true) with check (true);

alter table results add column if not exists answers jsonb not null default '[]'::jsonb;

-- 3) Tambah kolom event_id ke results, sessions, groups
alter table results add column if not exists event_id uuid references events(id);
alter table sessions add column if not exists event_id uuid references events(id);
alter table groups add column if not exists event_id uuid references events(id);

-- 4) Ganti batasan unik di results dari (nik, mode) menjadi (nik, mode, event_id)
--    supaya NIK yang sama BOLEH ikut pretest/posttest lagi di event yang berbeda.
--    Data lama (event_id masih NULL) tetap aman karena Postgres menganggap NULL selalu "berbeda"
--    pada unique constraint, jadi tidak akan bentrok dengan data baru yang sudah ada event_id-nya.
alter table results drop constraint if exists results_nik_mode_key;
alter table results drop constraint if exists results_nik_mode_event_key;
alter table results add constraint results_nik_mode_event_key unique (nik, mode, event_id);

-- Selesai. Setelah ini:
-- - Buat event pertama dari halaman admin.html (panel "Kelola Event"), lalu klik "Jadikan Aktif".
-- - index.html hanya akan menerima pretest/posttest kalau ada 1 event yang sedang aktif.
-- - Data yang sudah ada sebelum migrasi ini akan muncul sebagai "Data Tanpa Event" di dashboard/kelompok.
