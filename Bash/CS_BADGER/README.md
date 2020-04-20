# CS_BADGER.sh

This script will automate Splunk searches in CrowdStrike! So you can take a search and feed the CSV or JSON output to automation LIKE A NORMAL PERSON!

![enter image description here](https://github.com/freeload101/SCRIPTS/blob/master/Bash/CS_BADGER/SCREEN_SHOTS/CS_BADGER.jpg?raw=true?raw=true)

VT SHA-256 Searc
![enter image description here](https://github.com/freeload101/SCRIPTS/blob/master/Bash/CS_BADGER/SCREEN_SHOTS/CS_BADGER_VT.jpg?raw=true?raw=true)


## Create a session using your 2FA token ( or add -q 'query' to search and then exit for single usage )
bash CS_BADGER.sh -t 555666

## Open new shell to use cookies from your session. Searches must start with search and be escaped by single quotes example:
bash CS_BADGER.sh -q 'search index=\* |head 1'

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

## Max searches is 8 by default in the script and 10 CrowdStrike. To clear jobs (sids) use -k option. 
When you get error message like:

The maximum number of concurrent historical searches on this instance has been reached. concurrency_limit=10"


bash CS_BADGER.py -k

![enter image description here](https://github.com/freeload101/SCRIPTS/blob/master/Bash/CS_BADGER/SCREEN_SHOTS/SC_BADGER_KILLALL.jpg?raw=true)

## TODO:
* detect 'maximum searches' and auto kill ?

* Add cookie valid checks

* Test/Add Support ?/Document single quote and doubble quote support within single quote example:

bash CS_BADGER.py -q 'search  

| rex field=your_field "\'(?<your_new_field>[^\']*)\'"

'

* Rewrite in Python with secure coding practices!
 

Badgers are known as the gruff and grumpy residents of hillsides and prairies. These striped-faced mustelids are expert excavators, skilled at plucking out earthworms, grubs, insects and all sorts of other critters. Badgers often are portrayed in movies and popular literature as wise and practical.

