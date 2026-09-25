# Upload project ini ke GitHub.
# Prasyarat: Git sudah terpasang dan Anda sudah membuat repository kosong di GitHub.
$ErrorActionPreference = 'Stop'

Write-Host "=== MANADO P TAMPA BABELI - GitHub Upload ===" -ForegroundColor Cyan
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git belum terpasang. Install Git for Windows terlebih dahulu, lalu jalankan script ini lagi."
}

$repoUrl = Read-Host "Masukkan URL repository GitHub (contoh: https://github.com/USERNAME/NAMA-REPO.git)"
if ([string]::IsNullOrWhiteSpace($repoUrl)) { throw "https://github.com/jts765/babelimanado.git
." }

if (-not (Test-Path ".git")) {
    git init
}

git add .
git status
Write-Host "`nAkan dibuat commit awal. Lanjut? (Y/N)" -ForegroundColor Yellow
$answer = Read-Host
if ($answer -notmatch '^[Yy]$') { Write-Host "Dibatalkan."; exit }

git commit -m "Initial commit"
git branch -M main

$existingRemote = git remote get-url origin 2>$null
if ($LASTEXITCODE -eq 0) {
    git remote set-url origin $repoUrl
} else {
    git remote add origin $repoUrl
}

git push -u origin main
Write-Host "`nSelesai. Repository sudah di-push ke GitHub." -ForegroundColor Green
