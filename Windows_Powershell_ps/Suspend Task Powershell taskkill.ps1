
$ProcessName = "TiWorker"

$signature = @"
[DllImport("ntdll.dll")]
public static extern int NtSuspendProcess(IntPtr ProcessHandle);
"@

$NtSuspendProcess = Add-Type -MemberDefinition $signature -Name "SuspendProcess" -Namespace Win32Functions -PassThru

$Process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
if ($Process) {
    $NtSuspendProcess::NtSuspendProcess($Process.Handle)
    Write-Host "Process $ProcessName has been suspended."
} else {
    Write-Host "Process $ProcessName not found."
}