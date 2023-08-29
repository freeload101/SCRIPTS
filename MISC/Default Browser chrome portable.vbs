'Registers Google Chrome Portable with Default Programs or Default Apps in Windows
'chromeportable.vbs - created on May 20, 2019 by Ramesh Srinivasan, Winhelponline.com
'v1.1 13-June-2019 - Enclosed file name parameter in double-quotes.
'v1.2 10-Sept-2020 - Fixed ApplicationIcon path. And added other supported URL protocols.
'v1.3 23-July-2022 - Minor bug fixes.

Option Explicit
Dim sAction, sAppPath, sExecPath, objFile, oFSO, sbaseKey, sbaseKey2, ArrKeys, regkey
Dim WshShell : Set WshShell = CreateObject("WScript.Shell") 
Dim oFS0 : Set oFSO = CreateObject("Scripting.FileSystemObject")

Set objFile = oFSO.GetFile(WScript.ScriptFullName)
sAppPath = oFSO.GetParentFolderName(objFile)
sExecPath = sAppPath & "\GoogleChromePortable.exe"

'Quit if GoogleChromePortable.exe is missing in the current folder!
If Not oFSO.FileExists (sExecPath) Then
   MsgBox "Please run this script from Chrome Portable folder. The script will now quit.", _
   vbOKOnly + vbInformation, "Register Google Chrome Portable with Default Apps"
   WScript.Quit
End If

If InStr(sExecPath, " ") > 0 Then sExecPath = """" & sExecPath & """"
sbaseKey = "HKCU\Software\"

If WScript.Arguments.Count > 0 Then
   If UCase(Trim(WScript.Arguments(0))) = "-REG" Then Call RegisterChromePortable
   If UCase(Trim(WScript.Arguments(0))) = "-UNREG" Then Call UnregisterChromePortable
Else
   sAction = InputBox("Type REGISTER to add Chrome Portable to Default Apps." & _
   "Type UNREGISTER To remove.", "Chrome Portable Registration", "REGISTER")
   If UCase(Trim(sAction)) = "REGISTER" Then Call RegisterChromePortable
   If UCase(Trim(sAction)) = "UNREGISTER" Then Call UnregisterChromePortable
End If


Sub RegisterChromePortable
   sbaseKey2 = sbaseKey & "Clients\StartmenuInternet\Google Chrome Portable\"
   
   WshShell.RegWrite sbaseKey & "RegisteredApplications\Google Chrome Portable", _
   "Software\Clients\StartMenuInternet\Google Chrome Portable\Capabilities", "REG_SZ"
   WshShell.RegWrite sbaseKey & "Classes\ChromeHTML2\", "Chrome HTML Document", "REG_SZ"
   WshShell.RegWrite sbaseKey & "Classes\ChromeHTML2\AppUserModelId", "Chrome Portable", "REG_SZ"
   WshShell.RegWrite sbaseKey & "Classes\ChromeHTML2\Application\AppUserModelId", "Chrome Portable", "REG_SZ"
   WshShell.RegWrite sbaseKey & "Classes\ChromeHTML2\Application\ApplicationIcon", sExecPath & ",0", "REG_SZ"
   WshShell.RegWrite sbaseKey & "Classes\ChromeHTML2\Application\ApplicationName", "Google Chrome Portable", "REG_SZ"
   WshShell.RegWrite sbaseKey & "Classes\ChromeHTML2\Application\ApplicationDescription", "Access the internet", "REG_SZ"
   WshShell.RegWrite sbaseKey & "Classes\ChromeHTML2\Application\ApplicationCompany", "Google Inc.", "REG_SZ"
   WshShell.RegWrite sbaseKey & "Classes\ChromeHTML2\DefaultIcon\", sExecPath & ",0", "REG_SZ"
   WshShell.RegWrite sbaseKey & "Classes\ChromeHTML2\shell\open\command\", sExecPath & " -- " & """" & "%1" & """", "REG_SZ"
   
   WshShell.RegWrite sbaseKey2, "Google Chrome Portable Edition", "REG_SZ"
   WshShell.RegWrite sbaseKey2 & "Capabilities\ApplicationDescription", "Google Chrome Portable Edition", "REG_SZ"
   WshShell.RegWrite sbaseKey2 & "Capabilities\ApplicationIcon", sExecPath & ",0", "REG_SZ"
   WshShell.RegWrite sbaseKey2 & "Capabilities\ApplicationName", "Google Chrome Portable Edition", "REG_SZ"   
   
   
   ArrKeys = Array ("FileAssociations\.htm", _
   "FileAssociations\.html", _
   "FileAssociations\.shtml", _
   "FileAssociations\.xht", _
   "FileAssociations\.xhtml", _
   "FileAssociations\.webp", _
   "URLAssociations\ftp", _
   "URLAssociations\http", _
   "URLAssociations\https", _
   "URLAssociations\irc", _
   "URLAssociations\mailto", _
   "URLAssociations\mms", _
   "URLAssociations\news", _
   "URLAssociations\nntp", _
   "URLAssociations\sms", _
   "URLAssociations\smsto", _
   "URLAssociations\tel", _
   "URLAssociations\url", _
   "URLAssociations\webcal")
   
   For Each regkey In ArrKeys
      WshShell.RegWrite sbaseKey2 & "Capabilities\" & regkey, "ChromeHTML2", "REG_SZ"
   Next
   
   WshShell.RegWrite sbaseKey2 & "DefaultIcon\", sExecPath & ",0", "REG_SZ"
   WshShell.RegWrite sbaseKey2 & "shell\open\command\", sExecPath, "REG_SZ"
   
   'Launch Default Apps after registering Chrome Portable   
   WshShell.Run "control /name Microsoft.DefaultPrograms /page pageDefaultProgram"  
End Sub


Sub UnregisterChromePortable
   
   sbaseKey2 = "HKCU\Software\Clients\StartmenuInternet\Google Chrome Portable"
   
   On Error Resume Next
   WshShell.RegDelete sbaseKey & "RegisteredApplications\Google Chrome Portable"
   On Error GoTo 0
   
   WshShell.Run "reg.exe delete " & sbaseKey & "Classes\ChromeHTML2" & " /f", 0
   WshShell.Run "reg.exe delete " & chr(34) & sbaseKey2 & chr(34) & " /f", 0
   
   'Launch Default Apps after unregistering Chrome Portable   
   WshShell.Run "control /name Microsoft.DefaultPrograms /page pageDefaultProgram"   
End Sub
