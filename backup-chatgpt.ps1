$ErrorActionPreference = "Stop"
$repo = Join-Path $env:USERPROFILE ".chatgpt"
Set-Location $repo
if (-not (Test-Path ".git")) { throw "Repo Git MANQUANT: $repo" }
git fetch --quiet
$pending = git status --porcelain
if ([string]::IsNullOrWhiteSpace($pending)) { return }
git add -A
$stamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
git commit -m "Auto backup $stamp"
git push
