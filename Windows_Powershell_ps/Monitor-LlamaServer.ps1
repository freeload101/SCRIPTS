# ============================================================
# CONFIGURATION
# ============================================================
$ScriptPath  = $PSScriptRoot
$LogFile     = Join-Path $ScriptPath "llama-monitor.log"
$BatPath     = "C:\backup\LLM_Server\RUNME_CUDA.bat"
$ProcName    = "llama-server"
$TaskName    = "Monitor-LlamaServer"
$LockFile    = Join-Path $ScriptPath ".llama-monitor.lock"

# ============================================================
# LOGGING
# ============================================================
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $line -ErrorAction SilentlyContinue
    if ($Level -eq "ERROR") { Write-Warning $Message }
}

# ============================================================
# SCHEDULE SELF AS HOURLY TASK (idempotent — safe to re-run)
# ============================================================
function Register-MonitorTask {
    Write-Log "Registering/updating scheduled task: '$TaskName'"

    # Check if task already exists
    $existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

    # Build script argument — use absolute path to THIS script
    if ($MyInvocation.MyCommand.Path) {
        $scriptAbsPath = (Get-Item $MyInvocation.MyCommand.Path).FullName
    } else {
        $scriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
        $scriptAbsPath = Join-Path $PSScriptRoot $scriptName
    }
    $psArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptAbsPath`""

    $action = New-ScheduledTaskAction `
        -Execute  "powershell.exe" `
        -Argument $psArgs `
        -WorkingDirectory $ScriptPath

    # Hourly trigger: run immediately, then every hour (9999 days ~ max Task Scheduler supports)
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) `
        -RepetitionInterval (New-TimeSpan -Hours 1) `
        -RepetitionDuration (New-TimeSpan -Days 9999)

    # Settings: stop after 1hr max runtime, no restarts
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries:$false `
        -DontStopIfGoingOnBatteries:$false `
        -StartWhenAvailable:$true `
        -RunOnlyIfNetworkAvailable:$false `
        -ExecutionTimeLimit (New-TimeSpan -Hours 1) `
        -RestartCount 0

    # Run as current user with highest privileges
    $principal = New-ScheduledTaskPrincipal `
        -UserId $env:USERNAME `
        -LogonType S4U `
        -RunLevel Highest

    if ($existing) {
        Write-Log "Updating existing task '$TaskName'"
        Set-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal | Out-Null
    } else {
        Write-Log "Creating new task '$TaskName'"
        Register-ScheduledTask `
            -TaskName  $TaskName `
            -Action    $action `
            -Trigger   $trigger `
            -Settings  $settings `
            -Principal $principal `
            -Force `
            -Description "Auto-restart llama-server.exe every hour if not running." | Out-Null
    }

    # Verify registration
    $verify = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($verify) {
        Write-Log "Scheduled task '$TaskName' registered successfully (State: $($verify.State))"
    } else {
        Write-Log "WARNING: Task '$TaskName' may not have registered correctly." "WARN"
    }
}

# ============================================================
# MUTEX / LOCK FILE — prevent concurrent executions
# ============================================================
if (Test-Path $LockFile) {
    $lockAge = (Get-Item $LockFile).LastWriteTime
    if ((New-TimeSpan -Start $lockAge).TotalMinutes -lt 5) {
        Write-Log "Another instance is running (lock age: $((New-TimeSpan -Start $lockAge).TotalMinutes.ToString('F1')) min). Exiting." "WARN"
        Register-MonitorTask
        exit 0
    } else {
        Write-Log "Stale lock file found (age >5 min). Removing." "WARN"
        Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
    }
}
New-Item -Path $LockFile -ItemType File -Force | Out-Null

try {
    # ============================================================
    # VERIFY BAT FILE EXISTS
    # ============================================================
    if (-not (Test-Path $BatPath)) {
        Write-Log "CRITICAL: Launch batch file not found at '$BatPath'" "ERROR"
        Register-MonitorTask
        exit 1
    }

    # ============================================================
    # CHECK IF llama-server.exe IS RUNNING
    # ============================================================
    $running = Get-Process -Name $ProcName -ErrorAction SilentlyContinue

    if ($running) {
        $count = $running.Count
        $pids  = ($running.Id -join ", ")
        Write-Log "llama-server.exe is already running ($count instance(s), PIDs: $pids)"
        Register-MonitorTask
        exit 0
    }

    Write-Log "llama-server.exe NOT found. Attempting to start..."

    # ============================================================
    # LAUNCH llama-server.exe DIRECTLY (bypassing bat's 'pause' hang issue)
    # ============================================================
    $binDir = "C:\backup\LLM_Server\LLAMA_CUDA\llama.cpp\build\bin"

    if (-not (Test-Path $binDir)) {
        Write-Log "CRITICAL: Binary directory not found at '$binDir'" "ERROR"
        Register-MonitorTask
        exit 1
    }

    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName       = Join-Path $binDir "llama-server.exe"
    $processInfo.Arguments      = '--models-preset models.ini --models-max 1 --port 8082 --api-key "sk-lm-iUlcY0bh:V0ilgsVjjXSspXqyS1RX,sk-lm-n4oiut1g:SzPZIPMJK2Ll01rYBUq0" --host 0.0.0.0'
    $processInfo.WorkingDirectory = $binDir
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow  = $true
    $processInfo.WindowStyle     = [System.Diagnostics.ProcessWindowStyle]::Hidden

    $starter = [System.Diagnostics.Process]::Start($processInfo)
    Write-Log "Launched llama-server.exe (PID: $($starter.Id), Port: 8082)"

} catch {
    Write-Log "Exception: $_" "ERROR"
    Register-MonitorTask
} finally {
    Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
}

Write-Log "Script complete."
