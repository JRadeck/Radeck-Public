	function Get-OSName {
		param(
			[parameter(Mandatory = $true)]
			[ValidateNotNullOrEmpty()]
			[string]$InputObject
		)
		
        If ($InputObject.StartsWith('2')) {

        Write-Host "Windows 11"

        }

        ElseIf ($InputObject.StartsWith('1')) {

        Write-Host "Windows 10"
 
        }

        Else {

			Write-Host "Unable to translate OS version using input object: $($InputObject)"
			Write-Host "Unsupported OS version detected"
		}		

					
		
		 #Handle return value from function
	     return $OSName
	}



try {

    $TSEnvironment = New-Object -ComObject "Microsoft.SMS.TSEnvironment" -ErrorAction Stop
    $OSDrive = $TSEnvironment.Value("OSDTargetSystemDrive")
    $OSBuildNr = ((Dism /Image:$($OSDrive)\ /Get-Intl | Select-String -Pattern 'Image Version').ToString()).Split('.') | Select-Object -Index 2

    
    } catch [System.Exception] {
    
    $OSBuildNr = ((Dism /Online /Get-Intl | Select-String -Pattern 'Image Version').ToString()).Split('.') | Select-Object -Index 2
}


Get-OSName $OSBuildNr




