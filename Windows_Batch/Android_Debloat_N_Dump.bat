::@echo off
setlocal enabledelayedexpansion

echo '-----------------------------------------------------------------------------------------'
echo 'rmccurdy.com ( Android_Debloat_N_Dump )'
echo ' This script will:'
echo ' * DISABLED!!!!: Uninstall and disable any apps listed online as bloat'
echo ' * Dump the app name example com.vzw.ecid and the friendly name "Verizon Call Filter" to easily identidfy what apps to install or disable by hand'
echo '-----------------------------------------------------------------------------------------'

CALL :INIT
:: THIS IS NOT WORKING ON MY S10E CALL :ADGUARD
CALL :BACKUP
CALL :TWEAKS
CALL :GETINFO
:: This basicly brinks your phone ... so don't use it ... just example code here CALL :UNINSTALL
CALL :DUMPAPKINFO
CALL :DUMPAPK
CALL :END


:INIT
echo [+] %date% %time% "WARNING THIS SCRIPT DOES NOT SUPPORT MULTIPLE ADB DEVICES OR USERS !!!! "
CHOICE /T 8 /C y /CS /D y > %~dp0\null

cd "%~dp0"
 
 
set PATH = %PATH%;"%~dp0platform-tools"

echo [+] %date% %time% INFO: Installing ExplorerPatcher
powershell -Command "$downloadUri = ((Invoke-RestMethod -Method GET -Uri 'https://api.github.com/repos/valinet/ExplorerPatcher/releases/latest').assets | Where-Object name -like '*.exe').browser_download_url; Invoke-WebRequest -Uri $downloadUri -OutFile 'C:\windows\ep_setup.exe'"
"C:\windows\ep_setup.exe"



echo [+] %date% %time% INFO: Checking for adb.exe
 if not exist "%~dp0platform-tools\adb.exe" (
echo [+] %date% %time% INFO: Downloading adb.exe from "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
	powershell "(New-Object Net.WebClient).DownloadFile('https://dl.google.com/android/repository/platform-tools-latest-windows.zip', '%~dp0platform-tools-latest-windows.zip')" 
	powershell "Expand-Archive %~dp0platform-tools-latest-windows.zip -DestinationPath "%temp%" -force "  
	xcopy /Y /S /I "%TEMP%\platform-tools" %~dp0platform-tools
)


echo [+] %date% %time% INFO: Checking for aapt2 (to get info from apks)
if not exist "%~dp0aapt2" (
echo [+] %date% %time% INFO: Downloading aapt2 from "https://github.com/JonForShort/android-tools/raw/master/build/android-11.0.0_r33/aapt2/armeabi-v7a/bin/aapt2"
	powershell "(New-Object Net.WebClient).DownloadFile('https://github.com/JonForShort/android-tools/raw/master/build/android-11.0.0_r33/aapt2/armeabi-v7a/bin/aapt2', '%TEMP%\aapt2')"
copy "%TEMP%\aapt2" %~dp0
)



 
echo [+] %date% %time% "Please make sure you click allow on your device when prompted.  Plug in your phone and disable/re-enable USB Debuging and revoke USB auth. Press any key."
CHOICE /T 3 /C y /CS /D y > %~dp0\null

echo [+] %date% %time% INFO: Trying to find and kill processes on port 5563 that will break adb  
FOR /F "tokens=5 " %%A in ('netstat -ano ^| findstr :5563') do (
echo [+] %date% %time% INFO: Killing process PID "%%A"
taskkill /PID %%A /F
)


echo [+] %date% %time% INFO: Killing any existing adb server
"%~dp0platform-tools\adb.exe" kill-server

:: kill all nox app player adb and adb ..
taskkill /F /IM adb.exe 2> %~dp0\null
taskkill /F /IM nox_adb.exe 2> %~dp0\null

CHOICE /T 3 /C y /CS /D y > %~dp0\null

echo [+] %date% %time% INFO: Trying to find non offline Android devices
FOR /F "tokens=1 skip=1 " %%A in ('adb devices^|find /V "offline" ') do (
echo [+] %date% %time% INFO: Setting emulator device to "%%A"
set VAREMU=%%A
)


EXIT /B %ERRORLEVEL%


:TWEAKS
echo [+] %date% %time% INFO: Disabling wake on tap and lift to save battery  
"%~dp0platform-tools\adb.exe" shell "settings put system lift_to_wake 0"
"%~dp0platform-tools\adb.exe" shell "adb shell settings put secure wake_gesture_enabled 0"
EXIT /B %ERRORLEVEL%

:BACKUP
echo [+] %date% %time% INFO: Running legacy adb backup command 
adb backup -apk -shared -all -f backup.ab
EXIT /B %ERRORLEVEL%


:DUMPAPK
mkdir APKS
cd .\APKS

echo [+] %date% %time% INFO: Disabling PowerShell Executionpolicy
@powershell.exe   -Enc UwBlAHQALQBFAHgAZQBjAHUAdABpAG8AbgBQAG8AbABpAGMAeQAgAC0ARQB4AGUAYwB1AHQAaQBvAG4AUABvAGwAaQBjAHkAIABVAG4AcgBlAHMAdAByAGkAYwB0AGUAZAAgAC0ARgBvAHIAYwBlAA== 

echo [+] %date% %time% INFO: Downloading Dump_Apk.ps1
powershell -nop -c "iex(New-Object Net.WebClient).DownloadString('https://github.com/freeload101/SCRIPTS/raw/master/Windows_Powershell_ps/Dump_Apk.ps1')"

EXIT /B %ERRORLEVEL%


:DUMPAPKINFO
echo [+] %date% %time% INFO: Pushing aapt2 to /data/local/tmp/ you may need to change the path to a read write path

echo [+] %date% %time% INFO: Dumping all package information to DUMPAPKINFO.txt this will take upto 10 minutes or more
"%~dp0platform-tools\adb.exe" push "%~dp0aapt2 /data/local/tmp/
"%~dp0platform-tools\adb.exe" shell "chmod 777  /data/local/tmp/aapt2"

powershell  -command "& { $ErrorActionPreference= 'silentlycontinue';$BBList = cmd /c "%~dp0platform-tools\adb.exe" shell pm list packages   ; $BBList -replace 'package:','' | ForEach-Object { $ApkPath = (cmd /c "%~dp0platform-tools\adb.exe" shell pm path ($_)).replace(\"package:\",\"\") ;  Write-Output '###################################'  ; cmd /c "%~dp0platform-tools\adb.exe" shell /data/local/tmp/aapt2 dump badging \"$ApkPath\"    | Where-Object { if($_ -like \"package:*\"){Write-Host $_}elseif($_ -like \"versionName:*\"){Write-Host $_ }elseif($_ -like \"application-label*\"){Write-Host \"$_\";break} }     }    }   "  > DUMPAPKINFO.txt
start DUMPAPKINFO.txt
EXIT /B %ERRORLEVEL%

:GETINFO
echo [+] %date% %time% INFO: Listing users on device
"%~dp0platform-tools\adb.exe" shell "pm list users" > GETINFO.txt

echo [+] %date% %time% INFO: Please wait running top to show possible high CPU processes...
"%~dp0platform-tools\adb.exe" shell "top -b -n 5 -m 10 -o  PID,USER,PR,NI,VIRT,RES,SHR,S,%%CPU,%%MEM,TIME+,CMDLINE" >> GETINFO.txt

start GETINFO.txt
EXIT /B %ERRORLEVEL%

:ADGUARD
CHOICE /C YN /N /T 5 /D Y /M "Enable adguard global adblock (private dns setting) Y/N?"
IF ERRORLEVEL 1 SET adguard=YES
IF ERRORLEVEL 2 SET adguard=NO
SET ERRORLEVEL=0

