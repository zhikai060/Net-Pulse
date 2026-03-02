<#
NetPulse - Interactive Ping / Tracert Tool
Author: Leo
Description:
- Interactive IP input
- Choose ping or tracert (default: ping)
- Ping count: 10 / 30 / 50 / 100 / infinite (-t)
- Infinite mode: press Q to stop and show total count
- Optional CSV export (non-infinite mode)
- Real-time min / max / avg / TTL display
#>

param()

function Show-Header {
    Clear-Host
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host "        NetPulse v1.0" -ForegroundColor Green
    Write-Host "===============================" -ForegroundColor Cyan
}

function Get-Target {
    $target = Read-Host "Enter IP or domain"
    return $target
}

function Get-Mode {
    $mode = Read-Host "Choose mode: (1) Ping [Default]  (2) Tracert"
    if ($mode -eq "2") { return "tracert" }
    return "ping"
}

function Get-PingCount {
    Write-Host "Select ping count:" -ForegroundColor Yellow
    Write-Host "1) 10"
    Write-Host "2) 30"
    Write-Host "3) 50"
    Write-Host "4) 100"
    Write-Host "5) Infinite (-t)"

    $choice = Read-Host "Choose (1-5)"

    switch ($choice) {
        "1" { return 10 }
        "2" { return 30 }
        "3" { return 50 }
        "4" { return 100 }
        "5" { return -1 }
        default { return 10 }
    }
}

function Ask-ExportCSV {
    $export = Read-Host "Export result to CSV? (Y/N)"
    if ($export -match "^[Yy]$") { return $true }
    return $false
}

function Start-Tracert($target) {
    Write-Host "Starting tracert..." -ForegroundColor Cyan
    tracert $target
}

function Start-Ping($target, $count, $exportCSV) {

    $results = @()
    $min = [int]::MaxValue
    $max = 0
    $sum = 0
    $success = 0

    if ($count -eq -1) {
        Write-Host "Infinite ping. Press Q to stop." -ForegroundColor Yellow
        $i = 0
        while ($true) {
            if ([console]::KeyAvailable) {
                $key = [console]::ReadKey($true)
                if ($key.Key -eq 'Q') { break }
            }

            $reply = Test-Connection -ComputerName $target -Count 1 -ErrorAction SilentlyContinue
            $i++

            if ($reply) {
                $time = $reply.ResponseTime
                $ttl = $reply.TimeToLive
                $success++

                if ($time -lt $min) { $min = $time }
                if ($time -gt $max) { $max = $time }
                $sum += $time

                $avg = [math]::Round($sum / $success,2)

                Write-Host "[$i] Time=${time}ms TTL=$ttl | Min=$min Max=$max Avg=$avg"
            }
            Start-Sleep -Milliseconds 1000
        }

        Write-Host "Stopped. Total sent: $i"
        return
    }

    if ($exportCSV) {
        $csvPath = Join-Path $PSScriptRoot "ping_result.csv"
    }

    for ($i=1; $i -le $count; $i++) {
        $reply = Test-Connection -ComputerName $target -Count 1 -ErrorAction SilentlyContinue

        if ($reply) {
            $time = $reply.ResponseTime
            $ttl = $reply.TimeToLive
            $success++

            if ($time -lt $min) { $min = $time }
            if ($time -gt $max) { $max = $time }
            $sum += $time
            $avg = [math]::Round($sum / $success,2)

            Write-Host "[$i/$count] Time=${time}ms TTL=$ttl | Min=$min Max=$max Avg=$avg"

            if ($exportCSV) {
                $results += [pscustomobject]@{
                    Index = $i
                    Time_ms = $time
                    TTL = $ttl
                    Min = $min
                    Max = $max
                    Avg = $avg
                }
            }
        }
        Start-Sleep -Milliseconds 1000
    }

    if ($exportCSV) {
        $results | Export-Csv $csvPath -NoTypeInformation -Encoding UTF8
        Write-Host "CSV exported to $csvPath" -ForegroundColor Green
    }
}

Show-Header
$target = Get-Target
$mode = Get-Mode

if ($mode -eq "tracert") {
    Start-Tracert $target
}
else {
    $count = Get-PingCount
    $export = $false
    if ($count -ne -1) {
        $export = Ask-ExportCSV
    }
    Start-Ping $target $count $export
}
