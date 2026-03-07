<#
NetPulse v1.2
New:
- Packet Loss % detection
- Colorized latency display
- Full summary block
- Ping count presets (10 / 30 / 50 / 100 / 200 / -t infinite)
- Tracert mode
#>

param()

function Show-Header {
    Clear-Host
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host "        NetPulse v1.2" -ForegroundColor Green
    Write-Host "===============================" -ForegroundColor Cyan
}

function Select-Mode {

    Write-Host "Select mode:" -ForegroundColor Yellow
    Write-Host "1) Ping"
    Write-Host "2) Tracert"

    $choice = Read-Host "Choose (1-2)"

    if ($choice -eq "2") { return "tracert" }

    return "ping"
}

function Select-PingCount {

    Write-Host "Select ping count:" -ForegroundColor Yellow
    Write-Host "1) 10"
    Write-Host "2) 30"
    Write-Host "3) 50"
    Write-Host "4) 100"
    Write-Host "5) 200"
    Write-Host "6) Infinite (-t)"

    $choice = Read-Host "Choose (1-6)"

    switch ($choice) {
        "1" { return 10 }
        "2" { return 30 }
        "3" { return 50 }
        "4" { return 100 }
        "5" { return 200 }
        "6" { return -1 }
        default { return 10 }
    }
}

function Write-ColoredLatency($time, $text) {

    if ($time -lt 20) {
        Write-Host $text -ForegroundColor Green
    }
    elseif ($time -lt 80) {
        Write-Host $text -ForegroundColor Yellow
    }
    else {
        Write-Host $text -ForegroundColor Red
    }
}

function Invoke-PingTest($target, $count) {

    $min = [int]::MaxValue
    $max = 0
    $sum = 0
    $sent = 0
    $received = 0

    if ($count -eq -1) {

        Write-Host "Infinite ping mode. Press Q to stop." -ForegroundColor Yellow

        while ($true) {

            if ([console]::KeyAvailable) {
                $key = [console]::ReadKey($true)
                if ($key.Key -eq 'Q') { break }
            }

            $sent++

            $reply = Test-Connection -ComputerName $target -Count 1 -ErrorAction SilentlyContinue

            if ($reply) {

                $time = $reply.ResponseTime
                $ttl = $reply.TimeToLive
                $received++

                if ($time -lt $min) { $min = $time }
                if ($time -gt $max) { $max = $time }

                $sum += $time

                $text = "[$sent] ${time}ms TTL=$ttl"

                Write-ColoredLatency $time $text
            }
            else {

                Write-Host "[$sent] Request timed out." -ForegroundColor Red
            }

            Start-Sleep -Seconds 1
        }
    }
    else {

        for ($i=1; $i -le $count; $i++) {

            $sent++

            $reply = Test-Connection -ComputerName $target -Count 1 -ErrorAction SilentlyContinue

            if ($reply) {

                $time = $reply.ResponseTime
                $ttl = $reply.TimeToLive
                $received++

                if ($time -lt $min) { $min = $time }
                if ($time -gt $max) { $max = $time }

                $sum += $time

                $text = "[$i/$count] ${time}ms TTL=$ttl"

                Write-ColoredLatency $time $text
            }
            else {

                Write-Host "[$i/$count] Request timed out." -ForegroundColor Red
            }

            Start-Sleep -Seconds 1
        }
    }

    if ($received -gt 0) {

        $avg = [math]::Round($sum / $received,2)
    }
    else {

        $min = 0
        $avg = 0
    }

    $lost = $sent - $received

    if ($sent -gt 0) {

        $lossPercent = [math]::Round(($lost / $sent) * 100,2)
    }
    else {

        $lossPercent = 0
    }

    return [pscustomobject]@{
        Target = $target
        Sent = $sent
        Received = $received
        Lost = $lost
        LossPercent = $lossPercent
        Min = $min
        Max = $max
        Avg = $avg
    }
}

function Run-PingMode {

    $target = Read-Host "Enter IP or domain"

    $count = Select-PingCount

    $result = Invoke-PingTest $target $count

    Write-Host "`n===== NetPulse Summary =====" -ForegroundColor Cyan

    Write-Host "Target: $($result.Target)"

    Write-Host "Packets: Sent = $($result.Sent), Received = $($result.Received), Lost = $($result.Lost) ($($result.LossPercent)%)"

    Write-Host "Min = $($result.Min) ms"

    Write-Host "Max = $($result.Max) ms"

    Write-Host "Avg = $($result.Avg) ms"

    Write-Host "=============================" -ForegroundColor Cyan
}

function Run-TracertMode {

    $target = Read-Host "Enter IP or domain"

    Write-Host "`nRunning tracert..." -ForegroundColor Yellow

    tracert $target
}

Show-Header

$mode = Select-Mode

if ($mode -eq "tracert") {

    Run-TracertMode

}
else {

    Run-PingMode

}

Write-Host "`nPress Enter to exit..." -ForegroundColor DarkGray

Read-Host | Out-Null
