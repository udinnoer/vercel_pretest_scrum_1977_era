-- Jalankan ini di Supabase: buka project kamu → SQL Editor → New query → paste → Run

create extension if not exists pgcrypto;

create table if not exists results (
  id uuid primary key default gen_random_uuid(),
  nama text not null,
  nik text not null,
  divisi text not null,
  mode text not null check (mode in ('pre','post')),
  score int not null,
  total int not null,
  created_at timestamptz not null default now(),
  unique (nik, mode)  -- inti proteksi: 1 NIK hanya boleh 1 baris per mode
);

alter table results enable row level security;

-- Izinkan siapa pun (peserta, tanpa login) menyimpan hasil
create policy "Allow public insert" on results
  for insert
  to anon
  with check (true);

-- Izinkan siapa pun membaca data (dipakai untuk halaman Rekap)
-- Kalau mau rekap hanya bisa dilihat kamu sendiri, hapus policy ini
-- dan lihat data langsung lewat Supabase Table Editor.
create policy "Allow public select" on results
  for select
  to anon
  using (true);
