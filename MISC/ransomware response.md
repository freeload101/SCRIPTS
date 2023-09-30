Credit: Nate @slackgo_t1482dya3-u9m2qcg0y:beeper.local 7minsec Slack Channel


Here’s a stripped down version of a playbook I compiled for ransomware response: General Process

1.  Take a deep breath because you’re in for a long week or two. Call family and let them know you’ll be late.
    
2.  Reference an existing CIRP for any pre-defined processes and out-of-band communications tactics.
    
3.  Contact cybersecurity insurance firm if possible (highly recommended)
    

a. They will gather legal/DFIR firms and help navigate the process b. An IR firm/MSP will likely want to push an EDR agent to all devices.

1.  Identify the impact and scope.
    

a. Identify if there's any potential impact/risk to our customer networks.

1.  Check for SAN/NAS/3rd party solution backups and pause all snapshots
    
2.  Gather pre-defined team and establish a cadence for updates. Don’t forget an out-of-band method if there are still likely active threats on network or email/phones are down.
    

a. Work with communication team to provide pre-built initial response for website b. Notify parties as defined by applicable regulations

1.  Shutdown/isolate non-affected devices/networks to minimize impact
    
2.  Reset administrator/domain admins/enterprise admin credentials.
    
3.  Reset kbrtgt credentials (x2) to ensure no golden tickets in network. ([https://d](https://d/)[ocs.microsoft.com/en-us/windows-server/identity/ad-ds/manage/ad-forest-recovery-resetting-the-krbtgt-password#:~:text=The%20password%20history%20value%20for,by%20using%20an%20old%20password.)](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/manage/ad-forest-recovery-resetting-the-krbtgt-password#:~:text=The%20password%20history%20value%20for,by%20using%20an%20old%20password)
    

[a. P](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/manage/ad-forest-recovery-resetting-the-krbtgt-password#:~:text=The%20password%20history%20value%20for,by%20using%20an%20old%20password)assword doesn't matter.

1.  Reset all credentials in network
    

a. Likely going to break many items, but it’s better than ransomware b. Having a script ready to go is helpful!

1.  Submit an IC3 complaint with legal guidance if in USA
    

a. If located in WI, use [https://det.w](https://det.w/)[i.gov/Pages/Cyber-Response-Teams.aspx as a resourc](https://det.wi.gov/Pages/Cyber-Response-Teams.aspx)e.

1.  IR firm will need to do forensic captures.
    

a. They typically give basic instructions. If org isn’t very technical, may need assistance gathering evidence such as vmdk files.

1.  Begin restoration efforts after forensic capture is completed.
    
2.  IR firm will communicate with ransomware attackers to identify what the initial demand is and if any data was exfiltrated
    

a. They will likely use the Ackerman bargaining model for negotiations.

1.  For USA orgs, the crypto wallet will be checked against the OFAC list to ensure payment is not prohibited.
    

a. [https://home.treasury](https://home.treasury/)[.gov/system/files/126/ofac_ransomware_advisory_10012020_1.pdf](https://home.treasury.gov/system/files/126/ofac_ransomware_advisory_10012020_1.pdf) [b. https://home.tr](https://home.treasury.gov/system/files/126/ofac_ransomware_advisory_10012020_1.pdf)easury[.gov/policy-issues/financial-sanctions/faqs/topic/1626](https://home.treasury.gov/policy-issues/financial-sanctions/faqs/topic/1626) [c. https://sanctio](https://home.treasury.gov/policy-issues/financial-sanctions/faqs/topic/1626)nssear[ch.ofac.treas.gov/](https://sanctionssearch.ofac.treas.gov/)

1.  [Determine if rans](https://sanctionssearch.ofac.treas.gov/)om should be paid.
    
2.  Slowly finish the recovery efforts and deal with any residual consequences.
    
3.  Take time off to recover.
