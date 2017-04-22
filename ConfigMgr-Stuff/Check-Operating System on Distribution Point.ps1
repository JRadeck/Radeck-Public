$ModulePath = Join-path -Path (Split-Path $Env:SMS_ADMIN_UI_PATH -Parent) -ChildPath 'ConfigurationManager.psd1'
Import-module $ModulePath
$Sitecode = (gwmi -Namespace root\ccm -Class SMS_Authority -ErrorAction SilentlyContinue).Name.split(":")[1]
if (!($Sitecode)) {
$Sitecode = Read-Host "Unable to fetch Sitecode. Please provide Sitecode: "
}

Set-Location $SiteCode":\"
$DomainFQDN = (Get-WmiObject win32_computersystem).Domain

Get-CMDistributionPoint |  Where-Object {$_.NALType -ne 'Windows Intune'} | select NetworkOSPath | ` 
    foreach {($_.NetworkOSPath).replace("\\","").replace(".$DomainFQDN","")} | Select @{label="Name";Expression={$_}},` 
    @{label="IPAddress";Expression={(Resolve-DnsName $_ -Type A -ErrorAction SilentlyContinue).IPAddress}},` 
    @{label="Ping";Expression={Test-NetConnection $_ -InformationLevel Quiet}},` 
    @{label="OS";Expression={(Get-CimInstance -ComputerName $_  Win32_OperatingSystem).Caption}} | ft -AutoSize