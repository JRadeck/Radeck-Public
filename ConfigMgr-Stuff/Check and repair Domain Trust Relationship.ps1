#In the Discovery script put
Test-ComputerSecureChannel

#Create Secret
$Text = 'P@ssword'
$Secret = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($Text))
$Secret

#And in the Remediation script put 
#Change Secret and Username

if (!(Test-ComputerSecureChannel)) {
    $Secret = 'UABAAHMAcwB3AG8AcgBkAA==' # P@ssw0rd
    $DecodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Secret))
    $Username = 'DOMAIN\Username with Reset Computer password rights'
    $password = convertto-securestring -String $DecodedText -AsPlainText -Force
    $ADRepairCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
    Test-ComputerSecureChannel -Repair -Credential $ADRepairCred
    }
    