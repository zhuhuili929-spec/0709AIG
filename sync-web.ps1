$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Target = Join-Path $Root 'index.html'
$Sources = @(Get-ChildItem -LiteralPath $Root -Filter '*.html' -File | Where-Object { $_.Name -ne 'index.html' })

if ($Sources.Count -ne 1) {
  throw "Expected exactly one source HTML file beside index.html, found $($Sources.Count)."
}

$Source = $Sources[0].FullName
Copy-Item -LiteralPath $Source -Destination $Target -Force
$Hash = (Get-FileHash -LiteralPath $Target -Algorithm SHA256).Hash
Write-Output "Synced source HTML to index.html: $($Sources[0].Name)"
Write-Output "SHA256: $Hash"
