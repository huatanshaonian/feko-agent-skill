param(
    [switch]$All
)

$ErrorActionPreference = 'SilentlyContinue'
$candidateBins = [System.Collections.Generic.List[string]]::new()

function Add-BinCandidate([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    $expanded = [Environment]::ExpandEnvironmentVariables($Path.Trim('"'))
    if (Test-Path -LiteralPath $expanded -PathType Leaf) {
        $expanded = Split-Path -Parent $expanded
    }
    if (Test-Path -LiteralPath $expanded -PathType Container) {
        $resolved = (Resolve-Path -LiteralPath $expanded).Path
        if (-not $candidateBins.Contains($resolved)) { $candidateBins.Add($resolved) }
    }
}

# 1. Explicit environment configuration.
foreach ($root in @($env:FEKO_HOME, $env:ALTAIR_HOME)) {
    if ($root) {
        Add-BinCandidate (Join-Path $root 'bin')
        Add-BinCandidate (Join-Path $root 'feko\bin')
    }
}

# 2. Executables already available on PATH.
foreach ($commandName in @('cadfeko.exe', 'cadfeko', 'runfeko.exe', 'runfeko')) {
    $command = Get-Command $commandName -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($command) { Add-BinCandidate $command.Source }
}

# 3. Windows uninstall registrations that expose an install location.
if ($IsWindows -or $env:OS -eq 'Windows_NT') {
    $registryRoots = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    foreach ($entry in Get-ItemProperty $registryRoots -ErrorAction SilentlyContinue) {
        if ($entry.DisplayName -match '(?i)\bFeko\b' -and $entry.InstallLocation) {
            Add-BinCandidate (Join-Path $entry.InstallLocation 'bin')
            Add-BinCandidate (Join-Path $entry.InstallLocation 'feko\bin')
        }
    }

    # 4. Conventional Altair layouts. Enumerate versions; do not hard-code one.
    foreach ($programRoot in @($env:ProgramFiles, ${env:ProgramFiles(x86)})) {
        $altairRoot = if ($programRoot) { Join-Path $programRoot 'Altair' } else { $null }
        if ($altairRoot -and (Test-Path -LiteralPath $altairRoot)) {
            Get-ChildItem -LiteralPath $altairRoot -Directory -ErrorAction SilentlyContinue |
                ForEach-Object {
                    Add-BinCandidate (Join-Path $_.FullName 'feko\bin')
                    Add-BinCandidate (Join-Path $_.FullName 'bin')
                }
        }
    }
}

$installations = foreach ($bin in $candidateBins) {
    $cad = @('cadfeko.exe', 'cadfeko') | ForEach-Object { Join-Path $bin $_ } |
        Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
    $run = @('runfeko.exe', 'runfeko') | ForEach-Object { Join-Path $bin $_ } |
        Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
    if (-not $cad -or -not $run) { continue }

    $versionText = (& $cad --version 2>&1 | Select-Object -First 1) -join ''
    $version = if ($versionText -match '(\d{4}(?:\.\d+){0,3})') {
        try { [version]$Matches[1] } catch { [version]'0.0' }
    } elseif ($bin -match '[\\/](\d{4}(?:\.\d+){0,3})[\\/]') {
        try { [version]$Matches[1] } catch { [version]'0.0' }
    } else { [version]'0.0' }

    [pscustomobject]@{
        Version = $version
        VersionText = $versionText
        BinPath = $bin
        Cadfeko = $cad
        Runfeko = $run
    }
}

$installations = @($installations | Sort-Object Version -Descending -Unique)
if ($installations.Count -eq 0) {
    throw 'No validated FEKO installation found. Set FEKO_HOME, add FEKO bin to PATH, or provide the installation directory.'
}

if ($All) { $installations } else { $installations | Select-Object -First 1 }
