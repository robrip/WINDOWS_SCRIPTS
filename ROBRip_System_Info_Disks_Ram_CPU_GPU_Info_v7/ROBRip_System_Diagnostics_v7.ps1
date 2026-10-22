# ============================
#   Neon‑Violet ROBRip Banner
# ============================

Write-Host ""
Write-Host "`e[95m██████╗  ██████╗ ██████╗ ██████╗  ██╗██████╗ "
Write-Host "`e[95m██╔══██╗██╔═══██╗██╔══██╗██╔══██╗ ██║██╔══██╗"
Write-Host "`e[95m██████╔╝██║   ██║██████╔╝██████╔╝ ██║██████╔╝"
Write-Host "`e[95m██╔══██╗██║   ██║██╔══██╗██╔══██╗ ██║██╔═══╝ "
Write-Host "`e[95m██║  ██║╚██████╔╝██████╔╝██║  ██║ ██║██║     "
Write-Host "`e[95m╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═╝╚═╝     "
Write-Host "`e[0m"

# ============================
#   Helper: Health Color
# ============================

function Get-HealthColor {
    param($HealthStatus)
    switch ($HealthStatus) {
        'Healthy'        { return 'Green' }
        'Warning'        { return 'Yellow' }
        'Unhealthy'      { return 'Red' }
        default          { return 'DarkGray' }
    }
}

# ============================
#   Helper: Disk Type Detection
# ============================

function Get-DiskIcon {
    param($Disk)

    $name = $Disk.FriendlyName
    $bus  = $Disk.BusType

    # NVMe detection
    if ($bus -eq 'NVMe' -or $name -match 'NVMe|MZVL|Lexar NM|X7400') {
        return '⚡ NVMe'
    }

    # SSD detection
    if ($name -match 'SSD|Solid|Lexar|Samsung|SAMSUNG|Pro SSD') {
        return '🔷 SSD'
    }

    # HDD detection
    if ($name -match 'HGST|Seagate|Expansion|Desk|HMS|ST[0-9]+') {
        return '💽 HDD'
    }

    return '🖴 USB/Flash'
}

# ============================
#   GPU VRAM (DXDIAG PARSER)
# ============================

function Get-GPUInfo {
    dxdiag /x "$env:TEMP\dx.xml" | Out-Null
    [xml]$dx = Get-Content "$env:TEMP\dx.xml"

    $gpus = $dx.DxDiag.DisplayDevices.DisplayDevice

    # Remove duplicates by CardName
    $unique = $gpus | Group-Object CardName | ForEach-Object { $_.Group[0] }

    function Convert-MBToGB {
        param($value)
        if ($value -match '(\d+)\s*MB') {
            return [math]::round(($matches[1] / 1024), 2)
        }
        return "N/A"
    }

    foreach ($gpu in $unique) {
        $dedicated = Convert-MBToGB $gpu.DedicatedMemory
        $shared    = Convert-MBToGB $gpu.SharedMemory
        $total     = Convert-MBToGB $gpu.DisplayMemory

        [PSCustomObject]@{
            Name               = $gpu.CardName
            'VRAM (Dedicated)' = "$dedicated GB"
            'VRAM (Shared)'    = "$shared GB"
            'VRAM (Total)'     = "$total GB"
            DriverVersion      = $gpu.DriverVersion
        }
    }
}

# ============================
#   GPU Live Stats (nvidia-smi)
# ============================

function Get-GPULiveStats {
    if (-not (Get-Command nvidia-smi -ErrorAction SilentlyContinue)) {
        Write-Host "GPU live stats: nvidia-smi not found in PATH." -ForegroundColor DarkGray
        return
    }

    $csv = nvidia-smi --query-gpu=name,utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv,noheader,nounits
    $stats = $csv | ForEach-Object {
        $parts = $_ -split ',\s*'
        [PSCustomObject]@{
            Name          = $parts[0]
            'GPU Load (%)' = [int]$parts[1]
            'Temp (C)'     = [int]$parts[2]
            'VRAM Used (GB)' = [math]::round(([double]$parts[3] / 1024), 2)
            'VRAM Total (GB)' = [math]::round(([double]$parts[4] / 1024), 2)
        }
    }

    Write-Host "`n=== GPU Live Stats (nvidia-smi) ===`n"
    $stats | Format-Table -AutoSize
}

Get-GPULiveStats

# ============================
#   Physical Disk & Partition
# ============================

Write-Host "`n=== Physical Disk & Partition Info ===`n"

