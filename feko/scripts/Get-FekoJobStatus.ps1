param(
    [Parameter(Mandatory = $true)]
    [string]$ModelBase
)

$base = [System.IO.Path]::GetFullPath($ModelBase)
$outFile = "$base.out"
$resultFiles = Get-ChildItem -LiteralPath ([System.IO.Path]::GetDirectoryName($base)) `
    -Filter "$([System.IO.Path]::GetFileName($base))*" -ErrorAction SilentlyContinue |
    Where-Object { $_.Extension -in '.ffe', '.bof', '.out', '.fek' } |
    Select-Object Name, Extension, Length, LastWriteTime

$processes = Get-Process -ErrorAction SilentlyContinue |
    Where-Object {
        $_.ProcessName -eq 'runfeko' -or
        $_.ProcessName -eq 'mpiexec' -or
        $_.ProcessName -like 'feko*.impi'
    } |
    Select-Object Id, ProcessName, CPU, StartTime

[pscustomobject]@{
    ModelBase = $base
    OutExists = Test-Path -LiteralPath $outFile
    OutUpdated = if (Test-Path -LiteralPath $outFile) {
        (Get-Item -LiteralPath $outFile).LastWriteTime
    } else { $null }
    SolverProcesses = @($processes).Count
    FfeCount = @($resultFiles | Where-Object Extension -eq '.ffe').Count
    FfeReadyCount = @(
        $resultFiles | Where-Object { $_.Extension -eq '.ffe' -and $_.Length -gt 0 }
    ).Count
}

$processes
$resultFiles
if (Test-Path -LiteralPath $outFile) {
    Get-Content -LiteralPath $outFile -Tail 30
}
