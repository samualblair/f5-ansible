$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("X-F5-Auth-Token", "$responseToken")

$response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/declarative-onboarding/info" -Method 'GET' -Headers $headers
$response | ConvertTo-Json
