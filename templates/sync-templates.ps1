# Vergleicht CMakeLists.txt und CMakePresets.json aller Teilprojekte mit templates/.
# Standard: meldet nur Abweichungen.
#   -Apply   kopiert die Vorlagen in alle Teilprojekte.
[CmdletBinding()]
param([switch]$Apply)

$root = Split-Path $PSScriptRoot -Parent
$files = 'CMakeLists.txt', 'CMakePresets.json'

# Teilprojekt = Verzeichnis unter examples/ oder exercises/ mit einer der beiden Dateien.
$projects = foreach ($top in 'examples', 'exercises') {
    Get-ChildItem (Join-Path $root $top) -Recurse -Include $files -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '[\\/]build[\\/]' } |
        ForEach-Object { $_.DirectoryName } | Sort-Object -Unique
}
if (-not $projects) { Write-Host 'Keine Teilprojekte gefunden.'; exit 0 }

$drift = 0
foreach ($dir in $projects) {
    $rel = $dir.Substring($root.Length + 1)
    foreach ($f in $files) {
        $src = Join-Path $PSScriptRoot $f
        $dst = Join-Path $dir $f
        $state = if (-not (Test-Path $dst)) { 'fehlt' }
                 elseif ((Get-FileHash $src).Hash -ne (Get-FileHash $dst).Hash) { 'abweichend' }
                 else { $null }
        if (-not $state) { continue }
        $drift++
        if ($Apply) { Copy-Item $src $dst -Force; Write-Host "kopiert:  $rel\$f ($state)" }
        else { Write-Host "${state}: $rel\$f" }
    }
}

if ($drift -eq 0) { Write-Host 'Alle Teilprojekte entsprechen den Vorlagen.' }
elseif (-not $Apply) { Write-Host "`n$drift Abweichung(en). Mit -Apply angleichen."; exit 1 }
