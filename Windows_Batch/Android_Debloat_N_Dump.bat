@echo off
setlocal enabledelayedexpansion

echo '-----------------------------------------------------------------------------------------'
echo 'rmccurdy.com ( Android_Debloat_N_Dump )'
echo ' This script will:
echo ' * Uninstall and disable any apps listed online as bloat'
echo ' * Dump the app name example com.vzw.ecid and the friendly name "Verizon Call Filter" to easily identidfy what apps to uninstall or disable by hand'
echo '-----------------------------------------------------------------------------------------'

CALL :INIT

CALL :UNINSTALL

CALL :DUMPAPKINFO

CALL :END


:INIT

cd "%~dp0"

echo %date% %time% INFO: Checking for adb.exe
if not exist ".\platform-tools\adb.exe" (
echo %date% %time% INFO: Downloading adb.exe from "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
		powershell "(New-Object Net.WebClient).DownloadFile('https://dl.google.com/android/repository/platform-tools-latest-windows.zip', '.\platform-tools-latest-windows.zip')" > %temp%/null
		powershell "Expand-Archive .\platform-tools-latest-windows.zip -DestinationPath .\ "  > %temp%/null
	)


echo %date% %time% INFO: Checking for aapt2 (to get info from apks)
if not exist ".\aapt2" (
echo %date% %time% INFO: Downloading aapt2 from "https://github.com/JonForShort/android-tools/raw/master/build/android-11.0.0_r33/aapt2/armeabi-v7a/bin/aapt2"
		powershell "(New-Object Net.WebClient).DownloadFile('https://github.com/JonForShort/android-tools/raw/master/build/android-11.0.0_r33/aapt2/armeabi-v7a/bin/aapt2', '.\aapt2')" > %temp%/null
	)


 
echo %date% %time% "Please make sure you click allow on your device when prompted.  Plug in your phone and disable/re-enable USB Debuging and press any key."
pause

echo %date% %time% INFO: Pushing aapt2 to /data/local/tmp/ you may need to change the path to a read write path
cd "%~dp0platform-tools"

echo %date% %time% INFO: Killing any existing adb server
.\adb.exe kill-server
.\adb.exe kill-server
.\adb.exe kill-server

EXIT /B %ERRORLEVEL%
 

:DUMPAPKINFO
echo %date% %time% INFO: Dumping all package information to DUMPAPKINFO.txt this will take upto 10 minutes or more
.\adb.exe push ..\aapt2 /data/local/tmp/
.\adb.exe shell "chmod 777  /data/local/tmp/aapt2"

::powershell  -command "& { $ErrorActionPreference= 'silentlycontinue';$BBList = cmd /c .\adb.exe shell pm list packages| Select-String -Pattern '.*verizon.*' ; $BBList -replace 'package:','' | ForEach-Object { $ApkPath = (cmd /c .\adb.exe shell pm path ($_)).replace(\"package:\",\"\") ;  Write-Output '###################################'  ; cmd /c .\adb.exe shell /data/local/tmp/aapt2 dump badging \"$ApkPath\"  | Where-Object { if($_ -like \"package:*\"){Write-Host $_}elseif($_ -like \"versionName:*\"){Write-Host $_ }elseif($_ -like \"application-label*\"){Write-Host \"$_\";break} }   }    }   "  > DUMPAPKINFO.txt
::powershell  -command "& { $ErrorActionPreference= 'silentlycontinue';$BBList = cmd /c .\adb.exe shell pm list packages | Select-String -Pattern '.*com.vzw.apnlib.*' ; $BBList -replace 'package:','' | ForEach-Object { $ApkPath = (cmd /c .\adb.exe shell pm path ($_)).replace(\"package:\",\"\") ;  Write-Output '###################################'  ; cmd /c .\adb.exe shell /data/local/tmp/aapt2 dump badging \"$ApkPath\"  | Where-Object { if($_ -like \"package:*\"){Write-Host $_}elseif($_ -like \"versionName:*\"){Write-Host $_ }elseif($_ -like \"application-label*\"){Write-Host \"$_\";break} }   }    }   "  > DUMPAPKINFO.txt
powershell  -command "& { $ErrorActionPreference= 'silentlycontinue';$BBList = cmd /c .\adb.exe shell pm list packages   ; $BBList -replace 'package:','' | ForEach-Object { $ApkPath = (cmd /c .\adb.exe shell pm path ($_)).replace(\"package:\",\"\") ;  Write-Output '###################################'  ; cmd /c .\adb.exe shell /data/local/tmp/aapt2 dump badging \"$ApkPath\"    | Where-Object { if($_ -like \"package:*\"){Write-Host $_}elseif($_ -like \"versionName:*\"){Write-Host $_ }elseif($_ -like \"application-label*\"){Write-Host \"$_\";break} }     }    }   "  > DUMPAPKINFO.txt
start DUMPAPKINFO.txt
EXIT /B %ERRORLEVEL%



