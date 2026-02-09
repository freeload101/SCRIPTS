#!/bin/bash


# AI rewrote this script so may be gremlins but it looks better  :P 
#Key Changes
#Gateway Discovery Strategy:
 
#172.16-31.x: Scan only .1,.2,.3,.10,.20,.30,.50,.100,.200,.254 across all subnets (~2,560 IPs vs 1,048,576)
#10.x.x.x: Same approach (~655,360 IPs vs 16,777,216)
#192.168.x: Full scan (only 65,536 IPs, manageable)
#Two-stage approach for large ranges:
 
#Find active subnets via gateway IPs (fast)
#Scan only those /24s completely (targeted)
#Speed comparison for 10.x:
 
#Your approach: ~655K IPs to check for gateways
#Full /8 scan: ~16.7M IPs
#Your method is ~25x faster for discovery
#This combines your smart gateway discovery with the other optimizations. Expected runtime: 1-3 hours depending on how many active subnets exist.


# Configuration
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR="nmap_scan_${TIMESTAMP}"
mkdir -p "$LOG_DIR"
cd "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a scan.log
}

# Phase 1: Smart host discovery
log "Starting Phase 1: Smart Discovery"

# 192.168.0.0/16 - small enough to scan directly
log "Scanning 192.168.0.0/16 (full range)"
nmap -sn -T4 -n --min-rate 2000 --max-retries 1 \
    -oA 192_discovery 192.168.0.0/16 &
PID_192=$!

# 172.16-31.0-255 - scan common IPs to find active subnets
log "Scanning 172.16-31.x.x (gateway discovery)"
nmap -sn -T4 -n --min-rate 2000 --max-retries 1 \
    --min-parallelism 100 \
    -oA 172_gw_discovery \
    172.16-31.0-255.1,2,3,10,20,30,50,100,200,254 &
PID_172=$!

# 10.0-255.0-255 - scan common IPs to find active subnets
log "Scanning 10.x.x.x (gateway discovery)"
nmap -sn -T4 -n --min-rate 2000 --max-retries 1 \
    --min-parallelism 100 \
    -oA 10_gw_discovery \
    10.0-255.0-255.1,2,3,10,20,30,50,100,200,254 &
PID_10=$!

wait $PID_192 $PID_172 $PID_10
log "Phase 1 Complete"

# Phase 2: Expand to full /24 subnets where gateways found
log "Starting Phase 2: Subnet Expansion"

# Extract active /24 networks from 172 and 10
grep "Status: Up" 172_gw_discovery.gnmap | awk '{print $2}' | \
    sed -r 's/([0-9]+\.[0-9]+\.[0-9]+)\..*/\1.0\/24/' | \
    sort -u > 172_active_subnets.txt

grep "Status: Up" 10_gw_discovery.gnmap | awk '{print $2}' | \
    sed -r 's/([0-9]+\.[0-9]+\.[0-9]+)\..*/\1.0\/24/' | \
    sort -u > 10_active_subnets.txt

SUBNET_172=$(wc -l < 172_active_subnets.txt)
SUBNET_10=$(wc -l < 10_active_subnets.txt)
log "Found ${SUBNET_172} active /24s in 172.x, ${SUBNET_10} in 10.x"

# Scan full /24s for active subnets
if [ $SUBNET_172 -gt 0 ]; then
    nmap -sn -T4 -n --min-rate 2000 --max-retries 1 \
        -oA 172_subnet_discovery -iL 172_active_subnets.txt &
    PID_172_SUB=$!
fi

if [ $SUBNET_10 -gt 0 ]; then
    nmap -sn -T4 -n --min-rate 2000 --max-retries 1 \
        -oA 10_subnet_discovery -iL 10_active_subnets.txt &
    PID_10_SUB=$!
fi

wait $PID_172_SUB $PID_10_SUB 2>/dev/null
log "Phase 2 Complete"

# Phase 3: Port scan all live hosts
log "Starting Phase 3: Port Scanning"

grep "Status: Up" *_discovery.gnmap | awk '{print $2}' | sort -u > all_live_hosts.txt
LIVE_COUNT=$(wc -l < all_live_hosts.txt)
log "Found ${LIVE_COUNT} live hosts"

nmap -Pn -T4 -n --top-ports 100 --open \
    --min-rate 500 --max-retries 2 \
    -oA ports_scan -iL all_live_hosts.txt

log "Phase 3 Complete"

# Phase 4: Service detection on hosts with open ports
log "Starting Phase 4: Service Detection"

grep "open" ports_scan.gnmap | awk '{print $2}' | sort -u > hosts_with_ports.txt
PORTS_COUNT=$(wc -l < hosts_with_ports.txt)
log "Found ${PORTS_COUNT} hosts with open ports"

if [ $PORTS_COUNT -gt 0 ]; then
    nmap -Pn -T4 -sV --version-intensity 5 \
        --min-rate 300 --max-retries 2 \
        -oA service_detection -iL hosts_with_ports.txt
fi

log "Phase 4 Complete"

# Generate reports
log "Generating reports"

grep "open" *.gnmap | awk '{print $2}' | sort | uniq -c | sort -rn > all_ips_with_open.txt

grep "open" *.gnmap | awk '/Ports:/ {
    ip=$2; 
    sub(/.*Ports: /, ""); 
    gsub(/\/\/\//, ""); 
    print ip "," $0
}' > ip_portlist.csv

grep "open" *.gnmap | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" | \
    awk -F. '{print $1"."$2"."$3}' | sort | uniq -c | sort -rn | \
    awk '{print $1","$2}' > subnet_stats.csv

awk '/Host:.*Ports:/ {
    match($0, /Host: ([^ ]+) \(([^)]*)\).*Ports: (.*)/, arr);
    if (arr[3]) {
        cmd = "echo \"" arr[3] "\" | md5sum | cut -d\" \" -f1";
        cmd | getline hash;
        close(cmd);
        print arr[1] "," arr[2] "," hash "," arr[3];
    }
}' *.gnmap > ip_hash_ports.csv

log "Scan Complete - Results in ${LOG_DIR}"
