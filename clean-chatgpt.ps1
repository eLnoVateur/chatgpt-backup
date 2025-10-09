# Ferme d'abord toutes les instances de ChatGPT et ton navigateur
Stop-Process -Name "ChatGPT" -ErrorAction SilentlyContinue
Stop-Process -Name "msedge","chrome","firefox" -ErrorAction SilentlyContinue

# Supprime les caches ChatGPT / OpenAI
$paths = @(
  "$env:AppData\\OpenAI",
  "$env:LocalAppData\\OpenAI",
  "$env:Roaming\\OpenAI",
  "$env:AppData\\ChatGPT",
  "$env:LocalAppData\\ChatGPT",
  "$env:Roaming\\ChatGPT"
)

foreach ($p in $paths) {
  if (Test-Path $p) {
    Write-Host "Nettoyage de $p"
    Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue
  }
}

Write-Host "Nettoyage terminé. Relance ton appli ou ton navigateur."
