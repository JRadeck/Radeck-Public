if (!((Get-WmiObject Win32_Product).name -eq 'Crystal Reports 2008 Runtime SP2')){
Write-Verbose –Message 'Installing Crystal Reports 2008 Runtime SP2' –Verbose
start-process 'c:\Windows\System32\msiexec.exe' -ArgumentList "/i CRRuntime_12_2_mlb.msi /QB! REBOOT=ReallySuppress /l*v $env:WINDIR\Temp\Install-Crystal Reports 2008 Runtime SP2.log" -wait -Verbose
}
Else{
Write-Verbose –Message 'Found Crystal Reports 2008 Runtime SP2' –Verbose
}
