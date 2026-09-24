param(
  [int]$Port = 5500,
  [switch]$LocalOnly
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootWithSeparator = $Root.TrimEnd('\') + '\'
$Prefix = if ($LocalOnly) { "http://localhost:$Port/" } else { "http://+:$Port/" }
$Listener = [System.Net.HttpListener]::new()
$Listener.Prefixes.Add($Prefix)

function Get-ContentType([string]$Path) {
  switch ([IO.Path]::GetExtension($Path).ToLowerInvariant()) {
    '.html' { 'text/html; charset=utf-8'; break }
    '.js' { 'application/javascript; charset=utf-8'; break }
    '.json' { 'application/json; charset=utf-8'; break }
    '.webmanifest' { 'application/manifest+json; charset=utf-8'; break }
    '.css' { 'text/css; charset=utf-8'; break }
    '.svg' { 'image/svg+xml'; break }
    '.png' { 'image/png'; break }
    '.jpg' { 'image/jpeg'; break }
    '.jpeg' { 'image/jpeg'; break }
    '.webp' { 'image/webp'; break }
    '.ico' { 'image/x-icon'; break }
    default { 'application/octet-stream'; break }
  }
}

try {
  $Listener.Start()
  Write-Output "Tableware vision workbench is running:"
  Write-Output "  Local: http://localhost:$Port/index.html"
  if (-not $LocalOnly) {
    $Addresses = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
      Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } |
      Select-Object -ExpandProperty IPAddress -Unique
    foreach ($Address in $Addresses) { Write-Output "  LAN: http://${Address}:$Port/index.html" }
    Write-Output 'Other computers must be on the same network and allowed through Windows Firewall.'
  }
  while ($Listener.IsListening) {
    $Context = $Listener.GetContext()
    try {
      $Relative = [Uri]::UnescapeDataString($Context.Request.Url.AbsolutePath.TrimStart('/'))
      if ([string]::IsNullOrWhiteSpace($Relative)) { $Relative = 'index.html' }
      $FullPath = [IO.Path]::GetFullPath((Join-Path $Root $Relative))
      if (-not $FullPath.StartsWith($RootWithSeparator, [StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $FullPath -PathType Leaf)) {
        $Context.Response.StatusCode = 404
        $Context.Response.Close()
        continue
      }
      $Bytes = [IO.File]::ReadAllBytes($FullPath)
      $Context.Response.ContentType = Get-ContentType $FullPath
      $Context.Response.Headers['Cache-Control'] = 'no-cache'
      $Context.Response.ContentLength64 = $Bytes.Length
      $Context.Response.OutputStream.Write($Bytes, 0, $Bytes.Length)
      $Context.Response.Close()
    } catch {
      try { $Context.Response.StatusCode = 500; $Context.Response.Close() } catch {}
    }
  }
} finally {
  if ($Listener.IsListening) { $Listener.Stop() }
  $Listener.Close()
}
