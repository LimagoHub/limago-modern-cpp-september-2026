# Konfiguriert und baut alle Teilprojekte unter examples/ und exercises/ einzeln.
# Standard: nur MinGW (mingw-debug, mingw-release).
#   -WithMsvc   zusaetzlich msvc-debug; die Developer-Umgebung kommt ueber vswhere.
#   -Path       nur Teilprojekte unterhalb dieses Pfads (z. B. examples/01-ownership-raii).
[CmdletBinding()]
param(
    [switch]$WithMsvc,
    [string]$Path
)

$root = Split-Path $PSScriptRoot -Parent
$scope = if ($Path) { (Resolve-Path $Path).Path } else { $root }

function Import-VsEnvironment {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path $vswhere)) { return $false }
    $vs = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if (-not $vs) { return $false }
    $bat = Join-Path $vs 'VC\Auxiliary\Build\vcvars64.bat'
    if (-not (Test-Path $bat)) { return $false }
    cmd /c "`"$bat`" >nul && set" | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') { Set-Item -Path "env:$($Matches[1])" -Value $Matches[2] }
    }
    return $true
}

if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
    Write-Error 'cmake nicht im PATH.'
    exit 2
}

$presets = @('mingw-debug', 'mingw-release')
if ($WithMsvc) {
    if (Import-VsEnvironment) { $presets += 'msvc-debug' }
    else { Write-Warning 'vswhere oder Visual Studio nicht gefunden - MSVC wird ausgelassen.' }
}

$projects = foreach ($top in 'examples', 'exercises') {
    Get-ChildItem (Join-Path $root $top) -Recurse -Filter CMakePresets.json -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '[\\/]build[\\/]' -and $_.DirectoryName.StartsWith($scope) } |
        ForEach-Object { $_.DirectoryName }
}
if (-not $projects) { Write-Host 'Keine Teilprojekte gefunden.'; exit 0 }

$results = @()
foreach ($dir in $projects) {
    foreach ($p in $presets) {
        $name = "$($dir.Substring($root.Length + 1)) [$p]"
        Write-Host "== $name"
        Push-Location $dir
        try {
            cmake --preset $p | Out-Host
            $ok = ($LASTEXITCODE -eq 0)
            if ($ok) { cmake --build --preset $p | Out-Host; $ok = ($LASTEXITCODE -eq 0) }
        } finally { Pop-Location }
        $results += [pscustomobject]@{ Teilprojekt = $name; Ergebnis = if ($ok) { 'ok' } else { 'FEHLER' } }
    }
}

Write-Host "`nZusammenfassung"
$results | Format-Table -AutoSize
if ($results | Where-Object Ergebnis -ne 'ok') { exit 1 }
