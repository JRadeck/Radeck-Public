#Require ServiceUI.exe in the script folder
#You will find it on a box that have Microsoft Deployment Toolkit (MDT) installed (C:\Program Files\Microsoft Deployment Toolkit\Templates\Distribution\Tools\x64\ServiceUI.exe)
#Add a "Run Command Line" step in Task Sequence with folowing commandline "ServiceUI.exe -process:TSProgressUI.exe "%WINDIR%\System32\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -NoLogo -File .\TSDebug.ps1""
#Don't forget to add the package with the scipt and ServiceUI.exe in

$Null = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") 
$TSDebug = [Microsoft.VisualBasic.Interaction]::MsgBox("Continue?`n`nYes will Continue`nNo will fail the TS with Exitcode 1`nCancel will open a cmd prompt and then continue", "YesNoCancel,SystemModal,Information,MsgBoxSetForeground", "Debug Task Sequence")
If ($TSDebug -eq 'Ok') {
    Write-Host "TS Continues"
}
ElseIf ($TSDebug -eq 'Cancel') {
    Write-Host "TS Abort lunching CMD"

    If (Get-Item -Path 'X:\sms\bin\x64\CMTrace.exe' -ErrorAction SilentlyContinue) {
        Start-Process -FilePath "$PSScriptRoot\ServiceUI.exe" -ArgumentList "-process:TSProgressUI.exe X:\sms\bin\x64\CMTrace.exe X:\Windows\temp\SMSTSLog\smsts.log" -WindowStyle Hidden
    }
    If (Get-Item -Path 'C:\Windows\CCM\CMTrace.exe' -ErrorAction SilentlyContinue) {
        Start-Process -FilePath "$PSScriptRoot\ServiceUI.exe" -ArgumentList "-process:TSProgressUI.exe C:\Windows\CCM\CMTrace.exe C:\Windows\CCM\Logs\SMSTSLog\smsts.log" -WindowStyle Hidden
    }

    Start-Process -FilePath "$PSScriptRoot\ServiceUI.exe" -ArgumentList "-process:TSProgressUI.exe $env:windir\System32\cmd.exe" -Wait -WindowStyle Hidden
}
ElseIf ($TSDebug -eq 'No') {
    Write-Host "Will Fail TS"
    Exit 1
}