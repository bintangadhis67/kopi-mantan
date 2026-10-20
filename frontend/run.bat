@echo off
cd /d "%~dp0"

rem Buat folder platform (android, web, windows) jika belum ada. Kode di lib\ tidak ditimpa.
set NEED=0
if not exist android set NEED=1
if not exist windows set NEED=1
if "%NEED%"=="1" (
  call flutter create . --project-name kopi_mantan --org com.kopimantan --platforms=android,web,windows
)

call flutter pub get

rem Default dijalankan di Chrome. Ganti ke "-d windows" atau hapus "-d chrome" untuk emulator Android.
call flutter run -d chrome
