# Define the base subnet without the last octet
$baseSubnet = "10.110.0"

# This function pings a single IP address
function Test-PingAsync {
    param(
        [string]$ipAddress
    )

    $ping = New-Object System.Net.NetworkInformation.Ping
    $ping.SendPingAsync($ipAddress, 150) | ForEach-Object {
    Write-Host "$ipAddress Scanning" -ForegroundColor Green
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

    21,22,23,25,53,80,81,135,139,143,443,445,993,995,1723,3000,3306,3389,5900,8080,8081,8800,8099,8100,8443,32000,33000,34000,36000 | ForEach-Object {
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
