-- MIGRASI #5 — soal pretest/posttest disimpan di database, per event.
-- Jalankan SETELAH migration-4-events-login.sql. Aman dijalankan ulang.

create table if not exists questions (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events(id) on delete cascade,
  position int not null,
  cat text not null,
  q text not null,
  opts jsonb not null,
  correct int not null,
  note text not null default '',
  created_at timestamptz not null default now()
);
create index if not exists questions_event_pos_idx on questions(event_id, position);

alter table questions enable row level security;
drop policy if exists "Allow public all questions" on questions;
create policy "Allow public all questions" on questions
  for all to anon using (true) with check (true);

-- Seed: salin 15 soal standar ke setiap event yang BELUM punya soal.
insert into questions (event_id, position, cat, q, opts, correct, note)
select e.id, s.position, s.cat, s.q, s.opts, s.correct, s.note
from events e
cross join (values
  (1, $q$Fondasi Agile$q$, $q$Agile Manifesto lahir dari diskusi 17 praktisi software pada tahun berapa?$q$, $q$["1999","2001","2005","2010"]$q$::jsonb, 1, $q$Agile Manifesto disepakati tahun 2001 oleh 17 praktisi software.$q$),
  (2, $q$Fondasi Agile$q$, $q$Manakah pernyataan berikut yang justru BERTENTANGAN dengan nilai inti Agile Manifesto?$q$, $q$["Individu dan interaksi lebih diutamakan daripada proses dan tools","Working software lebih diutamakan daripada dokumentasi lengkap","Mengikuti rencana lebih diutamakan daripada merespons perubahan","Kolaborasi dengan pelanggan lebih diutamakan daripada negosiasi kontrak"]$q$::jsonb, 2, $q$Nilai aslinya justru sebaliknya: merespons perubahan lebih diutamakan daripada mengikuti rencana.$q$),
  (3, $q$Mengenal Scrum$q$, $q$Kenapa Scrum dianggap cocok untuk pengembangan software?$q$, $q$["Karena semua requirement bisa didefinisikan lengkap di awal","Karena kompleksitas & ketidakpastian teknis produk digital tinggi sehingga perlu iterasi","Karena tim boleh bekerja tanpa koordinasi","Karena tidak butuh feedback dari user"]$q$::jsonb, 1, $q$Scrum dirancang untuk menangani kompleksitas & ketidakpastian teknis lewat siklus iteratif.$q$),
  (4, $q$Mengenal Scrum$q$, $q$Ada berapa pilar (pillars) dalam Scrum?$q$, $q$["2","3","4","5"]$q$::jsonb, 1, $q$Tiga pilar Scrum: Transparency, Inspection, Adaptation.$q$),
  (5, $q$Mengenal Scrum$q$, $q$Berikut ini termasuk nilai (values) Scrum, KECUALI:$q$, $q$["Commitment","Courage","Focus","Efficiency"]$q$::jsonb, 3, $q$Lima nilai Scrum: Commitment, Courage, Focus, Openness, Respect — Efficiency bukan salah satunya.$q$),
  (6, $q$Scrum Actors$q$, $q$Siapa yang bertanggung jawab memaksimalkan nilai produk dan mengelola Product Backlog?$q$, $q$["Scrum Master","Product Owner","Developers","Stakeholder"]$q$::jsonb, 1, $q$Product Owner memegang akuntabilitas atas Product Backlog dan nilai produk.$q$),
  (7, $q$Scrum Actors$q$, $q$Apa peran utama Scrum Master dalam tim?$q$, $q$["Menulis kode aplikasi","Menjadi servant leader yang memastikan tim memahami & menjalankan Scrum dengan baik","Menentukan prioritas Product Backlog","Menyetujui anggaran proyek"]$q$::jsonb, 1, $q$Scrum Master adalah servant leader — memfasilitasi, bukan mengelola backlog atau menulis kode.$q$),
  (8, $q$BRD & Product Backlog$q$, $q$Dalam menyusun Business Requirement Document (BRD), kerangka apa yang dipakai untuk memastikan metric/KPI yang ditetapkan sudah tepat?$q$, $q$["SMART (Specific, Measurable, Achievable, Relevant, Time-bound)","SWOT (Strength, Weakness, Opportunity, Threat)","RACI (Responsible, Accountable, Consulted, Informed)","PDCA (Plan, Do, Check, Act)"]$q$::jsonb, 0, $q$Kerangka SMART dipakai untuk merumuskan metric/KPI BRD yang jelas dan terukur, mulai dari Business Objective hingga Baseline vs Target.$q$),
  (9, $q$BRD & Product Backlog$q$, $q$Kerangka DEEP dipakai untuk menilai ciri Product Backlog yang baik. Apa kepanjangan dari DEEP?$q$, $q$["Detailed appropriately, Emergent, Estimated, Prioritized","Defined, Executed, Evaluated, Planned","Detailed, Effective, Efficient, Practical","Developed, Engaged, Explained, Prepared"]$q$::jsonb, 0, $q$DEEP = Detailed appropriately, Emergent, Estimated, Prioritized — ciri Product Backlog yang sehat dan siap dikerjakan tim.$q$),
  (10, $q$BRD & Product Backlog$q$, $q$Manakah kriteria INVEST yang dipakai untuk menilai kualitas sebuah User Story?$q$, $q$["Independent, Negotiable, Valuable, Estimable, Small, Testable","Innovative, New, Verified, Efficient, Scalable, Testable","Integrated, Numbered, Verified, Estimated, Scoped, Timed","Iterative, Nimble, Value-driven, Efficient, Simple, Tracked"]$q$::jsonb, 0, $q$INVEST = Independent, Negotiable, Valuable, Estimable, Small, Testable — enam kriteria User Story yang baik dan siap masuk Sprint.$q$),
  (11, $q$Scrum Events$q$, $q$Event yang dilakukan setiap hari, maksimal 15 menit, untuk sinkronisasi progress tim disebut?$q$, $q$["Sprint Planning","Daily Scrum","Sprint Review","Sprint Retrospective"]$q$::jsonb, 1, $q$Daily Scrum adalah sesi sinkronisasi harian berdurasi maksimal 15 menit.$q$),
  (12, $q$Scrum Events$q$, $q$Pada event apa tim mendemonstrasikan increment (hasil kerja) kepada stakeholder?$q$, $q$["Sprint Planning","Daily Scrum","Sprint Review","Sprint Retrospective"]$q$::jsonb, 2, $q$Sprint Review adalah forum untuk mendemokan increment ke stakeholder dan mengumpulkan feedback.$q$),
  (13, $q$Scrum Events$q$, $q$Apa tujuan utama Sprint Retrospective?$q$, $q$["Menentukan Sprint Goal","Mendemo produk ke stakeholder","Mengevaluasi cara kerja tim & merencanakan perbaikan proses","Memecah Epic menjadi Task"]$q$::jsonb, 2, $q$Retrospective fokus pada refleksi proses kerja tim, bukan hasil produk.$q$),
  (14, $q$Waterfall & Scrum$q$, $q$Pola "Water-Scrum-Fall" merujuk pada kondisi di mana?$q$, $q$["Organisasi menjalankan Scrum murni tanpa jejak waterfall sama sekali","Organisasi menerapkan Scrum di tengah proses, tapi tetap waterfall di tahap requirement awal & deployment/release akhir","Waterfall diubah total menjadi Scrum penuh","Scrum dijalankan tanpa konsep Sprint"]$q$::jsonb, 1, $q$Water-Scrum-Fall menggambarkan hybrid: Scrum hanya diterapkan di bagian tengah siklus proyek.$q$),
  (15, $q$Bekal Praktik$q$, $q$Dalam hierarki Product Backlog, hubungan yang benar adalah?$q$, $q$["Task berisi banyak Epic","Product Backlog berisi beberapa Epic, dan satu Epic dipecah menjadi beberapa Task","Epic dan Task adalah istilah yang sama persis","Sprint Goal adalah bagian dari sebuah Task"]$q$::jsonb, 1, $q$Alurnya: Product Backlog → berisi banyak Epic → satu Epic dipecah jadi beberapa Task.$q$)
) as s(position, cat, q, opts, correct, note)
where not exists (select 1 from questions x where x.event_id = e.id);
