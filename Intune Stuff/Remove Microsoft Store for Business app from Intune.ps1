Connect-MSGraph

$Resource = 'deviceAppManagement/mobileApps'
$StoreForBusinessApp = (Invoke-MSGraphRequest -HttpMethod GET -Url $Resource).Value | Where-Object "@odata.type" -eq "#microsoft.graph.microsoftStoreForBusinessApp"

Foreach ($App in $StoreForBusinessApp) {

    $URI = "deviceAppManagement/mobileApps/$($App.Id)"
    $App.displayName
    Invoke-MSGraphRequest -HttpMethod DELETE -Url $URI

}


