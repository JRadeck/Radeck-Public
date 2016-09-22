<#
.Synopsis
   Check for application and the uninstall it
.DESCRIPTION
   List uninstall registry keys and search for specific application and then uninstall it
   Script name: Uninstall-MSI.ps1
   Created: 2016-09-22
   Version: 1.0
.EXAMPLE
   Uninstall-MSI.ps1

   Edit script to right application to uninstall
   $ApplicationToRemove = 'Java'

.NOTES

   Author:
       Johnny Radeck
       Twitter: @Johnny_Radeck
       Blog   : http://radeck.se

   Disclaimer:
       This script is provided "AS IS" with no warranties, confers no rights and 
       is not supported by the author.
#>
#Setup Logging
$Date = Get-Date -DisplayHint Date -Format 'yyyy-MM-dd'
$Model = (Get-WmiObject -Class Win32_ComputerSystem).Model
$Name = (Get-WmiObject -Class Win32_ComputerSystem).Name
$logdir = "$env:Programdata\ApplicationsLogs"

    if (test-path $logdir){
        Write-Verbose –Message 'Folder found' –Verbose
    }
    Else {
        Write-Verbose –Message 'No folder found. Creating it' –Verbose
        new-item -type directory $logdir -Verbose
    }

$logFile = "$logdir\$($myInvocation.MyCommand).log"
Start-Transcript -Append $logFile –Verbose
Write-Verbose –Message "$Date Start Logging to $logFile" –Verbose
Write-Verbose –Message "Model: $model" –Verbose
Write-Verbose –Message "Computername: $Name" –Verbose


# List installed applications
$ProductIDList = @{}
$UninstallKeys = $(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
    if(Test-Path -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'){'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'}
)

Get-ChildItem -Path $UninstallKeys -ErrorAction SilentlyContinue | ForEach-Object {
    if(-Not ($ProductIDList.ContainsKey($_.PSChildName)))
    {
        $Data = Get-ItemProperty -Path $_.PSPath | Select-Object -Property DisplayName, Version, UninstallString, Publisher, ModifyPath, InstallSource, InstallDate, DisplayVersion
        $ProductIDList.Add($_.PSChildName,$Data)
    }
} 

#Uninstall application
$ApplicationToRemove = 'Java'

    If ($ProductIDList.Values.displayname -like "*$ApplicationToRemove*"){

        If ($ProductIDList.Values.displayname){
            foreach($Appl in $ProductIDList.GetEnumerator()) {
                if($Appl.Value.DisplayName -like "*$ApplicationToRemove*") {
                    $ProductCode = $Appl.Key
                    $Name = $Appl.Value.DisplayName
                    $Version = $Appl.Value.DisplayVersion
                    Write-Verbose –Message "Uninstalling $Name $Version.....Wait....." –Verbose
                    Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList "/x $ProductCode /QB-! REBOOT=ReallySuppress /L*v `"$logdir\Uninstall-$Name $Version.log`"" -Wait
                }
            }
        } 
    }
    Else {
    Write-Verbose –Message "No application named $ApplicationToRemove was found." –Verbose
    }


#End stopp logging
Write-Verbose –Message "Done" –Verbose
Stop-Transcript