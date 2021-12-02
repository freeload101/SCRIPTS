
# Disclamer

Personaly I found a few apps and sites just straight up ignore or don't support "high contrast" settings. ( not a deal breaker with the F12 switch ) Example regexr.com and Splunk fail to show selected text at all and Microsoft Teams has a "Dark Mode" or "High Contrast" mode but it does not follow your high contrast theme...

![image](https://user-images.githubusercontent.com/4307863/140933612-314f920d-801f-4975-a3bb-50eec14dda5a.png)


# Usage

## Apply .theme file for windows to enable High Contast (Easy Method)
https://github.com/freeload101/SCRIPTS/blob/master/AutoHotkey/HC4.theme

## Easily switch between high contrast (F12) use the authotkey .ahk script or download this exe
https://github.com/freeload101/SCRIPTS/blob/master/AutoHotkey/High_Contrast_Toggle_AutoHotkey.exe


## To enable High Contrast feature for Chrome and Chromium Edge on Windows 10

1. Ensure both browsers are using the latest Canary version, type about:flags in your browser

2. Search for “forced” and for highlighted “Forced Colors “flags, which provides a description of turns on “forced colors mode for web content”, select “Enabled”

![image](https://user-images.githubusercontent.com/4307863/143725262-d64ca45d-c323-45e0-8898-25a67ba5d08c.png)


3. Restart the browser

4.  Now with Chrome Canary and Edge Canary open on Windows 10, (note: Windows  8 and Windows 7 also has the feature built-in), click on Start > Settings

5. Ease of Access > High contrast, under  “Use high contrast”, toggle button to “Turn on high contrast”

![image](https://user-images.githubusercontent.com/4307863/143725265-6be95c9d-5475-450d-afc3-43d39e815ef1.png)

Wait for Windows 10 to apply the changes, visit a website to notice High contrast mode which inverts the page colors, working. The feature is useful for vision-impaired users.

Note: Caret Browsing is still not available in-development versions of Chrome.

Filed Under: Google Chrome, Microsoft Edge, News
Tagged With: Chromium, Microsoft


--------------
# Set get high contrast mode ForcedColors in Chrome command line 

--flag-switches-begin --enable-features=ForcedColors --flag-switches-end 



# High Contrast Seetup ( if you don't use the .theme file or want to setup your own )

- Turn high contrast on
- Tweek your settings so there is no "black" it will help with websites that don't follow High Contrast mode
![image](https://user-images.githubusercontent.com/4307863/143724714-23b1f69c-b0e0-416e-bc93-ca7f3ce1913b.png)

 - Make sure to change all 'black' to different shades of grey
 - use this script for some sites/apps that don't follow with high
  
   



## Not needed: 

    @echo off
    cd "%~dp0"
    reg query    "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes" -v "CurrentTheme" 
    copy /y "./HC4.theme" "%USERPROFILE%\AppData\Local\Microsoft\Windows\Themes\HC4.theme"
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes" /v "CurrentTheme" /d "%USERPROFILE%\AppData\Local\Microsoft\Windows\Themes\HC4.theme" /f  
    start "THEME" "%USERPROFILE%\AppData\Local\Microsoft\Windows\Themes\HC4.theme"
    pause



