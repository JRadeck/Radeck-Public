<#
.Synopsis
   Check for application and the uninstall it
.DESCRIPTION
   List uninstall registry keys and search for specific application and then uninstall it
   Script name: Uninstall-Application.ps1
   Created: 2016-09-22
   Version: 1.1
.EXAMPLE
   Uninstall-Application.ps1 -ApplicationToRemove ApplicationName -MSIEXE MSI
   Uninstall-Application.ps1 -ApplicationToRemove ApplicationName -MSIEXE EXE

.NOTES

   Author:
       Johnny Radeck
       Twitter: @Johnny_Radeck
       Blog   : http://radeck.se

   Disclaimer:
       This script is provided "AS IS" with no warranties, confers no rights and 
       is not supported by the author.
#>

Param(
    [cmdletbinding()]
    [String]
    [Parameter(Mandatory=$true)]
    $ApplicationToRemove,
    [Parameter(Mandatory=$true)]
    [ValidateSet('MSI','EXE')]
    $MSIEXE
    )

Function Write-Verbose {
    [cmdletbinding()]
    param(
        $Message
    )
    $NewMessage = '[{0}] {1}' -f (Get-Date -Format 'HH:mm:ss'), $Message
    Microsoft.PowerShell.Utility\Write-Verbose -Message $NewMessage
}

#====================Setup Logging====================
$Date = Get-Date -DisplayHint Date -Format 'yyyy-MM-dd'
$Model = (Get-WmiObject -Class Win32_ComputerSystem).Model
$Name = (Get-WmiObject -Class Win32_ComputerSystem).Name
$Logdir = "$env:Programdata\ApplicationsLogs"

    if (Test-path $logdir){
        Write-Verbose –Message 'Log folder found' –Verbose
    }
    Else {
        Write-Verbose –Message 'No log folder found. Creating it' –Verbose
        New-item -type directory $logdir -Verbose
    }

$LogFile = "$Logdir\$($myInvocation.MyCommand).log"
Start-Transcript -Append $logFile –Verbose
Write-Verbose –Message "$Date Start Logging to $logFile" –Verbose
Write-Verbose –Message "Model: $model" –Verbose
Write-Verbose –Message "Computername: $Name" –Verbose


#====================List installed applications====================
$ProductIDList = @{}
$UninstallKeys = $(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
    If(Test-Path -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'){'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'}
)
Get-ChildItem -Path $UninstallKeys -ErrorAction SilentlyContinue | ForEach-Object {
    if(-Not ($ProductIDList.ContainsKey($_.PSChildName)))
    {
        $Data = Get-ItemProperty -Path $_.PSPath | Select-Object -Property DisplayName, Version, UninstallString, Publisher, ModifyPath, InstallSource, InstallDate, DisplayVersion 
        $ProductIDList.Add($_.PSChildName,$Data)
    }
} 

$CleanProductIDList = $ProductIDList.GetEnumerator()| ? Value # Remove applications with empty value

#====================Close Applications====================
If ($CleanProductIDList.Value.displayname -like "*$ApplicationToRemove*"){

    $AppsList = get-process | where-object {$_.Product -like "*$ApplicationToRemove*"}

    IF ($AppsList) {

        ForEach ($App in $AppsList){
        if (Get-Process -Name $App.ProcessName -ErrorAction SilentlyContinue){
        stop-process -name $App.ProcessName -Force -ErrorAction 'SilentlyContinue'
        Write-Verbose –Message "$ApplicationToRemove was running but not any more" -Verbose
                }
            }
        }
    Else {
    Write-Verbose –Message "$ApplicationToRemove was not running" -Verbose
    }
    }
    Else {
    Write-Verbose –Message "No application named $ApplicationToRemove was found running." –Verbose
    
}
#====================Uninstall application====================
If($PSBoundParameters.ContainsKey('ApplicationToRemove')) {

    If ($CleanProductIDList.Value.displayname -like "*$ApplicationToRemove*"){

        Foreach($Appl in $CleanProductIDList.GetEnumerator()) {

            If($Appl.Value.DisplayName -like "*$ApplicationToRemove*" -and $MSIEXE -eq 'MSI') {
                $ProductCode = $Appl.Key
                $Name = $Appl.Value.DisplayName
                $Version = $Appl.Value.DisplayVersion
                Write-Verbose –Message "Uninstalling $Name $Version.....Wait....." –Verbose
                Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList "/x $ProductCode /QB-! REBOOT=ReallySuppress /L*v `"$logdir\Uninstall-$Name $Version.log`"" -Wait
            }

            If($Appl.Value.DisplayName -like "*$ApplicationToRemove*" -and $MSIEXE -eq 'EXE') {
                    $Uninstall = $Appl.Value.UninstallString
                    $Name = $Appl.Value.DisplayName
                    $Version = $Appl.Value.DisplayVersion
                    Write-Verbose –Message "Uninstalling $Name $Version.....Wait....." –Verbose
                    Start-Process -FilePath $Uninstall -ArgumentList '/S' -Wait
                }
    } 
}
Else {
Write-Verbose –Message "No application named $ApplicationToRemove was found to uninstall." –Verbose
}
}

#====================End stopp logging====================
Write-Verbose –Message "Done" –Verbose
Stop-Transcript   
