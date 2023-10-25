<#
 .SYNOPSIS
    
 
 .DESCRIPTION
    Check Intune for models and then creates EntraID groups based on that.
    Lenovo will have easily readable group name and the crap name in the dynamic query.
    You need to install moudule
    Microsoft.Graph.Authentication (Install-Module Microsoft.Graph.Authentication)
    Microsoft.Graph.DeviceManagement (Install-Module Microsoft.Graph.DeviceManagement)
    Microsoft.Graph.Groups (Install-Module Microsoft.Graph.Groups)
    
    
 .EXAMPLE
 
 
 .NOTES
     FileName:    Get Model and from Intune and create EntraID groups.ps1
     Author:      Johnny Radeck
     Contact:     @Johnny_Radeck
     Created:     2023-09-21
     Updated:     2023-10-25
 
     Version history:
     1.0.0 - (2023-09-21) Script created
     1.0.1 - (2023-09-25) Fix lenovo model "geggan"
     1.0.1 - (2023-09-27) Add param and update description
     1.0.2 - (2023-10-24) Add Suffix and Prefix to group namne
     1.0.3 - (2023-10-25) Add MDM to dynamic rule to avoid server ending upp in groups
     1.0.4 - (2023-10-25) Coreccted Prefix and Suffix order and updated DESCRIPTION text
     1.0.5 - (2023-10-25) Check if Enterprice App vaule worked with Try Catch

 #>

#For use in a runbook
#$TenantID = Get-AutomationVariable -Name 'TenantID'
#$ClientID = Get-AutomationVariable -Name 'ApplicationID'
#$ClientSecret = Get-AutomationVariable -Name 'Certificate'


$TenantID = ''
$ClientID = ''
$ClientSecret = ''


$GroupNamePrefix = 'EID - DYN - Model'
$GroupNameSuffix = ''


$Body = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $ClientID
    Client_Secret = $ClientSecret
}

Try {
$Connection = Invoke-RestMethod -Uri https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token -Method POST -Body $body
}
Catch {

    Write-Output "Getting Enerprise App value has failed"

}

$Token = ConvertTo-SecureString -AsPlainText $Connection.access_token -Force

Connect-MgGraph  -AccessToken  $Token -NoWelcome

$IntuneAll = Get-MgDeviceManagementManagedDevice  -Filter "OperatingSystem eq 'Windows'" -All | Select-Object Model, Manufacturer -Unique

foreach ($Item in $IntuneAll) {

    If ($Item.Manufacturer -eq 'LENOVO') {

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        [xml]$OEMLinks = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/maurice-daly/DriverAutomationTool/master/Data/OEMLinks.xml" -UseBasicParsing).Content 
        $LenovoXMLSource = ($OEMLinks.OEM.Manufacturer | Where-Object { $_.Name -match "Lenovo" }).Link | Where-Object { $_.Type -eq "XMLSource" } | Select-Object -ExpandProperty URL
        [xml]$LenovoModelXML = (New-Object System.Net.WebClient).DownloadString("$LenovoXMLSource")
        $LenovoModels = $LenovoModelXML.ModelList.Model
        $LenovoModel = (($LenovoModels | Where-Object { $_.types.type -eq "$(($Item.Model).Substring(0,4))" }).Name).Split(' ')
        $Model = [String]$LenovoModel[0, 1, 2, 3]

        $GroupName = ("$GroupNamePrefix $Model $GroupNameSuffix").Trim()

        If (!($CheckGroup = Get-MgGroup -All | Where-Object { $_.DisplayName -eq "$GroupName" })) {
                
            $CreatedGroup = New-MgGroup -DisplayName "$GroupName" -MailEnabled:$False -MailNickName "$(($Model).replace(' ',''))"  -SecurityEnabled -GroupTypes 'DynamicMembership' -MembershipRule "(device.deviceModel startsWith  `"$(($Item.Model).Substring(0,4))`") and (device.managementType -eq `"MDM`")" -membershipRuleProcessingState on    
        
            Write-Output "Created group $($CreatedGroup.DisplayName)"
        }
        Else { Write-Output "Group `"$($CheckGroup.DisplayName)`" already exists." }
        
    }
    Else {

        $Model = [String]$Item.Model

        $GroupName = ("$GroupNamePrefix $Model $GroupNameSuffix").Trim()

        If (!($CheckGroup = Get-MgGroup -All | Where-Object { $_.DisplayName -eq "$GroupName" })) {
                
            $CreatedGroup = New-MgGroup -DisplayName "$GroupName" -MailEnabled:$False -MailNickName "$(($Model).replace(' ',''))"  -SecurityEnabled -GroupTypes 'DynamicMembership' -MembershipRule "(device.deviceModel -eq `"$Model`") and (device.managementType -eq `"MDM`")" -membershipRuleProcessingState on

            Write-Output "Created group $($CreatedGroup.DisplayName)"

        }
        Else { Write-Output "Group `"$($CheckGroup.DisplayName)`" already exists." }
    }
    
}