$diskInfo = Get-Partition |
    Where-Object DriveLetter -match '^[A-Z]$' |
    ForEach-Object {
        $disk = Get-Disk -Number $_.DiskNumber
        $icon = Get-DiskIcon -Disk $disk

        [PSCustomObject]@{
            DriveLetter       = $_.DriveLetter
            DiskNumber        = $_.DiskNumber
            Icon              = $icon
            FriendlyName      = $disk.FriendlyName
            SerialNumber      = $disk.SerialNumber
            HealthStatus      = $disk.HealthStatus
            OperationalStatus = $disk.OperationalStatus
            SizeGB            = "{0:N2}" -f ($disk.Size / 1GB)
            PartitionStyle    = $disk.PartitionStyle
        }
    } | Sort-Object DriveLetter

$diskInfo | ForEach-Object {
    $color = Get-HealthColor -HealthStatus $_.HealthStatus

    Write-Host (
        "{0}  Disk {1}  {2}  {3}  Serial:{4}  Health:{5}  Op:{6}  Size:{7} GB  Style:{8}" -f `
        $_.DriveLetter, $_.DiskNumber, $_.Icon, $_.FriendlyName, $_.SerialNumber, `
        $_.HealthStatus, $_.OperationalStatus, $_.SizeGB, $_.PartitionStyle
    ) -ForegroundColor $color
}

# ============================
#   Disk Space Information
# ============================

Write-Host "`n=== Disk Space Information ===`n"

$diskSpace = Get-PSDrive -PSProvider FileSystem |
    Select-Object Name,
        @{Name="Used(GB)";Expression={[math]::round($_.Used/1GB,2)}},
        @{Name="Free(GB)";Expression={[math]::round($_.Free/1GB,2)}}

$diskSpace | Format-Table -AutoSize

# ============================
#   Disk SMART & Reliability
# ============================

Write-Host "`n=== Disk SMART / Reliability (Basic) ===`n"

try {
    $smart = Get-PhysicalDisk | ForEach-Object {
        $rel = Get-StorageReliabilityCounter -PhysicalDisk $_ -ErrorAction SilentlyContinue

        [PSCustomObject]@{
            FriendlyName        = $_.FriendlyName
            MediaType           = $_.MediaType
            HealthStatus        = $_.HealthStatus
            TemperatureC        = if ($rel) { $rel.Temperature } else { "N/A" }
            Wear                = if ($rel) { $rel.Wear } else { "N/A" }
            ReadErrors          = if ($rel) { $rel.ReadErrorsTotal } else { "N/A" }
            WriteErrors         = if ($rel) { $rel.WriteErrorsTotal } else { "N/A" }
            Reallocations       = if ($rel) { $rel.ReallocatedSectors } else { "N/A" }
        }
    }

    $smart | Format-Table -AutoSize
}
catch {
    Write-Host "SMART / reliability counters not available on this system." -ForegroundColor DarkGray
}

# ============================
#   CPU Usage Information
# ============================

Write-Host "`n=== CPU Usage Information ===`n"

$cpuUsage = Get-WmiObject -Class Win32_Processor |
    Select-Object Name,
        @{Name="CPU Usage (%)";Expression={$_.LoadPercentage}}

$cpuUsage | Format-Table -AutoSize

# ============================
#   Memory Usage Information
# ============================

Write-Host "`n=== Memory Usage Information ===`n"

$memoryUsage = Get-WmiObject -Class Win32_OperatingSystem |
    Select-Object @{Name="Total Memory (GB)";Expression={[math]::round($_.TotalVisibleMemorySize/1MB,2)}},
                  @{Name="Free Memory (GB)";Expression={[math]::round($_.FreePhysicalMemory/1MB,2)}}

$memoryUsage | Format-Table -AutoSize

# ============================
#   GPU Information
# ============================

Write-Host "`n=== GPU Information ===`n"
Get-GPUInfo | Format-Table -AutoSize

# ============================
#   Temperature Information
# ============================

# This is commented out - due it not working correctly on all systems. It may be re-enabled in future versions if a more reliable method is found.
#Write-Host "`n=== Temperature Information (Basic) ===`n"


<#try {
    $temps = Get-WmiObject -Namespace "root/wmi" -Class MSAcpi_ThermalZoneTemperature -ErrorAction Stop |
       Select-Object @{Name="Instance";Expression={$_.InstanceName}},
                      @{Name="Temperature(C)";Expression={[math]::round(($_.CurrentTemperature / 10 - 273.15), 1)}}

    if ($temps) {
        $temps | Format-Table -AutoSize
    } else {
        Write-Host "No thermal zone data exposed via WMI." -ForegroundColor DarkGray
    }
}
catch {
    Write-Host "Temperature data not available via MSAcpi_ThermalZoneTemperature." -ForegroundColor DarkGray
}#>

Write-Host "`nClaudeWad DIAGNOSTICS v7 — telemetry engaged.`n" -ForegroundColor Magenta