IF "%adguard%" == "YES" (
"%~dp0platform-tools\adb.exe" shell settings put global private_dns_mode hostname
"%~dp0platform-tools\adb.exe" shell settings put global private_dns_specifier dns.adguard.com
)

IF "%adguard%" == "NO" (
adb shell settings put global private_dns_mode off
)
SET ERRORLEVEL=0
EXIT /B %ERRORLEVEL%





:UNINSTALL


echo [+] %date% %time% INFO: Running mass uninstall/disable 
::Credit: 
::system/app/PlayAutoInstallConfig/PlayAutoInstallConfig.apk"
::# Credits: https://forum.xda-developers.com/galaxy-note-8/how-to/list-software-packages-apps-disabled-t3676131/page3"
::# Bloatware according to serajr (Sony apps not included)"
::# Credits: https://forum.xda-developers.com/galaxy-note-8/how-to/list-software-packages-apps-disabled-t3676131/page3"
::# Bloatware according to serajr (Sony apps not included)"
::# Credits: Neo3D https://forum.xda-developers.com/galaxy-s8/how-to/s8-debloat-bloatware-thread-t3669009"
::# Note: This is copy and pasted into priv-app too because I'm unsure If they are in app or priv-app"

:: more notes and updates....credits 
::https://forum.xda-developers.com/t/tool-adb-appcontrol-1-7-ultimate-app-manager-debloat-tool-tweaks.4147837/
::https://forum.xda-developers.com/t/script-2021-01-30-v2-9-universal-android-debloater.4069209/
::https://gitlab.com/W1nst0n/universal-android-debloater/-/releases
::https://forum.xda-developers.com/t/debloat-scripts-overview-for-the-s21.4278727/
::https://forum.xda-developers.com/t/root-non-root-android-10-11-debloat-script-v1-0.4169015/

::pm uninstall removes everything
::pm uninstall -k removes the app, leaves the user data intact (to be used if the app is reinstalled)
::pm clear only removes the user data associated with the package, but not the package itself

::BetterBatteryStats 
::Greenify
::3C All-in-One Toolbox

::adb shell
::top

::You could try BBS or similar apps. Maybe it's an app which prevents the phone to go to deep doze (wakelocks).

cd "%~dp0platform-tools"