:UNINSTALL

echo %date% %time% INFO: Running mass uninstall/disable 
::Credit: 
::system/app/PlayAutoInstallConfig/PlayAutoInstallConfig.apk"
::# Credits: https://forum.xda-developers.com/galaxy-note-8/how-to/list-software-packages-apps-disabled-t3676131/page3"
::# Bloatware according to serajr (Sony apps not included)"
::# Credits: https://forum.xda-developers.com/galaxy-note-8/how-to/list-software-packages-apps-disabled-t3676131/page3"
::# Bloatware according to serajr (Sony apps not included)"
::# Credits: Neo3D https://forum.xda-developers.com/galaxy-s8/how-to/s8-debloat-bloatware-thread-t3669009"
::# Note: This is copy and pasted into priv-app too because I'm unsure If they are in app or priv-app"

cd "%~dp0platform-tools"


for %%x in (
REMOVE_IF_YOU_HAVE_YOUR_OWN_LAUNCHER_LIKE_NOVAcom.sec.android.app.launcher
com.telecomsys.directedsms.android.SCG
com.vzw.ecid
com.securityandprivacy.android.verizon.vms
com.verizon.onetalk.dialer
com.customermobile.preload.vzw
com.samsung.android.app.tips
com.LogiaGroup.LogiaDeck
com.telecomsys.directedsms.android.SCG
com.samsung.vzwapiservice
com.verizon.obdm_permissions
com.verizon.mips.services
com.vzw.apnlib
com.zynga.gotslots
com.apple.android.music
com.squareup.cash
com.verizon.familybase.parent
com.sec.android.inputmethod
com.tripledot.solitaire
com.vzw.ecid
com.dreamgames.royalmatch
com.disney.disneyplus
com.tripledot.woodoku   
tv.pluto.android
com.stitcher.app
com.yahoo.mobile.client.android.sportacular
com.yahoo.mobile.client.android.yahoo
com.yahoo.mobile.client.android.finance
com.securityandprivacy.android.verizon.vms
com.netflix.mediaclient
com.opera.app.news

android.autoinstalls.config.samsung
com.facebook.appmanager
com.gd.mobicore.pa
com.google.android.gm
com.google.android.syncadapters.calendar
com.google.android.syncadapters.contacts
com.hiya.star
com.samsung.android.app.clipboardedge
com.samsung.android.app.talkback
com.samsung.android.app.withtv
com.amazon.mShop.android.shopping
com.amazon.kindle
com.s.antivirus
com.google.android.apps.docs
com.google.android.apps.tachyon
com.google.android.printservice.recommendation
com.android.htmlviewer
com.google.android.apps.maps
com.android.keychain
com.android.providers.partnerbookmarks
com.dsi.ant.sample.acquirechannels
com.dsi.ant.service.socket
com.dsi.ant.server
com.dsi.ant.plugins.antplus
flipboard.boxer.app
com.cnn.mobile.android.phone.edgepanel
com.sec.android.easyonehand
com.samsung.android.widgetapp.yahooedge.finance
com.android.dreams.phototable
com.android.printspooler
com.samsung.android.widgetapp.yahooedge.sport
com.samsung.android.spdfnote
com.sec.android.daemonapp
com.samsung.android.weather
com.samsung.android.app.reminder
com.hancom.office.editor.hidden
com.samsung.android.keyguardwallpaperupdator
com.samsung.android.app.news
com.android.egg
com.sec.android.app.sbrowser
com.samsung.android.app.sbrowseredge
com.samsung.android.email.provider
com.wsomacp
com.facebook.katana
com.facebook.system
com.facebook.services
com.samsung.android.hmt.vrsvc
com.samsung.android.app.vrsetupwizardstub
com.samsung.android.hmt.vrshell
com.google.vr.vrcore
com.samsung.android.app.ledcoverdream
com.sec.android.cover.ledcover
com.sec.android.app.desktoplauncher
com.sec.android.app.withtv
com.verizon.mips.services
com.turner.cnvideoapp
com.vzw.hss.myverizon
com.sec.android.app.voicenote
com.vcast.mediamanager
com.samsung.android.bixby.agent
com.sec.android.gallery3d
com.samsung.android.bixby.es.globalaction
com.samsung.android.service.peoplestripe
com.sec.android.desktopmode.uiservice
com.samsung.android.app.taskedge
com.samsung.ecomm
com.google.android.street
com.sec.android.app.myfiles
com.customermobile.preload.vzw
com.telecomsys.directedsms.android.SCG
com.sec.android.app.quicktool
com.samsung.android.bixby.wakeup
com.samsung.android.bixby.plmsync
com.samsung.android.spayfw
com.samsung.android.spay
com.samsung.android.app.notes
com.samsung.android.app.spage
com.LogiaGroup.LogiaDeck
com.sec.android.easyMover
com.samsung.android.visionintelligence
net.sharewire.parkmobilev2
com.samsung.android.app.watchmanagerstub
com.asurion.android.verizon.vms
com.samsung.android.bixby.voiceinput
com.samsung.android.app.appsedge
com.samsung.systemui.bixby
com.verizon.messaging.vzmsgs
com.samsung.android.bixby.agent.dummy
com.google.android.feedback
com.google.android.onetimeinitializer
com.microsoft.office.excel
com.microsoft.office.powerpoint
com.samsung.android.app.assistantmenu
com.samsung.android.app.galaxyfinder
com.samsung.android.dqagent
com.samsung.enhanceservice
com.google.android.backuptransport
com.android.inputdevices
com.android.sharedstoragebackup
org.simalliance.openmobileapi.service
com.android.stk
com.android.apps.tag
com.sec.android.widgetapp.samsungapps
com.android.cellbroadcastreceiver
com.sonymobile.cellbroadcast.notification
com.samsung.svoice.sync
com.samsung.android.app.watchmanager
com.samsung.android.drivelink.stub
com.samsung.android.svoice
com.samsung.android.app.memo
com.sec.spp.push
com.sec.android.app.shealth
com.samsung.android.voicewakeup
com.samsung.voiceserviceplatform
com.sec.android.sidesync30
com.android.exchange
com.samsung.groupcast
com.sec.android.service.health
com.sec.kidsplat.installer
com.sec.android.widgetapp.diotek.smemo
com.sec.android.provider.snote
com.sec.android.app.translator
com.vlingo.midas
com.sec.readershub
com.sec.android.app.gamehub
com.sec.everglades.update
com.sec.everglades
tv.peel.samsung.app
com.sec.yosemite.phone
com.samsung.android.app.episodes
com.samsung.android.app.storyalbumwidget
com.samsung.android.tripwidget
com.samsung.android.service.travel
com.tripadvisor.tripadvisor
com.android.email
com.sec.android.app.ocr
       ) do (
		echo Trying to Uninstall:		%%x
        .\adb.exe shell "pm uninstall --user 0 %%x"
		echo Trying to Disable:		%%x
		.\adb.exe shell pm disable-user --user 0
       )

EXIT /B %ERRORLEVEL%



:END
echo %date% %time% INFO: Killing any existing adb server
.\adb.exe kill-server
.\adb.exe kill-server
.\adb.exe kill-server
echo %date% %time% INFO: All done
pause
exit
