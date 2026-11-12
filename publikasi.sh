#!/bin/bash
# Menerbitkan versi baru MDB Intelligence ke GitHub Pages.
# Pemakaian (dari dalam folder repository):
#   ./publikasi.sh ~/Downloads/MDB_Intelligence_V77/MDB_INTELLIGENCE_DASHBOARD_V77.html
set -e
cd "$(dirname "$0")"

SRC="$1"
if [ -z "$SRC" ]; then echo "Pemakaian: ./publikasi.sh <file dashboard .html>"; exit 1; fi
if [ ! -f "$SRC" ]; then echo "File tidak ditemukan: $SRC"; exit 1; fi
if [ ! -d .git ]; then echo "Skrip ini harus berada di dalam folder repository."; exit 1; fi

VER=$(basename "$SRC" | grep -o 'V[0-9]\+' | head -1)
VER=${VER:-baru}

echo "Mengambil versi terbaru dari GitHub..."
git pull --quiet

cp "$SRC" index.html

# Pengaman: jangan pernah menerbitkan API key atau token
if grep -rIlE --exclude-dir=.git 'AIza[0-9A-Za-z_\-]{30,}|ghp_[0-9A-Za-z]{30,}|github_pat_[0-9A-Za-z_]{30,}' . ; then
  echo "BERHENTI: file di atas tampak berisi API key atau token. Hapus dulu, lalu jalankan ulang."
  git checkout -q -- index.html 2>/dev/null || true
  exit 1
fi

git add -A
if git diff --cached --quiet; then echo "Tidak ada perubahan untuk diterbitkan."; exit 0; fi

echo "Perubahan yang akan diterbitkan:"
git status --short
read -r -p "Terbitkan sebagai \"Rilis $VER\"? (y/n) " ok
if [ "$ok" != "y" ]; then git reset -q; echo "Dibatalkan, tidak ada yang dikirim."; exit 0; fi

git commit -q -m "Rilis $VER"
git push -q
echo "Selesai. Situs diperbarui dalam 1 sampai 2 menit:"
URL=$(git remote get-url origin | sed -E 's#(git@github.com:|https://github.com/)##; s#\.git$##')
echo "https://${URL%%/*}.github.io/${URL#*/}/"
