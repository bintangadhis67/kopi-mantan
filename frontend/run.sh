#!/usr/bin/env bash
# Membuat folder platform yang belum ada lalu menjalankan aplikasi di Chrome
set -e
cd "$(dirname "$0")"
if [ ! -d android ] || [ ! -d windows ]; then
  flutter create . --project-name kopi_mantan --org com.kopimantan --platforms=android,web,windows
fi
flutter pub get
flutter run -d "${1:-chrome}"