for %%x in (
REMOVE_IF_YOU_HAVE_YOUR_OWN_LAUNCHER_LIKE_NOVAcom.sec.android.app.launcher
android.auto_generated_rro__
android.auto_generated_rro_vendor
android.autoinstalls.config.samsung
android.autoinstalls.config.Xiaomi.cactus
android.autoinstalls.config.Xiaomi.cepheus
android.autoinstalls.config.Xiaomi.daisy
android.autoinstalls.config.Xiaomi.dipper
cci.usage
cn.oneplus.photos
cn.wps.xiaomi.abroad.lite
co.sitic.pp
com.aaa.android.discounts
com.aaa.android.discounts.vpl
com.aetherpal.attdh.se
com.aetherpal.attdh.zte
com.amazon.aa
com.amazon.aa.attribution
com.amazon.appmanager
com.amazon.avod.thirdpartyclient
com.amazon.clouddrive.photos
com.amazon.fv
com.amazon.kindle
com.amazon.mp3
com.amazon.mShop.android
com.amazon.mShop.android.shopping
com.amazon.venezia
com.android.apps.tag
com.android.backup
com.android.backupconfirm
com.android.bips
com.android.bluetooth
com.android.bluetoothmidiservice
com.android.bookmarkprovider
com.android.browser
com.android.browser.provider
com.android.calllogbackup
com.android.carrierconfig
com.android.carrierdefaultapp
com.android.cellbroadcastreceiver
com.android.certinstaller
com.android.chrome
com.android.companiondevicemanager
com.android.dreams.basic
com.android.dreams.phototable
com.android.dreams.phototable.overlay
com.android.dynsystem
com.android.egg
com.android.email
com.android.email.partnerprovider
com.android.email.partnerprovider.overlay
com.android.emergency
com.android.exchange
com.android.externalstorage
com.android.galaxy4
com.android.hotwordenrollment.okgoogle
com.android.hotwordenrollment.xgoogle
com.android.htmlviewer
com.android.hwmirror
com.android.inputdevices
com.android.keychain
com.android.keyguard
com.android.LGSetupWizard
com.android.localtransport
com.android.location.fused
com.android.magicsmoke
com.android.managedprovisioning
com.android.midrive
com.android.mms.service
com.android.mtp
com.android.musicvis
com.android.nfc
com.android.noisefield
com.android.ons
com.android.pacprocessor
com.android.partnerbrowsercustomizations.btl.s600ww.overlay
com.android.partnerbrowsercustomizations.chromeHomepage
com.android.phasebeam
com.android.phone
com.android.printspooler
com.android.providers.blockednumber
com.android.providers.calendar
com.android.providers.downloads
com.android.providers.downloads.ui
com.android.providers.media
com.android.providers.partnerbookmarks
com.android.providers.settings
com.android.providers.settings.overlay.base.s600ww
com.android.providers.telephony
com.android.providers.userdictionary
com.android.proxyhandler
com.android.quicksearchbox
com.android.runintest.ddrtest
com.android.se
com.android.server.telecom
com.android.settings
com.android.settings.intelligence
com.android.sharedstoragebackup
com.android.shell
com.android.simappdialog
com.android.soundrecorder
com.android.sprint.hiddenmenuapp
com.android.statementservice
com.android.stk
com.android.stk2
com.android.storagemanager
com.android.systemui
com.android.traceur
com.android.vpndialogs
com.android.wallpaper.holospiral
com.android.wallpaper.livepicker
com.android.wallpaper.livepicker.overlay
com.android.wallpaperbackup
com.android.wallpapercropper
com.apple.android.music
com.aspiro.tidal
com.asurion.android.mobilerecovery.att
com.asurion.android.mobilerecovery.sprint
com.asurion.android.mobilerecovery.sprint.vpl
com.asurion.android.protech.att
com.asurion.android.verizon.vms
com.asurion.home.sprint
com.asurion.home.sprint.vpl
com.asus.calculator
com.asus.easylauncher
com.asus.ia.asusapp
com.asus.soundrecorder
com.asus.userfeedback
com.att.android.attsmartwifi
com.att.callprotect
com.att.csoiam.mobilekey
com.att.dh
com.att.dtv.shaderemote
com.att.iqi
com.att.mobile.android.vvm
com.att.mobilesecurity
com.att.mobiletransfer
com.att.myWireless
com.att.personalcloud
com.att.tv
com.att.tv.watchtv
com.audible.application
com.aura.oobe.samsung
com.autonavi.minimap
com.baidu.duersdk.opensdk
com.baidu.input_huawei
com.baidu.input_mi
com.baidu.searchbox
com.bleacherreport.android.teamstream
com.blurb.checkout
com.booking
com.bsp.catchlog
com.caf.fmradio
com.cequint.ecid
com.chrome.beta
com.chrome.canary
com.chrome.dev
com.cnn.mobile.android.phone
com.cnn.mobile.android.phone.edgepanel
com.coloros.appmanager
com.coloros.backuprestore
com.coloros.cloud
com.coloros.findmyphone
com.coloros.gamespace
com.coloros.ocrscanner
com.coloros.soundrecorder
com.coloros.speechassist
com.coloros.wallet
com.coloros.weather.service
com.contextlogic.wish
com.cootek.smartinputv5.language.englishgb
com.cootek.smartinputv5.language.spanishus
com.crowdcare.agent.k
com.customermobile.preload.vzw
com.devhd.feedly
com.diotek.sec.lookup.dictionary
com.directv.dvrscheduler
com.discoveryscreen
com.disney.disneyplus
com.dna.solitaireapp
com.draftkings.dknativermgGP.vpl
com.dreamgames.royalmatch
com.drivemode
com.dsi.ant.plugins.antplus
com.dsi.ant.sample.acquirechannels
com.dsi.ant.server
com.dsi.ant.service.socket
com.duokan.phone.remotecontroller
com.duokan.phone.remotecontroller.peel.plugin
com.ebay.carrier
com.ebay.mobile
com.ehernandez.radiolainolvidable
com.emoji.keyboard.touchpal
com.enhance.gameservice
com.eterno
com.evenwell.AprUploadService.data.overlay.base
com.evenwell.AprUploadService.data.overlay.base.s600id
com.evenwell.AprUploadService.data.overlay.base.s600ww
com.evenwell.autoregistration.overlay.base
com.evenwell.autoregistration.overlay.base.s600id
com.evenwell.autoregistration.overlay.base.s600ww
com.evenwell.autoregistration.overlay.d.base.s600id
com.evenwell.autoregistration.overlay.d.base.s600ww
com.evenwell.batteryprotect
com.evenwell.batteryprotect.overlay.base
com.evenwell.batteryprotect.overlay.base.s600id
com.evenwell.batteryprotect.overlay.base.s600ww
com.evenwell.batteryprotect.overlay.d.base.s600e0
com.evenwell.bboxsbox.app
com.evenwell.bokeheditor.overlay.base.s600ww
com.evenwell.CPClient.overlay.base
com.evenwell.CPClient.overlay.base.s600id
com.evenwell.CPClient.overlay.base.s600ww
com.evenwell.custmanager.data.overlay.base
com.evenwell.custmanager.data.overlay.base.s600id
com.evenwell.custmanager.data.overlay.base.s600ww
com.evenwell.customerfeedback.overlay.base.s600ww
com.evenwell.dataagent.overlay.base
com.evenwell.dataagent.overlay.base.s600id
com.evenwell.dataagent.overlay.base.s600ww
com.evenwell.DbgCfgTool.overlay.base
com.evenwell.DbgCfgTool.overlay.base.s600id
com.evenwell.DbgCfgTool.overlay.base.s600ww
com.evenwell.DeviceMonitorControl.data.overlay.base
com.evenwell.DeviceMonitorControl.data.overlay.base.s600id
com.evenwell.DeviceMonitorControl.data.overlay.base.s600ww
com.evenwell.factorywizard
com.evenwell.factorywizard.overlay.base
com.evenwell.factorywizard.overlay.base.s600ww
com.evenwell.fqc
com.evenwell.legalterm
com.evenwell.legalterm.overlay.base.s600ww
com.evenwell.managedprovisioning.overlay.base
com.evenwell.managedprovisioning.overlay.base.s600id
com.evenwell.managedprovisioning.overlay.base.s600ww
com.evenwell.nps
com.evenwell.nps.overlay.base
com.evenwell.nps.overlay.base.s600id
com.evenwell.nps.overlay.base.s600ww
com.evenwell.pandorasbox.app
com.evenwell.partnerbrowsercustomizations
com.evenwell.partnerbrowsercustomizations.overlay.base
com.evenwell.partnerbrowsercustomizations.overlay.base.s600id
com.evenwell.partnerbrowsercustomizations.overlay.base.s600ww
com.evenwell.permissiondetection.overlay.base.s600ww
com.evenwell.phone.overlay.base
com.evenwell.phone.overlay.base.s600ww
com.evenwell.PowerMonitor
com.evenwell.PowerMonitor.overlay.base
com.evenwell.PowerMonitor.overlay.base.s600id
com.evenwell.PowerMonitor.overlay.base.s600ww
com.evenwell.providers.downloads.overlay.base.s600ww
com.evenwell.providers.downloads.ui.overlay.base.s600ww
com.evenwell.providers.weather
com.evenwell.providers.weather.overlay.base.s600ww
com.evenwell.pushagent
com.evenwell.pushagent.overlay.base
com.evenwell.pushagent.overlay.base.s600id
com.evenwell.pushagent.overlay.base.s600ww
com.evenwell.retaildemoapp
com.evenwell.retaildemoapp.overlay.base
com.evenwell.retaildemoapp.overlay.base.s600id
com.evenwell.retaildemoapp.overlay.base.s600ww
com.evenwell.settings.data.overlay.base.s600ww
com.evenwell.SettingsUtils
com.evenwell.SettingsUtils.overlay.base.s600ww
com.evenwell.SetupWizard
com.evenwell.setupwizard.btl.s600ww.overlay
com.evenwell.SetupWizard.overlay.base
com.evenwell.SetupWizard.overlay.base.s600ww
com.evenwell.SetupWizard.overlay.d.base.s600ww
com.evenwell.stbmonitor
com.evenwell.stbmonitor.data.overlay.base
com.evenwell.stbmonitor.data.overlay.base.s600id
com.evenwell.stbmonitor.data.overlay.base.s600ww
com.evenwell.telecom.data.overlay.base.s600id
com.evenwell.telecom.data.overlay.base.s600ww
com.evenwell.UsageStatsLogReceiver
com.evenwell.UsageStatsLogReceiver.data.overlay.back.s600id
com.evenwell.UsageStatsLogReceiver.data.overlay.base.s600ww
com.evenwell.weatherservice
com.evenwell.weatherservice.overlay.base.s600ww
com.evernote
com.example.android.notepad
com.example.wifirftest
com.facebook.appmanager
com.facebook.katana
com.facebook.orca
com.facebook.services
com.facebook.system
com.facemoji.lite.xiaomi.gp
com.factory.mmigroup
com.fih.StatsdLogger
com.fingerprints.fingerprintsensortest
com.fingerprints.sensortesttool
com.foxconn.ifaa
com.galaxyfirsatlari
com.gd.mobicore.pa
com.generalmobi.go2pay
com.google.android.apps.access.wifi.consumer
com.google.android.apps.adm
com.google.android.apps.ads.publisher
com.google.android.apps.adwords
com.google.android.apps.authenticator2
com.google.android.apps.blogger
com.google.android.apps.books
com.google.android.apps.chromecast.app
com.google.android.apps.cloudprint
com.google.android.apps.cultural
com.google.android.apps.currents
com.google.android.apps.docs
com.google.android.apps.docs.editors.docs
com.google.android.apps.docs.editors.sheets
com.google.android.apps.docs.editors.slides
com.google.android.apps.dynamite
com.google.android.apps.enterprise.cpanel
com.google.android.apps.enterprise.dmagent
com.google.android.apps.fireball
com.google.android.apps.fitness
com.google.android.apps.freighter
com.google.android.apps.giant
com.google.android.apps.googleassistant
com.google.android.apps.handwriting.ime
com.google.android.apps.hangoutsdialer
com.google.android.apps.inbox
com.google.android.apps.kids.familylink
com.google.android.apps.kids.familylinkhelper
com.google.android.apps.m4b
com.google.android.apps.magazines
com.google.android.apps.maps
com.google.android.apps.mapslite
com.google.android.apps.meetings
com.google.android.apps.messaging
com.google.android.apps.navlite
com.google.android.apps.nbu.files
com.google.android.apps.paidtasks
com.google.android.apps.pdfviewer
com.google.android.apps.photos
com.google.android.apps.photos.scanner
com.google.android.apps.plus
com.google.android.apps.podcasts
com.google.android.apps.recorder
com.google.android.apps.restore
com.google.android.apps.santatracker
com.google.android.apps.setupwizard.searchselector
com.google.android.apps.subscriptions.red
com.google.android.apps.tachyon
com.google.android.apps.tasks
com.google.android.apps.translate
com.google.android.apps.travel.onthego
com.google.android.apps.turbo
com.google.android.apps.uploader
com.google.android.apps.vega
com.google.android.apps.walletnfcrel
com.google.android.apps.wallpaper
com.google.android.apps.wellbeing
com.google.android.apps.youtube.creator
com.google.android.apps.youtube.gaming
com.google.android.apps.youtube.kids
com.google.android.apps.youtube.music
com.google.android.apps.youtube.vr
com.google.android.as
com.google.android.backuptransport
com.google.android.calculator
com.google.android.calendar
com.google.android.captiveportallogin
com.google.android.configupdater
com.google.android.documentsui
com.google.android.email
com.google.android.ext.shared
com.google.android.feedback
com.google.android.gm
com.google.android.gms.location.history
com.google.android.googlequicksearchbox
com.google.android.gsf
com.google.android.instantapps.supervisor
com.google.android.keep
com.google.android.markup
com.google.android.marvin.talkback
com.google.android.music
com.google.android.networkstack
com.google.android.networkstack.permissionconfig
com.google.android.networkstack.tethering.overlay
com.google.android.onetimeinitializer
com.google.android.packageinstaller
com.google.android.partnersetup
com.google.android.pixel.setupwizard
com.google.android.play.games
com.google.android.printservice.recommendation
com.google.android.projection.gearhead
com.google.android.setupwizard
com.google.android.setupwizard.a_overlay
com.google.android.soundpicker
com.google.android.street
com.google.android.syncadapters.bookmarks
com.google.android.syncadapters.calendar
com.google.android.syncadapters.contacts
com.google.android.tag
com.google.android.talk
com.google.android.tts
com.google.android.tv.remote
com.google.android.videoeditor
com.google.android.videos
com.google.android.voicesearch
com.google.android.vr.home
com.google.android.vr.inputmethod
com.google.android.wearable.app
com.google.android.youtube
com.google.ar.core
com.google.ar.lens
com.google.audio.hearing.visualization.accessibility.scribe
com.google.chromeremotedesktop
com.google.earth
com.google.mainline.telemetry
com.google.marvin.talkback
com.google.samples.apps.cardboarddemo
com.google.tango.measure
com.google.vr.cyclops
com.google.vr.expeditions
com.google.vr.vrcore
com.google.zxing.client.android
com.gotv.nflgamecenter.us.lite
com.groupon
com.hancom.office.editor.hidden
com.handmark.expressweather
com.handmark.expressweather.vpl
com.hicloud.android.clone
com.hiya.star
com.hmdglobal.datago
com.hmdglobal.datago.overlay.base
com.hmdglobal.support
com.huaqin.diaglogger
com.huaqin.factory
com.huaqin.FM
com.huawei.android.chr
com.huawei.android.FloatTasks
com.huawei.android.hwpay
com.huawei.android.instantshare
com.huawei.android.karaoke
com.huawei.android.mirrorshare
com.huawei.android.remotecontroller
com.huawei.android.tips
com.huawei.android.totemweather
com.huawei.android.totemweatherapp
com.huawei.android.totemweatherwidget
com.huawei.android.wfdft
com.huawei.android.wfdirect
com.huawei.appmarket
com.huawei.arengine.service
com.huawei.bd
com.huawei.bluetooth
com.huawei.browser
com.huawei.browserhomepage
com.huawei.compass
com.huawei.contactscamcard
com.huawei.email
com.huawei.fido.uafclient
com.huawei.gameassistant
com.huawei.geofence
com.huawei.health
com.huawei.hiassistantoversea
com.huawei.hicloud
com.huawei.hifolder
com.huawei.himovie.overseas
com.huawei.hitouch
com.huawei.hwasm
com.huawei.hwdetectrepair
com.huawei.hwid
com.huawei.hwsearch
com.huawei.hwstartupguide
com.huawei.hwvoipservice
com.huawei.iaware
com.huawei.ihealth
com.huawei.intelligent
com.huawei.livewallpaper.artflower
com.huawei.livewallpaper.flowersbloom
com.huawei.livewallpaper.mountaincloud
com.huawei.livewallpaper.naturalgarden
com.huawei.livewallpaper.paradise
com.huawei.livewallpaper.ripplestone
com.huawei.magazine
com.huawei.mirrorlink
com.huawei.music
com.huawei.parentcontrol
com.huawei.pcassistant
com.huawei.phoneservice
com.huawei.scanner
com.huawei.stylus.floatmenu
com.huawei.synergy
com.huawei.tips
com.huawei.vassistant
com.huawei.videoeditor
com.huawei.wallet
com.hulu.plus
com.hyperlync.Sprint.Backup
com.hyperlync.Sprint.CloudBinder
com.ideashower.readitlater.pro
com.iflytek.speechsuite
com.imdb.mobile
com.infraware.polarisoffice5
com.instagram.android
com.ironsource.appcloud.oobe
com.ironsource.appcloud.oobe.huawei
com.justride.stbbuch
com.king.candycrush4
com.king.candycrushsaga
com.king.candycrushsodasaga
com.knox.vpn.proxyhandler
com.lenovo.lsf.user
com.lge.appwidget.dualsimstatus
com.lge.bnr
com.lge.bnr.launcher
com.lge.cic.eden.service
com.lge.cloudhub
com.lge.drmservice
com.lge.easyhome
com.lge.eltest
com.lge.email
com.lge.eula
com.lge.eulaprovider
com.lge.floatingbar
com.lge.fmradio
com.lge.friendsmanager
com.lge.gallery.collagewallpaper
com.lge.gallery.vr.wallpaper
com.lge.gestureanswering
com.lge.gnss.airtest
com.lge.gnsslogcat
com.lge.gnsspostest
com.lge.gnsstest
com.lge.hiddenmenu
com.lge.hiddenpersomenu
com.lge.hifirecorder
com.lge.homeselector
com.lge.hotspotlauncher
com.lge.ia.task.smartsetting
com.lge.iftttmanager
com.lge.ime.solution.handwriting
com.lge.ime.solution.text
com.lge.laot
com.lge.launcher2.theme.optimus
com.lge.lgaccount
com.lge.lgdrm.permission
com.lge.lgfmservice
com.lge.lginstallservies
com.lge.lgsetupview
com.lge.LGSetupView
com.lge.lgworld
com.lge.lifetracker
com.lge.mirrorlink
com.lge.mlt
com.lge.music
com.lge.musicshare
com.lge.myplace
com.lge.myplace.engine
com.lge.operator.hiddenmenu
com.lge.phonemanagement
com.lge.privacylock
com.lge.qhelp
com.lge.qmemoplus
com.lge.remote.lgairdrive
com.lge.remote.setting
com.lge.servicemenu
com.lge.sizechangable.weather
com.lge.sizechangable.weather.platform
com.lge.sizechangable.weather.theme.optimus
com.lge.smartdoctor.webview
com.lge.smartshare
com.lge.smartshare.provider
com.lge.snappage
com.lge.springcleaning
com.lge.sync
com.lge.video.vr.wallpaper
com.lge.videoplayer
com.lge.videostudio
com.lge.voicecare
com.lge.vrplayer
com.lge.wernicke
com.lge.wernicke.nlp
com.lge.wfds.service.v3
com.lge.wifi.p2p
com.lge.wifihotspotwidget
com.linkedin.android
com.lmi.motorola.rescuesecurity
com.locationlabs.cni.att
com.locationlabs.finder.sprint
com.locationlabs.finder.sprint.vpl
com.LogiaGroup.LogiaDeck
com.lookout
com.mediatek.atmwifimeta
com.mediatek.engineermode
com.mediatek.mtklogger
com.mediatek.providers.drm
com.mediatek.wfo.impl
com.mfashiongallery.emag
com.mi.android.globalminusscreen
com.mi.android.globalpersonalassistant
com.mi.AutoTest
com.mi.global.bbs
com.mi.global.shop
com.mi.globalTrendNews
com.mi.health
com.mi.liveassistant
com.mi.setupwizardoverlay
com.mi.webkit.core
com.micredit.in
com.microsoft.appmanager
com.microsoft.office.excel
com.microsoft.office.officehub
com.microsoft.office.officehubhl
com.microsoft.office.officehubrow
com.microsoft.office.powerpoint
com.microsoft.office.word
com.microsoft.skydrive
com.microsoft.translator
com.milink.service
com.mipay.wallet
com.mipay.wallet.id
com.mipay.wallet.in
com.miui.accessibility
com.miui.analytics
com.miui.android.fashiongallery
com.miui.audioeffect
com.miui.bugreport
com.miui.cit
com.miui.cleanmaster
com.miui.cloudbackup
com.miui.cloudservice
com.miui.cloudservice.sysbase
com.miui.compass
com.miui.contentcatcher
com.miui.daemon
com.miui.enbbs
com.miui.fm
com.miui.fmservice
com.miui.gallery
com.miui.greenguard
com.miui.huanji
com.miui.hybrid
com.miui.hybrid.accessory
com.miui.klo.bugreport
com.miui.micloudsync
com.miui.miservice
com.miui.miwallpaper
com.miui.miwallpaper.earth
com.miui.miwallpaper.mars
com.miui.msa.global
com.miui.newmidrive
com.miui.notes
com.miui.personalassistant
com.miui.player
com.miui.providers.weather
com.miui.qr
com.miui.screenrecorder
com.miui.smsextra
com.miui.spock
com.miui.sysopt
com.miui.systemAdSolution
com.miui.touchassistant
com.miui.translation.kingsoft
com.miui.translation.xmcloud
com.miui.translation.youdao
com.miui.translationservice
com.miui.userguide
com.miui.video
com.miui.videoplayer
com.miui.videoplayer.overlay
com.miui.virtualsim
com.miui.vsimcore
com.miui.weather2
com.miui.yellowpage
com.mobeam.barcodeService
com.mobiletools.systemhelper
com.mobitv.client.sprinttvng
com.mobitv.client.tmobiletvhd
com.mobolize.sprint.securewifi
com.monotype.android.font.chococooky
com.monotype.android.font.cooljazz
com.monotype.android.font.foundation
com.monotype.android.font.rosemary
com.monotype.android.font.samsungone
com.motorola.actions
com.motorola.android.fmradio
com.motorola.android.jvtcmd
com.motorola.android.nativedropboxagent
com.motorola.android.provisioning
com.motorola.android.settings.diag_mdlog
com.motorola.attvowifi
com.motorola.bach.modemstats
com.motorola.brapps
com.motorola.bug2go
com.motorola.ccc.devicemanagement
com.motorola.ccc.mainplm
com.motorola.ccc.notification
com.motorola.contacts.preloadcontacts
com.motorola.demo
com.motorola.demo.env
com.motorola.easyprefix
com.motorola.email
com.motorola.faceunlock
com.motorola.faceunlocktrustagent
com.motorola.fmplayer
com.motorola.frameworks.singlehand
com.motorola.genie
com.motorola.gesture
com.motorola.help
com.motorola.lifetimedata
com.motorola.ltebroadcastservices_vzw
com.motorola.mot5gmod
com.motorola.moto
com.motorola.motocit
com.motorola.motodisplay
com.motorola.omadm.sprint
com.motorola.omadm.vzw
com.motorola.programmenu
com.motorola.ptt.prip
com.motorola.slpc_sys
com.motorola.timeweatherwidget
com.motorola.visualvoicemail
com.motorola.vzw.cloudsetup
com.motorola.vzw.loader
com.motorola.vzw.mot5gmod
com.motorola.vzw.pco.extensions.pcoreceiver
com.motorola.vzw.phone.extensions
com.motorola.vzw.provider
com.motricity.verizon.ssodownloadable
com.mygalaxy
com.nearme.browser
com.nearme.themestore
com.netflix.mediaclient
com.netflix.partner.activation
com.nextradioapp.nextradio
com.niksoftware.snapseed
com.nuance.swype.input
com.oem.autotest
com.oem.logkitsdservice
com.oem.nfc
com.oem.oemlogkit
com.oneplus.backuprestore
com.oneplus.brickmode
com.oneplus.bttestmode
com.oneplus.card
com.oneplus.factorymode
com.oneplus.factorymode.specialtest
com.oneplus.gamespace
com.oneplus.note
com.oneplus.opbugreportlite
com.oneplus.opsports
com.oneplus.soundrecorder
com.opera.app.news
com.opera.branding
com.opera.branding.news
com.opera.max.oem
com.opera.max.preinstall
com.opera.mini.native
com.opera.preinstall
com.oppo.fingerprints.fingerprintsensortest
com.oppo.market
com.oppo.music
com.oppo.quicksearchbox
com.orange.mail.fr
com.orange.miorange
com.orange.mylivebox.fr
com.orange.mysosh
com.orange.orangeetmoi
com.orange.owtv
com.orange.tdd
com.orange.update
com.orange.vvm
com.orange.wifiorange
com.osp.app.signin
com.particlenews.newsbreak
com.phonepe.app
com.pinsight.dw
com.pinsight.v1
com.plantronics.headsetservice
com.playphone.gamestore
com.playphone.gamestore.loot
com.policydm
com.pure.indosat.care
com.qiyi.video
com.qti.confuridialer
com.qualcomm.atfwd
com.qualcomm.embms
com.qualcomm.location
com.qualcomm.qti.auth.fidocryptoservice
com.qualcomm.qti.autoregistration
com.qualcomm.qti.dynamicddsservice
com.qualcomm.qti.lpa
com.qualcomm.qti.networksetting
com.qualcomm.qti.perfdump
com.qualcomm.qti.qmmi
com.qualcomm.qti.qms.service.telemetry
com.qualcomm.qti.rcsbootstraputil
com.qualcomm.qti.uceshimservice
com.qualcomm.qti.uim
com.quicinc.cne.CNEService
com.quicinc.fmradio
com.realme.findphone.client2
com.realvnc.android.remote
com.remotefairy4
com.republicwireless.tel
com.rhapsody
com.rhapsody.vpl
com.roaming.android.gsimcontentprovider
com.rsupport.rs.activity.lge.allinone
com.rsupport.rs.activity.rsupport.aas2
com.s.antivirus
com.samsung.aasaservice
com.samsung.accessibility
com.samsung.accessory
com.samsung.accessory.beansmgr
com.samsung.accessory.safiletransfer
com.samsung.advp.imssettings
com.samsung.android.accessibility.talkback
com.samsung.android.aircommandmanager
com.samsung.android.airtel.stubapp
com.samsung.android.allshare.service.fileshare
com.samsung.android.allshare.service.mediashare
com.samsung.android.app.accesscontrol
com.samsung.android.app.advsounddetector
com.samsung.android.app.aodservice
com.samsung.android.app.appsedge
com.samsung.android.app.assistantmenu
com.samsung.android.app.camera.sticker.facear.preload
com.samsung.android.app.camera.sticker.facear3d.preload
com.samsung.android.app.camera.sticker.facearavatar.preload
com.samsung.android.app.camera.sticker.facearframe.preload
com.samsung.android.app.camera.sticker.stamp.preload
com.samsung.android.app.clipboardedge
com.samsung.android.app.cocktailbarservice
com.samsung.android.app.color
com.samsung.android.app.contacts
com.samsung.android.app.dofviewer
com.samsung.android.app.dressroom
com.samsung.android.app.earphonetypec
com.samsung.android.app.episodes
com.samsung.android.app.filterinstaller
com.samsung.android.app.galaxyfinder
com.samsung.android.app.interactivepanoramaviewer
com.samsung.android.app.ledbackcover
com.samsung.android.app.ledcoverdream
com.samsung.android.app.memo
com.samsung.android.app.mhswrappertmo
com.samsung.android.app.mirrorlink
com.samsung.android.app.news
com.samsung.android.app.notes
com.samsung.android.app.notes.addons
com.samsung.android.app.omcagent
com.samsung.android.app.panel.naver.v
com.samsung.android.app.pinboard
com.samsung.android.app.readingglass
com.samsung.android.app.reminder
com.samsung.android.app.routines
com.samsung.android.app.sbrowseredge
com.samsung.android.app.settings.bixby
com.samsung.android.app.sharelive
com.samsung.android.app.simplesharing
com.samsung.android.app.smartcapture
com.samsung.android.app.social
com.samsung.android.app.soundpicker
com.samsung.android.app.spage
com.samsung.android.app.storyalbumwidget
com.samsung.android.app.talkback
com.samsung.android.app.taskedge
com.samsung.android.app.telephonyui
com.samsung.android.app.tips
com.samsung.android.app.vrsetupwizards
com.samsung.android.app.vrsetupwizardstub
com.samsung.android.app.watchmanager
com.samsung.android.app.watchmanagerstub
com.samsung.android.app.withtv
com.samsung.android.appseparation
com.samsung.android.ardrawing
com.samsung.android.aremoji
com.samsung.android.aremojieditor
com.samsung.android.arzone
com.samsung.android.asksmanager
com.samsung.android.authfw
com.samsung.android.aware.service
com.samsung.android.bbc.bbcagent
com.samsung.android.bbc.fileprovider
com.samsung.android.beaconmanager
com.samsung.android.biometrics.app.setting
com.samsung.android.bixby.agent
com.samsung.android.bixby.agent.dummy
com.samsung.android.bixby.es.globalaction
com.samsung.android.bixby.plmsync
com.samsung.android.bixby.service
com.samsung.android.bixby.voiceinput
com.samsung.android.bixby.wakeup
com.samsung.android.bixbyvision.framework
com.samsung.android.bluelightfilter
com.samsung.android.brightnessbackupservice
com.samsung.android.calendar
com.samsung.android.callbgprovider
com.samsung.android.camerasdkservice
com.samsung.android.cameraxservice
com.samsung.android.cidmanager
com.samsung.android.cmfa.framework
com.samsung.android.coldwalletservice
com.samsung.android.container
com.samsung.android.coreapps
com.samsung.android.da.daagent
com.samsung.android.dialer
com.samsung.android.digitalkey
com.samsung.android.dlp.service
com.samsung.android.dqagent
com.samsung.android.drivelink.stub
com.samsung.android.dsms
com.samsung.android.dynamiclock
com.samsung.android.easysetup
com.samsung.android.email.provider
com.samsung.android.emojiupdater
com.samsung.android.fast
com.samsung.android.fmm
com.samsung.android.forest
com.samsung.android.game.gamehome
com.samsung.android.game.gametools
com.samsung.android.game.gos
com.samsung.android.gametuner.thin
com.samsung.android.gearoplugin
com.samsung.android.hdmapp
com.samsung.android.hmt.vrshell
com.samsung.android.hmt.vrsvc
com.samsung.android.honeyboard
com.samsung.android.icecone
com.samsung.android.incall.contentprovider
com.samsung.android.incallui
com.samsung.android.intelligenceservice2
com.samsung.android.ipsgeofence
com.samsung.android.keyguardwallpaperupdator
com.samsung.android.kgclient
com.samsung.android.kidsinstaller
com.samsung.android.knox.analytics.uploader
com.samsung.android.knox.attestation
com.samsung.android.knox.containeragent
com.samsung.android.knox.containercore
com.samsung.android.knox.pushmanager
com.samsung.android.livestickers
com.samsung.android.localeoverlaymanager
com.samsung.android.location
com.samsung.android.lool
com.samsung.android.mapsagent
com.samsung.android.mateagent
com.samsung.android.mcfds
com.samsung.android.mcfserver
com.samsung.android.mdecservice
com.samsung.android.mdm
com.samsung.android.mdx
com.samsung.android.mdx.kit
com.samsung.android.mdx.quickboard
com.samsung.android.messaging
com.samsung.android.mfi
com.samsung.android.mobileservice
com.samsung.android.motionphoto.viewer
com.samsung.android.MtpApplication
com.samsung.android.net.wifi.wifiguider
com.samsung.android.networkdiagnostic
com.samsung.android.networkstack.tethering.overlay
com.samsung.android.oneconnect
com.samsung.android.personalpage.service
com.samsung.android.privateshare
com.samsung.android.provider.filterprovider
com.samsung.android.providers.carrier
com.samsung.android.providers.contacts
com.samsung.android.providers.context
com.samsung.android.providers.media
com.samsung.android.rubin.app
com.samsung.android.samsungpass
com.samsung.android.samsungpassautofill
com.samsung.android.samsungpositioning
com.samsung.android.scloud
com.samsung.android.sconnect
com.samsung.android.scs
com.samsung.android.sdk.handwriting
com.samsung.android.sdk.professionalaudio.utility.jammonitor
com.samsung.android.sdm.config
com.samsung.android.secsoundpicker
com.samsung.android.securitylogagent
com.samsung.android.server.iris
com.samsung.android.server.wifi.mobilewips
com.samsung.android.service.airviewdictionary
com.samsung.android.service.livedrawing
com.samsung.android.service.pentastic
com.samsung.android.service.peoplestripe
com.samsung.android.service.stplatform
com.samsung.android.service.tagservice
com.samsung.android.service.travel
com.samsung.android.setting.multisound
com.samsung.android.SettingsReceiver
com.samsung.android.shortcutbackupservice
com.samsung.android.singletake.service
com.samsung.android.six.webtrans
com.samsung.android.slinkcloud
com.samsung.android.sm
com.samsung.android.sm.devicesecurity
com.samsung.android.sm.policy
com.samsung.android.smartcallprovider
com.samsung.android.smartface
com.samsung.android.smartfitting
com.samsung.android.smartmirroring
com.samsung.android.smartsuggestions
com.samsung.android.smartswitchassistant
com.samsung.android.spay
com.samsung.android.spayfw
com.samsung.android.spaymini
com.samsung.android.spdfnote
com.samsung.android.stickercenter
com.samsung.android.stickerplugin
com.samsung.android.ststub
com.samsung.android.sume.nn.service
com.samsung.android.svcagent
com.samsung.android.svoice
com.samsung.android.svoiceime
com.samsung.android.tadownloader
com.samsung.android.tapack.authfw
com.samsung.android.themecenter
com.samsung.android.themestore
com.samsung.android.tripwidget
com.samsung.android.uds
com.samsung.android.universalswitch
com.samsung.android.video
com.samsung.android.visionarapps
com.samsung.android.visioncloudagent
com.samsung.android.visionintelligence
com.samsung.android.voc
com.samsung.android.voicewakeup
com.samsung.android.vtcamerasettings
com.samsung.android.wallpaper.res
com.samsung.android.weather
com.samsung.android.wellbeing
com.samsung.android.widgetapp.yahooedge.finance
com.samsung.android.widgetapp.yahooedge.sport
com.samsung.android.wifi.resources
com.samsung.android.wifi.softap.resources
com.samsung.android.wifi.softapwpathree.resources
com.samsung.app.highlightplayer
com.samsung.app.jansky
com.samsung.app.newtrim
com.samsung.attvvm
com.samsung.clipboardsaveservice
com.samsung.cmh
com.samsung.crane
com.samsung.daydream.customization
com.samsung.dcmservice
com.samsung.desktopsystemui
com.samsung.ecomm
com.samsung.enhanceservice
com.samsung.euicc
com.samsung.faceservice
com.samsung.fresco.logging
com.samsung.gamedriver.ex2100
com.samsung.gpuwatchapp
com.samsung.groupcast
com.samsung.helphub
com.samsung.hiddennetworksetting
com.samsung.hs20provider
com.samsung.ims.smk
com.samsung.ipservice
com.samsung.klmsagent
com.samsung.knox.appsupdateagent
com.samsung.knox.keychain
com.samsung.knox.knoxtrustagent
com.samsung.knox.rcp.components
com.samsung.knox.securefolder
com.samsung.knox.securefolder.setuppage
com.samsung.logwriter
com.samsung.mdl.radio
com.samsung.mdl.radio.radiostub
com.samsung.mlp
com.samsung.oh
com.samsung.pregpudriver.ex2100
com.samsung.rcs
com.samsung.safetyinformation
com.samsung.sec.android.application.csc
com.samsung.sec.android.teegris.tui_service
com.samsung.slsi.audiologging
com.samsung.SMT
com.samsung.sree
com.samsung.storyservice
com.samsung.svoice.sync
com.samsung.systemui.bixby
com.samsung.systemui.bixby2
com.samsung.tmovvm
com.samsung.ucs.agent.boot
com.samsung.ucs.agent.ese
com.samsung.visionprovider
com.samsung.voiceserviceplatform
com.samsung.vvm
com.samsung.vvm.se
com.samsung.vzwapiservice
com.sec.allsharecastplayer
com.sec.android.app.apex
com.sec.android.app.applinker
com.sec.android.app.billing
com.sec.android.app.bluetoothtest
com.sec.android.app.camera
com.sec.android.app.chromecustomizations
com.sec.android.app.clockpackage
com.sec.android.app.DataCreate
com.sec.android.app.desktoplauncher
com.sec.android.app.dexonpc
com.sec.android.app.dictionary
com.sec.android.app.easysetup
com.sec.android.app.ewidgetatt
com.sec.android.app.factorykeystring
com.sec.android.app.gamehub
com.sec.android.app.hwmoduletest
com.sec.android.app.kidshome
com.sec.android.app.magnifier
com.sec.android.app.mt
com.sec.android.app.myfiles
com.sec.android.app.ocr
com.sec.android.app.ocrcom.google.android.setupwizard
com.sec.android.app.parser
com.sec.android.app.personalization
com.sec.android.app.popupcalculator
com.sec.android.app.quicktool
com.sec.android.app.ringtoneBR
com.sec.android.app.safetyassurance
com.sec.android.app.samsungapps
com.sec.android.app.sbrowser
com.sec.android.app.SecSetupWizard
com.sec.android.app.servicemodeapp
com.sec.android.app.setupwizard
com.sec.android.app.setupwizardlegalprovider
com.sec.android.app.shealth
com.sec.android.app.SmartClipEdgeService
com.sec.android.app.sns3
com.sec.android.app.soundalive
com.sec.android.app.suwscriptplayer
com.sec.android.app.sysscope
com.sec.android.app.tfunlock
com.sec.android.app.tourviewer
com.sec.android.app.translator
com.sec.android.app.ve.vebgm
com.sec.android.app.vepreload
com.sec.android.app.voicenote
com.sec.android.app.volumemonitorprovider
com.sec.android.app.wfdbroker
com.sec.android.app.withtv
com.sec.android.app.wlantest
com.sec.android.autodoodle.service
com.sec.android.AutoPreconfig
com.sec.android.cover.ledcover
com.sec.android.daemonapp
com.sec.android.desktopmode.uiservice
com.sec.android.diagmonagent
com.sec.android.easyMover
com.sec.android.easyMover.Agent
com.sec.android.easyonehand
com.sec.android.emergencylauncher
com.sec.android.emergencymode.service
com.sec.android.fido.uaf.asm
com.sec.android.fido.uaf.client
com.sec.android.gallery3d
com.sec.android.game.gamehome
com.sec.android.inputmethod
com.sec.android.mimage.avatarstickers
com.sec.android.mimage.gear360editor
com.sec.android.mimage.photoretouching
com.sec.android.ofviewer
com.sec.android.omc
com.sec.android.Preconfig
com.sec.android.preloadinstaller
com.sec.android.provider.badge
com.sec.android.provider.emergencymode
com.sec.android.provider.snote
com.sec.android.providers.security
com.sec.android.providers.tasks
com.sec.android.RilServiceModeApp
com.sec.android.sdhms
com.sec.android.service.health
com.sec.android.sidesync30
com.sec.android.smartfpsadjuster
com.sec.android.soagent
com.sec.android.splitsound
com.sec.android.systemupdate
com.sec.android.uibcvirtualsoftkey
com.sec.android.usermanual
com.sec.android.widgetapp.diotek.smemo
com.sec.android.widgetapp.easymodecontactswidget
com.sec.android.widgetapp.samsungapps
com.sec.android.widgetapp.webmanual
com.sec.app.RilErrorNotifier
com.sec.app.TransmitPowerService
com.sec.automation
com.sec.bcservice
com.sec.downloadablekeystore
com.sec.enterprise.knox.attestation
com.sec.enterprise.knox.cloudmdm.smdms
com.sec.enterprise.knox.shareddevice.keyguard
com.sec.enterprise.mdm.services.simpin
com.sec.enterprise.mdm.vpn
com.sec.epdg
com.sec.epdgtestapp
com.sec.everglades
com.sec.everglades.update
com.sec.factory
com.sec.factory.camera
com.sec.factory.cameralyzer
com.sec.factory.iris.usercamera
com.sec.hearingadjust
com.sec.hiddenmenu
com.sec.ims
com.sec.imslogger
com.sec.imsservice
com.sec.kidsplat.installer
com.sec.knox.bluetooth
com.sec.knox.bridge
com.sec.knox.containeragent2
com.sec.knox.foldercontainer
com.sec.knox.knoxsetupwizardclient
com.sec.knox.packageverifier
com.sec.knox.shortcutsms
com.sec.knox.switcher
com.sec.knox.switchknoxI
com.sec.knox.switchknoxII
com.sec.location.nfwlocationprivacy
com.sec.location.nsflp2
com.sec.mhs.smarttethering
com.sec.mldapchecker
com.sec.modem.settings
com.sec.phone
com.sec.providers.assisteddialing
com.sec.readershub
com.sec.smartcard.manager
com.sec.spen.flashannotate
com.sec.spp.push
com.sec.sve
com.sec.unifiedwfc
com.sec.usbsettings
com.sec.vowifispg
com.sec.vsim.ericssonnsds.webapp
com.sec.yosemite.phone
com.securityandprivacy.android.verizon.vms
com.sem.factoryapp
com.servicemagic.consumer
com.setk.widget
com.sfr.android.moncompte
com.sfr.android.sfrcloud
com.sfr.android.sfrmail
com.sfr.android.sfrplay
com.sfr.android.vvm
com.sharecare.askmd
com.shopee.id
com.singtel.mysingtel
com.skms.android.agent
com.skype.m2
com.skype.raider
com.slacker.radio
com.smithmicro.netwise.director.comcast.oem
com.sohu.inputmethod.sogou.xiaomi
com.sony.tvsideview.videoph
com.sonyericsson.android.omacp
com.sonyericsson.conversations.res.overlay
com.sonyericsson.idd.agent
com.sonyericsson.mtp.extension.backuprestore
com.sonyericsson.mtp.extension.update
com.sonyericsson.music
com.sonyericsson.textinput.chinese
com.sonyericsson.trackid.res.overlay
com.sonyericsson.trackid.res.overlay_305
com.sonyericsson.unsupportedheadsetnotifier
com.sonyericsson.wappush
com.sonyericsson.warrantytime
com.sonyericsson.xhs
com.sonymobile.advancedlogging
com.sonymobile.advancedwidget.topcontacts
com.sonymobile.android.addoncamera.soundphoto
com.sonymobile.android.contacts.res.overlay_305
com.sonymobile.android.externalkeyboard
com.sonymobile.android.externalkeyboardjp
com.sonymobile.androidapp.cameraaddon.areffect
com.sonymobile.anondata
com.sonymobile.aptx.notifier
com.sonymobile.assist
com.sonymobile.cameracommon.wearablebridge
com.sonymobile.cellbroadcast.notification
com.sonymobile.coverapp2
com.sonymobile.demoappchecker
com.sonymobile.dualshockmanager
com.sonymobile.email
com.sonymobile.entrance
com.sonymobile.getmore.client
com.sonymobile.getset
com.sonymobile.getset.priv
com.sonymobile.gettoknowit
com.sonymobile.glovemode
com.sonymobile.googleanalyticsproxy
com.sonymobile.indeviceintelligence
com.sonymobile.intelligent.backlight
com.sonymobile.intelligent.gesture
com.sonymobile.lifelog
com.sonymobile.moviecreator.rmm
com.sonymobile.music.googlelyricsplugin
com.sonymobile.music.wikipediaplugin
com.sonymobile.music.youtubekaraokeplugin
com.sonymobile.music.youtubeplugin
com.sonymobile.pobox
com.sonymobile.retaildemo
com.sonymobile.scan3d
com.sonymobile.smartcharger
com.sonymobile.support
com.sonymobile.themes.sou.cid18.black
com.sonymobile.themes.sou.cid19.silver
com.sonymobile.themes.sou.cid20.blue
com.sonymobile.themes.sou.cid21.pink
com.sonymobile.themes.xperialoops2
com.sonymobile.xperialounge.services
com.sonymobile.xperiatransfermobile
com.sonymobile.xperiaweather
com.sonymobile.xperiaxlivewallpaper
com.sonymobile.xperiaxlivewallpaper.product.res.overlay
com.spotify.music
com.sprint.android.musicplus2033
com.sprint.care
com.sprint.ce.updater
com.sprint.ecid
com.sprint.fng
com.sprint.international.message
com.sprint.ms.cdm
com.sprint.psdg.sw
com.sprint.safefound
com.sprint.w.installer
com.sprint.w.v8
com.squareup.cash
com.stitcher.app
com.swiftkey.swiftkeyconfigurator
com.synchronoss.dcs.att.r2g
com.telecomsys.directedsms.android.SCG
com.telenav.app.android.cingular
com.telenav.app.android.scout_us
com.tencent.soter.soterserver
com.test.LTEfunctionality
com.til.timesnews
com.tmobile.pr.adapt
com.tmobile.pr.mytmobile
com.tmobile.services.nameid
com.tmobile.simlock
com.tmobile.vvm.application
com.touchtype.swiftkey
com.tracker.t
com.tripadvisor.tripadvisor
com.tripledot.solitaire
com.tripledot.woodoku  
com.trustonic.tuiservice
com.turner.cnvideoapp
com.ubercab
com.ubercab.driver
com.ubercab.eats
com.UCMobile.intl
com.ume.browser.northamerica
com.vcast.mediamanager
com.verizon.familybase.parent
com.verizon.llkagent
com.verizon.messaging.vzmsgs
com.verizon.mips.services
com.verizon.obdm_permissions
com.verizon.onetalk.dialer
com.verizon.permissions.vzwappapn
com.verizontelematics.verizonhum
com.vlingo.midas
com.vznavigator.Generic
com.vzw.apnlib
com.vzw.apnservice
com.vzw.ecid
com.vzw.hss.myverizon
com.vzw.hss.widgets.infozone.large
com.vzw.qualitydatalog
com.wapi.wapicertmanage
com.wapi.wapicertmanager
com.wavemarket.waplauncher
com.wb.goog.got.conquest
com.whatsapp
com.whitepages.nameid.tmobile
com.wsomacp
com.wssnps
com.wssyncmldmcom.telecomsys.directedsms.android.SCG
com.wt.secret_code_manager
com.xiaomi.ab
com.xiaomi.account
com.xiaomi.channel
com.xiaomi.gamecenter.sdk.service
com.xiaomi.glgm
com.xiaomi.joyose
com.xiaomi.jr
com.xiaomi.lens
com.xiaomi.mi_connect_service
com.xiaomi.micloud.sdk
com.xiaomi.midrop
com.xiaomi.midrop.overlay
com.xiaomi.mipicks
com.xiaomi.mirecycle
com.xiaomi.o2o
com.xiaomi.oversea.ecom
com.xiaomi.pass
com.xiaomi.payment
com.xiaomi.providers.appindex
com.xiaomi.scanner
com.xiaomi.shop
com.xiaomi.simactivate.service
com.xiaomi.smarthome
com.xiaomi.upnp
com.xiaomi.vipaccount
com.xiaomi.xmsfkeeper
com.yahoo.mobile.client.android.finance
com.yahoo.mobile.client.android.liveweather
com.yahoo.mobile.client.android.sportacular
com.yahoo.mobile.client.android.yahoo
com.yellowpages.android.ypmobile
com.yelp.android
com.yelp.android.samsungedge
com.zhiliaoapp.musically
com.zte.assistant
com.zte.weather
com.zynga.gotslots
comflipboard.app
comflipboard.boxer.app
comtv.peel.samsung.app
de.axelspringer.yana.zeropage
de.telekom.tsc
flipboard.app
flipboard.boxer.app
fr.bouyguestelecom.ecm.android
fr.bouyguestelecom.tv.android
fr.bouyguestelecom.vvmandroid
fr.orange.cineday
id.co.babe
in.amazon.mShop.android.shopping
in.mohalla.sharechat
in.playsimple.wordtrip
jp.co.omronsoft.openwnn
jp.gocro.smartnews.android
msgplus.jibe.sca.vpl
net.aetherpal.device
net.oneplus.commonlogtool
net.oneplus.forums
net.oneplus.odm
net.oneplus.odm.provider
net.oneplus.push
net.oneplus.weather
net.oneplus.widget
net.sharewire.parkmobilev2
org.codeaurora.gps.gpslogsave
org.simalliance.openmobileapi.service
pl.zdunex25.updater
tv.fubo.mobile.vpl
tv.peel.app
tv.peel.samsung.app
tv.pluto.android
us.com.dt.iq.appsource.tmobile
       ) do (
		echo Trying to Uninstall:		%%x
		"%~dp0platform-tools\adb.exe" shell "pm uninstall -k --user 0 %%x"
		echo Trying to Disable:		%%x
		"%~dp0platform-tools\adb.exe" shell "pm disable --user 0 %%x" 2> null
       )

EXIT /B %ERRORLEVEL%

:END
echo [+] %date% %time% INFO: All done
pause
exit
