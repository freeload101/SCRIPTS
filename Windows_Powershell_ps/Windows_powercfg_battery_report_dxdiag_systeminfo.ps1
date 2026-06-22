function Get-SystemSummary {
    $reportPath = "$PSScriptRoot\SystemSummary.txt"
    $report = New-Object System.Collections.Generic.List[string]

    # 1. OS & Hardware Core
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $board = Get-CimInstance Win32_BaseBoard
    
    $report.Add("OS: $($os.Caption)")
    $report.Add("CPU: $($cpu.Name.Trim())")
    $report.Add("Motherboard: $($board.Manufacturer) $($board.Product)")

    # 2. Memory
    $memTotal = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $memFree = [Math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $report.Add("RAM: ${memTotal}GB (${memFree}GB Available)")

    # 3. GPU & VRAM (Using your Registry logic)
    $gpuList = Get-ItemProperty "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0*" -ErrorAction SilentlyContinue | 
               Where-Object { $_."HardwareInformation.qwMemorySize" -ne $null }

    foreach ($gpu in $gpuList) {
        $vramRaw = $gpu."HardwareInformation.qwMemorySize"
        if ($vramRaw -gt 0) {
            $VRAM = [math]::Round($vramRaw / 1GB)
            $report.Add("GPU: $($gpu.DriverDesc) (${VRAM}GB VRAM)")
        }
    }

    # 4. Battery Health
    $batt = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
    if ($batt) {
        try {
            $full = Get-CimInstance -Namespace "root\WMI" -ClassName "MSBatteryClass_FullChargedCapacity" -ErrorAction Stop
            $design = Get-CimInstance -Namespace "root\WMI" -ClassName "MSBatteryClass_DesignCapacity" -ErrorAction Stop
            $health = [Math]::Round(($full.FullChargedCapacity / $design.DesignCapacity) * 100, 1)
            $report.Add("Battery Health: ${health}%")
        } catch {
            $report.Add("Battery: $($batt.EstimatedChargeRemaining)% (Run as Admin for health %)")
        }
    }

    # 5. Hyper-V / WSL Status
    $sysInfo = systeminfo | Select-String "A hypervisor has been detected"
    if ($sysInfo) {
        $report.Add("Hyper-V/WHPX: Enabled")
    } else {
        $report.Add("Hyper-V/WHPX: Disabled or Not Detected")
    }

    # Save and Auto-Open
    $report | Out-File -FilePath $reportPath -Encoding utf8
    Invoke-Item $reportPath
}

Get-SystemSummary
