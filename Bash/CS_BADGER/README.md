# CS_BADGER.sh a CrowdStrike Spunk "API"
 
 
This script will automate Splunk searches in CrowdStrike! So you can take a search and feed the CSV or JSON output to automation LIKE A NORMAL PERSON!

*Badgers are known as the gruff and grumpy residents of hillsides and prairies. These striped-faced mustelids are expert excavators, skilled at plucking out earthworms, grubs, insects and all sorts of other critters. Badgers often are portrayed in movies and popular literature as wise and practical.*

## 1) Install Cygwin
https://github.com/vegardit/cygwin-portable-installer/blob/main/cygwin-portable-installer.cmd

## 2) Start a new bash shell by running "cygwin-portable.cmd" after install/setup is complete

## 3) Download CS_BADGER.sh with wget 
wget 'https://github.com/freeload101/SCRIPTS/raw/master/Bash/CS_BADGER/CS_BADGER.sh'

## 4) Edit the the config section to the username and password you want to use in CS in CS_BADGER.sh file

## 5) Create a session in CS_BADGER using your MFA token for CS
./CS_BADGER.sh -t ######

## 5) Open a new tab in cygwin by pressing the green '+' sign

## 6) Perform any CS splunk search you like! Results will be in file called results.json
./CS_BADGER.sh -q 'search index=* | head 1'


## You can also use multi line search like so

bash CS_BADGER.sh -q 'search event_simpleName=\*ProcessRollup2 

[search event_simpleName="UserAccountCreated" 

| rename RpcClientProcessId as TargetProcessId_decimal 

| rename UserName as UserName_UserAccountCreated 

| fields aid TargetProcessId_decimal UserName ] 

|  regex CommandLine!="(?i)something\.exe"

| stats count values(SHA256HashData) values(UserName) values(CommandLine) by  FileName

| sort -count

'

## Max searches is 99 by default in the script and 10 in CrowdStrike. To clear jobs (sids) use -k option. 
When you get error message like:

The maximum number of concurrent historical searches on this instance has been reached. concurrency_limit=10"

bash CS_BADGER.py -k

![enter image description here](https://github.com/freeload101/SCRIPTS/blob/master/Bash/CS_BADGER/SCREEN_SHOTS/SC_BADGER_KILLALL.jpg?raw=true)

# See Also CrowdStrike Threat Hunting Splunk SPL queries! 
https://github.com/freeload101/SCRIPTS/tree/master/CrowdStrike%20Threat%20Hunting 

```
Usage:
Update ##### CONFIG section of this script
./CS_BADGER.sh -t 2FA_TOKEN (Run in screen or in the background to keep session)
./CS_BADGER.sh -q ‘QUERY’ if you already have active cookie session
./CS_BADGER.sh -h ‘Virus Total Hash’
./CS_BADGER.sh -j kill (Kills all sids and jobs)
./CS_BADGER.sh -j pluck (Runs a example batch job of 7day DNS,Network and Process for each host with detections)
./CS_BADGER.sh -u file.json (Upload .json file to Splunk using HTTP Event Collector (HEC) Example -j upload results.json
```

Example Output
![enter image description here](https://github.com/freeload101/SCRIPTS/blob/master/Bash/CS_BADGER/SCREEN_SHOTS/CS_BADGER.jpg?raw=true?raw=true)

Example CrowdStrike to Splunk running on https://localhost:8080
![image](https://user-images.githubusercontent.com/4307863/154322725-4f326554-0093-42d9-a245-104eb1aa90ec.png)

VT SHA-256 Hash Search!! 
![enter image description here](https://github.com/freeload101/SCRIPTS/blob/master/Bash/CS_BADGER/SCREEN_SHOTS/CS_BADGER_VT.jpg?raw=true?raw=true)


## Updates:
** 02/16/2022: Upload .json file to Splunk using HTTP Event Collector (HEC)!!!  **


## TODO:
* detect 'maximum searches' and auto kill ?

* Add cookie valid checks

* Add config yaml file and rewrite in Python

* Test/Add Support ?/Document single quote and doubble quote support within single quote example:

bash CS_BADGER.py -q 'search  

| rex field=your_field "\'(?<your_new_field>[^\']*)\'"

'

* Rewrite in Python with secure coding practices!
 
 


*get CS_BADGER working in python ( reference working python code I was given from linkedin ) https://github.com/freeload101/SCRIPTS/tree/master/Bash/CS_BADGER

*get SAML working in PING SSO with python  ( https://sso.COMPANY.com/XXXXXXXXXXXXXX/XXXXXXXXXXXXX.ping?PartnerSpId=https%3A%2F%2Ffalcon.crowdstrike.com%2Fsaml%2Fmetadata )

*combine SAML and CS_BADGER python into a single script

*work out the logic / design of how the script could be used as a splunk app

-provide verbose output for debugging

-allow any input into the script from ES example "give me ES SrcIP from an alert and make it a input to badger Splunk app so that ES alerts have CS Threat hunting results in them 
based on IOA;s like SRC,DEST,PORT,USERNAME etc )

-sort out howto properly add data to a index and/or get suggestions from Andy on howto get the data in Splunk besides maybe just a |outputlookup/append

*get requirements for input of the Splunk app (username:password,hash,SSO URL,security ?)

*Convert the python script to Splunk app

*Publish APP to internet and Splunk app store for free and sit-back and enjoy the vendors hating on your for making it easy to get data into Splunk from Croudstrike


Future state:

* scores come back to weight the alert so for example if a IP hit happens on a host and a new IOC is found in that search it's searched back against ES and CS Splunk and maybe it finds 4 other host that have the same security events in CS Splunk that we missed some how etc ....

* Start to  automate Threat hunting searches in CS be sent to ES  based off of https://github.com/freeload101/SCRIPTS/tree/master/CrowdStrike%20Threat%20Hunting
















*Badgers are known as the gruff and grumpy residents of hillsides and prairies. These striped-faced mustelids are expert excavators, skilled at plucking out earthworms, grubs, insects and all sorts of other critters. Badgers often are portrayed in movies and popular literature as wise and practical.*


