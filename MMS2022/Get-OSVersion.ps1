	function Get-OSBuild {
		param(
			[parameter(Mandatory = $true, HelpMessage = "OS version data to be translated.")]
			[ValidateNotNullOrEmpty()]
			[string]$InputObject
		)
		switch ([String]$InputObject) {
			"22000" {
				$OSVersion = '21H2'
			}
			"19044" {
				$OSVersion = '21H2'
			}
			"19043" {
				$OSVersion = '21H1'
			}
			"19042" {
				$OSVersion = '20H2'
			}
			"19041" {
				$OSVersion = 2004
			}
			"18363" {
				$OSVersion = 1909
			}
			"18362" {
				$OSVersion = 1903
			}
			"17763" {
				$OSVersion = 1809
			}
			"17134" {
				$OSVersion = 1803
			}
			"16299" {
				$OSVersion = 1709
			}
			"15063" {
				$OSVersion = 1703
			}
			"14393" {
				$OSVersion = 1607
			}
			default {
				Write-Host "Unable to translate OS version using input object: $($InputObject)"
				Write-Host "Unsupported OS version detected, please reach out to the developers of this script"
				

			}
		}
		
		# Handle return value from function
		return $OSVersion
	}


try {

    $TSEnvironment = New-Object -ComObject "Microsoft.SMS.TSEnvironment" -ErrorAction Stop
    $OSDrive = $TSEnvironment.Value("OSDTargetSystemDrive")
    $OSBuildNr = ((Dism /Image:$($OSDrive)\ /Get-Intl | Select-String -Pattern 'Image Version').ToString()).Split('.') | Select-Object -Index 2

    
    } catch [System.Exception] {
    
    $OSBuildNr = ((Dism /Online /Get-Intl | Select-String -Pattern 'Image Version').ToString()).Split('.') | Select-Object -Index 2
}


Get-OSBuild $OSBuildNr
