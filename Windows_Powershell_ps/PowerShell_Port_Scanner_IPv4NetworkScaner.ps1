# Define the base subnet without the last octet
$baseSubnet = "10.110.0"

# This function pings a single IP address
function Test-PingAsync {
    param(
        [string]$ipAddress
    )

    $ping = New-Object System.Net.NetworkInformation.Ping
    $ping.SendPingAsync($ipAddress, 1000) | ForEach-Object {
        if ($_.Result.Status -eq 'Success') {
            Write-Host "$ipAddress is up" -ForegroundColor Green
            Scan-PortsAsync -ipAddress $ipAddress
        }
    }
}

# This function scans ports of a given IP address
function Scan-PortsAsync {
    param(
        [string]$ipAddress
    )

    1..1024 | ForEach-Object {
        $port = $_
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connectAsync = $tcpClient.BeginConnect($ipAddress, $port, $null, $null)
        $waitHandle = $connectAsync.AsyncWaitHandle
        $success = $waitHandle.WaitOne(100, $false)
        if ($success -and $tcpClient.Connected) {
            Write-Host "$ipAddress has port $port open" -ForegroundColor Cyan
        }
        $tcpClient.Close()
    }
}

# Ping all addresses in the subnet asynchronously
1..254 | ForEach-Object {
    $ipAddress = "$baseSubnet.$_"
    Test-PingAsync -ipAddress $ipAddress
}
