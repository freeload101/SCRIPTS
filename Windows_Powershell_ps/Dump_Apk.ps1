$Env:PATH = "$Env:PATH;$Env:TEMP\platform-tools"
adb shell pm list packages > apklist.txt
Start-Sleep -s 5
$apks = ((Get-Content .\apklist.txt)) -replace 'package:',''
 ForEach ($apk in $apks) {
    echo "APK is $apk"
    md $apk
    # If in secondary profile, add "--user 15" after path, before $file
    adb shell pm path $apk
    #Start-Sleep -s 1
    $filepath = ((adb shell pm path $apk | % {$_.replace("package:","")}))
    ForEach ($lapk in $filepath | % {$_.replace("package:","")}) {
        echo "pulling $lapk $apk"
        adb pull $lapk $apk
        #Start-Sleep -s 1
    }
 }
