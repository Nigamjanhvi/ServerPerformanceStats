<#
Server Performance Stats (Windows PowerShell)
Simplified version for compatibility with Windows PowerShell 5.1.
#>
param([switch]$AllDisks)

function Section([string]$title) { Write-Host "`n-- $title --" -ForegroundColor Cyan }

Write-Host "=============================="
Write-Host "   SERVER PERFORMANCE STATS"
Write-Host "=============================="

# CPU Usage
Section "CPU Usage"
try {
  $cpu = (Get-Counter '\\Processor(_Total)\\% Processor Time' -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue
  $cpuVal = ($cpu | Select-Object -First 1)
  if ($null -eq $cpuVal) { $cpuVal = 0 }
  Write-Host ("{0:N2}%" -f ([double]$cpuVal))
} catch { Write-Warning $_ }

# Memory Usage
Section "Memory Usage"
try {
  $os = Get-CimInstance -ClassName Win32_OperatingSystem
  $total = [double]$os.TotalVisibleMemorySize * 1KB
  $free  = [double]$os.FreePhysicalMemory * 1KB
  $used  = $total - $free
  $pct   = if ($total -gt 0) { ($used*100.0)/$total } else { 0 }
  Write-Host ("Used: {0:N2} GB | Free: {1:N2} GB | Usage: {2:N2}%" -f ($used/1GB), ($free/1GB), $pct)
} catch { Write-Warning $_ }

# Disk Usage
Section "Disk Usage"
try {
  $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
  if (-not $AllDisks) { $disks = $disks | Where-Object { $_.DeviceID -eq 'C:' } }
  foreach ($d in $disks) {
    $size=[double]$d.Size; $free=[double]$d.FreeSpace; $used=$size-$free
    $pct = if ($size -gt 0) { ($used*100.0)/$size } else { 0 }
    Write-Host ("{0} -> Used: {1:N2} GB | Free: {2:N2} GB | Usage: {3:N2}%" -f $d.DeviceID, ($used/1GB), ($free/1GB), $pct)
  }
} catch { Write-Warning $_ }

# Top processes (CPU)
Section "Top 5 CPU-consuming processes"
try {
  Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 |
    Select-Object @{n='PID';e={$_.Id}}, @{n='Name';e={$_.ProcessName}}, @{n='CPU(s)';e={[math]::Round($_.CPU,2)}} |
    Format-Table -AutoSize
} catch { Write-Warning $_ }

# Top processes (Memory)
Section "Top 5 Memory-consuming processes"
try {
  Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 |
    Select-Object @{n='PID';e={$_.Id}}, @{n='Name';e={$_.ProcessName}}, @{n='WorkingSet(MB)';e={[math]::Round($_.WorkingSet/1MB,2)}} |
    Format-Table -AutoSize
} catch { Write-Warning $_ }

# Extras
Section "Uptime"
try {
  $os = Get-CimInstance Win32_OperatingSystem
  $uptime = (Get-Date) - ([Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime))
  Write-Host ("Up {0} days {1} hours {2} minutes" -f $uptime.Days,$uptime.Hours,$uptime.Minutes)
} catch { }

Section "OS Version"
try { Write-Host (Get-CimInstance Win32_OperatingSystem).Caption } catch { }

Section "Logged-in users"
try { Write-Host ((quser 2>$null | Measure-Object).Count) } catch { Write-Host (whoami) }

Write-Host "`n=============================="
Write-Host "       END OF REPORT"
Write-Host "=============================="
