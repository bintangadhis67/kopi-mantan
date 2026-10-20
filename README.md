# Kopi Mantan

Proyek UTS Pemrograman Aplikasi Bergerak, Program Studi Sistem Informasi, Tahun Akademik 2026/2027.

## Aplikasi

- **Aplikasi asli:** Kopi Kenangan
- **Nama plesetan:** Kopi Mantan

## Anggota Kelompok 3

| No | Nama | NIM | Job Desk |
|----|------|-----|----------|
| 1 | Netha Yuwira Almaizzani | 24051214185 | Frontend (UI) dan integrasi API |
| 2 | Muhammad Rafi Febrio | 24051214196 | Database dan Backend |
| 3 | Bintang Adhi Susanto | 24051214197 | Frontend (UI) dan integrasi API |
| 4 | Achmad Rafi Ilmal | 24051214204 | Database dan Backend |

## Cara Menjalankan

Tech stack: Flutter, REST API (Node.js + Express), PostgreSQL.
Prasyarat: Flutter SDK, Node.js 18+, PostgreSQL.

**1. Database**
Buka Pgadmin/postgresql dan buat database dengan nama "kopi_mantan"

Buka pgAdmin (Query Tool) atau psql, lalu buat database dengan nama `kopi_mantan`:

```sql
CREATE DATABASE kopi_mantan;
```

**Selanjutnya extract zip folder dan buka folder pada vscode lalu ke bagian terminal dan ketik code backend dibawah ini setiap satu baris:** 

**2. Backend**

```bash
cd backend
cp .env.example .env      # Windows: copy .env.example .env
```

**Isi file `.env`: `DATABASE_URL` (dengan password PostgreSQL) dan `JWT_SECRET` (teks acak apa saja)**. Lalu:

```bash
npm install
npm run migrate           # menjalankan semua file di backend/migrations
npm run dev               # API di http://localhost:3000
```

**Setelah localhost sudah menyala lanjut buka terminal baru dan ketik code frontend dibawah ini setiap baris** 


**3. Frontend**

```bash
cd frontend
flutter pub get
flutter run -d chrome     # atau pilih emulator Android
```

Login memakai nomor HP apa saja dan kode OTP `1234`.
