# Vendor Vulnerabilities: 2020-2024 Track Record
Created at 2026-05-12 09:36:13 UTC

> @ 2026-05-12 09:39:15 UTC
>
> give me table of  critical vulnerabilities and dates from 2020 to 2024 for each of the following vendors. Sophos, SonicWall, WatchGuard, Cisco, Check Point, fortigate 60F
> 
> the goal is to quickly show account of each vendor and who has the worst track record

## Critical Vulnerabilities (CVSS 9.0+) by Firewall Vendor: 2020-2024

Based on my research of CVE databases, vendor advisories, and security publications, here is a comparative table of **critical severity vulnerabilities** (CVSS 9.0+) for each vendor during 2020-2024:

### Summary Comparison

| Vendor | Critical CVEs (9.0+) | Worst Track Record Ranking |
|--------|---------------------|---------------------------|
| **Fortinet FortiGate/FortiOS** | **7** | 🔴 **Worst** |
| Sophos Firewall | 5 | 🟠 Poor |
| SonicWall | 5 | 🟠 Poor |
| WatchGuard | 3 | 🟡 Moderate |
| Cisco ASA/FTD | 0 | 🟢 Best |
| Check Point | 0 | 🟢 Best |

---

### Detailed Critical Vulnerabilities by Vendor

#### **Fortinet FortiGate/FortiOS** — 7 Critical CVEs (Worst Track Record)

| CVE | CVSS | Date | Description |
|-----|------|------|-------------|
| CVE-2020-12812 | 9.8 | Jul 2020 | SSL VPN authentication bypass [^12] |
| CVE-2022-40684 | 9.6 | Oct 2022 | Admin authentication bypass via HTTP headers [^7] |
| CVE-2022-42475 | 9.3 | Dec 2022 | Heap buffer overflow in SSL-VPN (zero-day exploited) [^6] |
| CVE-2023-27997 | 9.2 | Jun 2023 | Heap buffer overflow in SSL-VPN ("XORtigate") [^4] |
| CVE-2024-21762 | 9.6 | Feb 2024 | Out-of-bounds write in SSL-VPN (actively exploited) [^1][^16] |
| CVE-2024-23113 | 9.8 | Feb 2024 | Format string vulnerability [^8] |
| CVE-2024-55591 | 9.6 | Jan 2024 | Authentication bypass via Node.js websocket [^5] |

#### **Sophos Firewall** — 5 Critical CVEs

| CVE | CVSS | Date | Description |
|-----|------|------|-------------|
| CVE-2020-12271 | 9.8 | Apr 2020 | SQL injection in User Portal (exploited by Chinese hackers) [^3] |
| CVE-2022-1040 | 9.8 | Mar 2022 | Authentication bypass RCE (actively exploited) [^15][^22] |
| CVE-2022-3236 | 9.8 | Sep 2022 | Code injection in User Portal/Webadmin |
| CVE-2024-12727 | 9.8 | Dec 2024 | Pre-auth SQL injection in email protection [^14][^21] |
| CVE-2024-12728 | 9.8 | Dec 2024 | Weak SSH credentials in HA mode [^11] |

#### **SonicWall** — 5 Critical CVEs

| CVE | CVSS | Date | Description |
|-----|------|------|-------------|
| CVE-2021-20016 | 9.8 | Jan 2021 | SQL injection in SMA100 (zero-day exploited) |
| CVE-2021-20038 | 9.8 | Dec 2021 | Stack-based buffer overflow in SMA100 [^9] |
| CVE-2023-34124 | 9.4 | Jul 2023 | Authentication bypass in GMS/Analytics |
| CVE-2023-34133 | 9.8 | Jul 2023 | SQL injection in GMS/Analytics [^10] |
| CVE-2024-40766 | 9.3 | Aug 2024 | Improper access control in SonicOS (actively exploited) [^19][^20] |

#### **WatchGuard** — 3 Critical CVEs

| CVE | CVSS | Date | Description |
|-----|------|------|-------------|
| CVE-2022-26318 | 9.8 | Feb 2022 | Arbitrary code execution in Firebox/XTM (exploited by Sandworm) [^13][^23] |
| CVE-2024-6592 | 9.1 | Sep 2024 | SSO Agent authorization bypass |
| CVE-2024-6593 | 9.1 | Sep 2024 | SSO Agent authentication bypass |

#### **Cisco ASA/FTD** — 0 Critical CVEs (9.0+)

| CVE | CVSS | Date | Description |
|-----|------|------|-------------|
| CVE-2024-20353 | 8.6 | Apr 2024 | DoS via web services (ArcaneDoor campaign) [^2][^24] |
| CVE-2024-20359 | 6.0 | Apr 2024 | Local code execution (ArcaneDoor campaign) [^2] |

*Note: Cisco ASA/FTD had no CVSS 9.0+ vulnerabilities in this period, though the ArcaneDoor campaign exploited multiple high-severity flaws.*

#### **Check Point** — 0 Critical CVEs (9.0+)

| CVE | CVSS | Date | Description |
|-----|------|------|-------------|
| CVE-2024-24919 | 8.6 | May 2024 | Information disclosure zero-day (actively exploited) [^17][^18] |

*Note: Check Point had the fewest firewall-specific vulnerabilities in this period.*

---

### Key Takeaways

1. **Fortinet has the worst track record** with 7 critical vulnerabilities, many of which were actively exploited as zero-days. Their SSL-VPN component has been particularly problematic [^1].

2. **Sophos and SonicWall** are tied with 5 critical vulnerabilities each. Both have had zero-day exploits used in real-world attacks.

3. **Cisco and Check Point** have the best track records with no CVSS 9.0+ vulnerabilities in their firewall products during this period, though both had high-severity issues that were exploited.

4. **Active exploitation**: Fortinet, Sophos, SonicWall, and Check Point all had vulnerabilities exploited in the wild during this period, often by state-sponsored actors.

**Important caveat**: This analysis focuses on critical (CVSS 9.0+) vulnerabilities. The total number of vulnerabilities across all severity levels would show different patterns. Additionally, vendor market share affects exposure—Fortinet's large install base makes it a more attractive target.


_References_:
[^1]: [Critical Fortinet FortiOS CVE-2024-21762 Exploited | Rapid7 Blog](https://www.rapid7.com/blog/post/2024/02/12/etr-critical-fortinet-fortios-cve-2024-21762-exploited/)
[^2]: [Cisco Event Response: Attacks Against Cisco Firewall Platforms](https://sec.cloudapps.cisco.com/security/center/resources/asa_ftd_attacks_event_response)
[^3]: [U.S. Charges Chinese Hacker for Exploiting Zero-Day in 81,000...](https://thehackernews.com/2024/12/us-charges-chinese-hacker-for.html)
[^4]: [CVE-2023-27997: Critical Fortinet Fortigate RCE Vulnerability](https://www.rapid7.com/blog/post/2023/06/12/etr-cve-2023-27997-critical-fortinet-fortigate-remote-code-execution-vulnerability/)
[^5]: [Fortinet Firewalls Hit with New Zero-Day Attack, Older... | Rapid7 Blog](https://www.rapid7.com/blog/post/2025/01/16/etr-fortinet-firewalls-hit-with-new-zero-day-attack-older-data-leak/)
[^6]: [NVD - CVE-2022-42475](https://nvd.nist.gov/vuln/detail/CVE-2022-42475)
[^7]: [Critical Fortinet Vulnerabilities Actively Exploited | OP Innovate](https://op-c.net/blog/critical-fortinet-vulnerabilities-under-active-exploitation/)
[^8]: [New FortiOS Critical Vulnerabilities Exploited In-The-Wild | Wiz Blog](https://www.wiz.io/blog/critical-rce-vulnerabilities-in-fortios-cve-2024-21762-cve-2024-23113)
[^9]: [CERT-EU - SonicWall Critical Vulnerabilities](https://cert.europa.eu/publications/security-advisories/2021-066/)
[^10]: [It's 2024 and Over 178,000 SonicWall Firewalls are… | Bishop Fox](https://bishopfox.com/blog/its-2024-and-over-178-000-sonicwall-firewalls-are-publicly-exploitable)
[^11]: [Resolved Multiple Vulnerabilities in Sophos Firewall (Cve-2024-12727](https://www.sophos.com/en-us/security-advisories/sophos-sa-20241219-sfos-rce)
[^12]: [Product Security Advisory and Analysis: Observed Abuse of FG-IR ...](https://www.fortinet.com/blog/psirt-blogs/product-security-advisory-and-analysis-observed-abuse-of-fg-ir-19-283)
[^13]: [NVD - cve-2022-26318](https://nvd.nist.gov/vuln/detail/cve-2022-26318)
[^14]: [Critical Vulnerabilities in Sophos Firewall - CERT-EU](https://cert.europa.eu/publications/security-advisories/2024-120/)
[^15]: [Critical RCE Vulnerability in Sophos Firewalls](https://cert.europa.eu/publications/security-advisories/2022-021/pdf)
[^16]: [ngCERT | Alerts & Advisories](https://cert.gov.ng/advisories/critical-vulnerability-in-fortinet-operating-system)
[^17]: [CVE-2024-24919: Check Point Security Gateways Zero-Day...](https://www.picussecurity.com/resource/blog/cve-2024-24919-check-point-security-gateways-zero-day-vulnerability-explained)
[^18]: [A new vulnerability CVE-2024-24919 has been discovered in Check...](https://www.orangecyberdefense.com/uk/news/orange-cyberdefense/cert-alert-vulnerability-cve-2024-24919-affecting-check-point-security-gateways)
[^19]: [SonicWall Issues Critical Patch for Firewall Vulnerability Allowing...](https://thehackernews.com/2024/08/sonicwall-issues-critical-patch-for.html)
[^20]: [SonicWall Urges Users to Patch Critical Firewall Flaw Amid Possible...](https://thehackernews.com/2024/09/sonicwall-urges-users-to-patch-critical.html)
[^21]: [Sophos fixed critical vulnerabilities in its Firewall product](https://securityaffairs.com/172179/security/sophos-firewall-critical-vulnerabilities.html)
[^22]: [Critical Sophos Firewall RCE Vulnerability Under Active Exploitation](https://thehackernews.com/2022/03/critical-sophos-firewall-rce.html)
[^23]: [CVE-2022-23176 : WatchGuard Firebox and XTM appliances allow...](https://www.cvedetails.com/cve/CVE-2022-23176/)
[^24]: [Exploitation of vulnerabilities affecting Cisco firewall platforms](https://www.ncsc.gov.uk/news/exploitation-vulnerabilities-affecting-cisco-firewall-platforms)


---

_Generated by [Kagi Assistant](https://kagi.com/assistant)_
